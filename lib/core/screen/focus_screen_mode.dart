import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Платформенные действия над экраном, спрятанные за интерфейсом.
///
/// Не ради абстракции как таковой: без этого шва нельзя проверить тестом
/// главное свойство режима — что яркость возвращается и блокировка снимается
/// на любом пути выхода. А проверять это надо именно тестом: забытая
/// пониженная яркость переживает закрытие экрана и выглядит как поломка
/// телефона, а не приложения.
abstract class ScreenControls {
  Future<void> keepAwake(bool enabled);

  /// Яркость, заданная приложением поверх системной.
  Future<void> setBrightness(double value);

  /// Вернуть системную яркость. Отдельный вызов, а не `setBrightness`
  /// с прежним значением: плагин помнит исходное сам, и это надёжнее, чем
  /// хранить снимок у себя — пользователь мог покрутить яркость шторкой,
  /// пока наш экран был открыт.
  Future<void> restoreBrightness();
}

/// Боевая реализация. Все вызовы обёрнуты: ни один из них не стоит того,
/// чтобы уронить экран таймера посреди сессии, а на десктопе половина из них
/// просто не поддерживается.
class PlatformScreenControls implements ScreenControls {
  const PlatformScreenControls();

  /// Управление яркостью — только там, где оно вообще есть.
  static bool get _canDim => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Future<void> keepAwake(bool enabled) async {
    try {
      await WakelockPlus.toggle(enable: enabled);
    } catch (error) {
      debugPrint('keepAwake($enabled) failed: $error');
    }
  }

  @override
  Future<void> setBrightness(double value) async {
    if (!_canDim) return;
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(value);
    } catch (error) {
      debugPrint('setBrightness failed: $error');
    }
  }

  @override
  Future<void> restoreBrightness() async {
    if (!_canDim) return;
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (error) {
      debugPrint('restoreBrightness failed: $error');
    }
  }
}

/// Что приложение делает с экраном, пока открыт таймер.
///
/// Две отдельные вещи с общим сроком жизни:
///  * экран не гаснет, пока идёт сессия, — на таймер смотрят, а трогать его
///    руками раз в минуту, чтобы он не погас, бессмысленно;
///  * «тихий режим» — приглушённый монохромный вид того же таймера.
///
/// Ключевое требование — снятие. Уйти с экрана можно жестом «назад»,
/// системной кнопкой, программно после конца сессии, — и во всех случаях
/// яркость обязана вернуться, а блокировка сна сняться. Поэтому снятие
/// собрано в один [release], который зовётся из `dispose()`: это
/// единственный путь, который отрабатывает при любом способе ухода.
///
/// Это не системный Always-On Display: он живёт вне приложения и требует
/// прав, которых у обычного приложения нет. Здесь — просто вид экрана
/// таймера, поэтому и называется он в интерфейсе «тихим режимом».
class FocusScreenMode {
  FocusScreenMode({ScreenControls? controls})
      : _controls = controls ?? const PlatformScreenControls();

  final ScreenControls _controls;

  /// Яркость тихого режима. Не ноль: экран должен остаться читаемым в
  /// тёмной комнате, а не погаснуть.
  static const double dimBrightness = 0.05;

  bool _awake = false;
  bool _quiet = false;
  bool _released = false;

  bool get isQuiet => _quiet;
  bool get isAwake => _awake;

  /// Вход на экран таймера: держим экран включённым.
  Future<void> enter() async {
    if (_released || _awake) return;
    _awake = true;
    await _controls.keepAwake(true);
  }

  Future<void> setQuiet(bool value) async {
    if (_released || _quiet == value) return;
    _quiet = value;
    if (value) {
      await _controls.setBrightness(dimBrightness);
    } else {
      await _controls.restoreBrightness();
    }
  }

  Future<void> toggleQuiet() => setQuiet(!_quiet);

  /// Единственный путь снятия. Идемпотентен: `dispose()` может прийти после
  /// того, как пользователь уже вышел из тихого режима руками, и второй
  /// возврат яркости не должен ничего испортить.
  ///
  /// Яркость возвращается всегда, даже если тихий режим считается
  /// выключенным: если запрос на возврат когда-то не прошёл, состояние в
  /// приложении и состояние экрана разошлись, и верить надо экрану.
  Future<void> release() async {
    if (_released) return;
    _released = true;
    _quiet = false;
    _awake = false;
    await _controls.restoreBrightness();
    await _controls.keepAwake(false);
  }
}
