import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Вибро-отклик приложения.
///
/// У каждого события — свой ритм, а не один универсальный «бз». Настроение
/// на переключателе ощущается по-разному: «плохое» — один короткий слабый
/// импульс, «full f0kus» — нарастающая очередь. Крутилка таймера отбивает
/// щелчок на каждые N минут.
///
/// Там, где вибромотора нет (десктоп, часть планшетов) или пакет `vibration`
/// не поддерживает произвольные паттерны, мы откатываемся на встроенный
/// [HapticFeedback] — он есть на всех платформах и просто ничего не делает
/// там, где отклик недоступен.
abstract final class Haptics {
  /// Общий выключатель вибрации из настроек.
  static bool enabled = true;

  /// 0.0–1.0, настраивается пользователем. Масштабирует amplitude там,
  /// где платформа это поддерживает.
  static double _intensity = 1.0;

  static bool? _hasVibrator;
  static bool? _hasAmplitudeControl;
  static bool? _hasCustomVibrationsSupport;

  static double get intensity => _intensity;

  static set intensity(double value) => _intensity = value.clamp(0.0, 1.0);

  /// Опрашивает возможности устройства один раз при старте. Безопасно
  /// вызывать повторно и на платформах без плагина — любые ошибки
  /// проглатываются, приложение просто останется на HapticFeedback.
  static Future<void> init() async {
    try {
      _hasVibrator = await Vibration.hasVibrator();
      _hasAmplitudeControl = await Vibration.hasAmplitudeControl();
      _hasCustomVibrationsSupport = await Vibration.hasCustomVibrationsSupport();
    } catch (error, stack) {
      debugPrint('Haptics.init failed: $error\n$stack');
      _hasVibrator = false;
      _hasAmplitudeControl = false;
      _hasCustomVibrationsSupport = false;
    }
  }

  static bool get _canPattern =>
      enabled &&
      (_hasVibrator ?? false) &&
      (_hasCustomVibrationsSupport ?? false);

  static int _amplitude(int base) =>
      (base * _intensity).round().clamp(1, 255);

  static Future<void> _pattern(
    List<int> pattern,
    List<int> intensities,
    Future<void> Function() fallback,
  ) async {
    if (!enabled) return;
    if (!_canPattern) {
      await _plainVibrate(pattern, fallback);
      return;
    }
    try {
      await Vibration.vibrate(
        pattern: pattern,
        intensities: (_hasAmplitudeControl ?? false)
            ? intensities.map(_amplitude).toList()
            : const [],
      );
    } catch (error) {
      debugPrint('Haptics pattern failed: $error');
      await _plainVibrate(pattern, fallback);
    }
  }

  /// Промежуточная ступень между паттерном и [HapticFeedback].
  ///
  /// Мотор есть, но произвольные паттерны недоступны — тогда лучше отдать
  /// системе одну вибрацию нужной длительности, чем сразу падать на
  /// `HapticFeedback`: тот на части устройств привязан к системному профилю
  /// звука и в беззвучном режиме не делает ничего. `Vibration.vibrate` идёт
  /// прямо в вибромотор и от профиля не зависит.
  static Future<void> _plainVibrate(
    List<int> pattern,
    Future<void> Function() fallback,
  ) async {
    if (!(_hasVibrator ?? false)) {
      await fallback();
      return;
    }
    // Нечётные позиции паттерна — сами импульсы, чётные — паузы между ними.
    var total = 0;
    for (var i = 1; i < pattern.length; i += 2) {
      total += pattern[i];
    }
    if (total <= 0) {
      await fallback();
      return;
    }
    try {
      await Vibration.vibrate(duration: total.clamp(10, 2000));
    } catch (error) {
      debugPrint('Haptics plain vibrate failed: $error');
      await fallback();
    }
  }

  // --- Настроение: четыре разных характера ---

  /// Плохое — один короткий слабый импульс. Не бодрит, а признаёт.
  static Future<void> moodBad() => _pattern(
        const [0, 30],
        const [0, 70],
        HapticFeedback.selectionClick,
      );

  /// Нормальное — ровный средний тычок.
  static Future<void> moodNeutral() => _pattern(
        const [0, 45],
        const [0, 120],
        HapticFeedback.lightImpact,
      );

  /// Хорошее — два коротких: уже с настроением.
  static Future<void> moodGood() => _pattern(
        const [0, 35, 40, 45],
        const [0, 140, 0, 170],
        HapticFeedback.mediumImpact,
      );

  /// full f0kus — нарастающая очередь: разгон перед сессией.
  static Future<void> moodFullFokus() => _pattern(
        const [0, 25, 30, 35, 30, 50, 30, 80],
        const [0, 90, 0, 140, 0, 190, 0, 255],
        HapticFeedback.heavyImpact,
      );

  static Future<void> mood(int index) => switch (index) {
        0 => moodBad(),
        1 => moodNeutral(),
        2 => moodGood(),
        _ => moodFullFokus(),
      };

  // --- Запуск приложения ---
  //
  // Четыре разных ощущения на четыре такта загрузочной анимации. Смысл
  // именно в разнице: одинаковый «бз» четыре раза подряд читается как сбой,
  // а нарастающая последовательность — как «система поднимается».

  /// Такт 1 — включение питания. Едва заметный щелчок: экран только загорелся.
  static Future<void> bootPowerOn() => _pattern(
        const [0, 14],
        const [0, 60],
        HapticFeedback.selectionClick,
      );

  /// Такты 2–4 — сборка знака. Три ступени: одиночный слабый импульс,
  /// двойной средний, тройной с разгоном. Каждая следующая плотнее
  /// предыдущей, поэтому ожидание ощущается как приближение к финалу.
  static Future<void> bootAssemble(int stage) => switch (stage) {
        0 => _pattern(
            const [0, 18],
            const [0, 80],
            HapticFeedback.selectionClick,
          ),
        1 => _pattern(
            const [0, 22, 26, 26],
            const [0, 120, 0, 150],
            HapticFeedback.lightImpact,
          ),
        _ => _pattern(
            const [0, 20, 22, 26, 22, 34],
            const [0, 150, 0, 185, 0, 220],
            HapticFeedback.mediumImpact,
          ),
      };

  /// Финал — знак «защёлкнулся». Короткая пауза перед последним длинным
  /// импульсом: именно она делает его похожим на щелчок замка, а не на
  /// продолжение очереди.
  static Future<void> bootLock() => _pattern(
        const [0, 36, 70, 150],
        const [0, 170, 0, 255],
        HapticFeedback.heavyImpact,
      );

  // --- Таймер и общие события ---

  /// Щелчок крутилки — на каждый шаг в N минут. Должен быть очень коротким:
  /// пользователь получает их десятками за один жест.
  static Future<void> dialTick() => _pattern(
        const [0, 12],
        const [0, 90],
        HapticFeedback.selectionClick,
      );

  /// Конец фокус-цикла — заметный двойной импульс.
  static Future<void> cycleComplete() => _pattern(
        const [0, 60, 60, 120],
        const [0, 200, 0, 255],
        HapticFeedback.heavyImpact,
      );

  /// Конец всей сессии — финальный тройной аккорд.
  static Future<void> sessionComplete() => _pattern(
        const [0, 80, 60, 80, 60, 160],
        const [0, 200, 0, 220, 0, 255],
        HapticFeedback.heavyImpact,
      );

  /// Сигнал «время вышло» — самостоятельный, а не украшение к звуку.
  ///
  /// Отличается от [sessionComplete] намеренно: тот аккорд играет, когда
  /// пользователь смотрит на экран и всё и так очевидно. Этот — единственное,
  /// что человек получит, если телефон лежит экраном вниз в беззвучном
  /// режиме, поэтому он длинный, с двумя одинаковыми группами и заметной
  /// паузой между ними: такой ритм не спутать с приходом сообщения.
  static Future<void> timerAlarm() => _pattern(
        const [0, 220, 140, 220, 140, 420],
        const [0, 255, 0, 255, 0, 255],
        HapticFeedback.heavyImpact,
      );

  /// Привычка отмечена выполненной.
  static Future<void> success() => _pattern(
        const [0, 25, 35, 55],
        const [0, 130, 0, 200],
        HapticFeedback.mediumImpact,
      );

  /// Лёгкое подтверждение нажатия.
  static Future<void> tap() async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Отмена, удаление, ошибка ввода.
  static Future<void> warning() => _pattern(
        const [0, 90],
        const [0, 220],
        HapticFeedback.vibrate,
      );

  /// Останавливает всё, что сейчас играет — например, при выходе с экрана
  /// таймера во время длинного паттерна.
  static Future<void> cancel() async {
    if (!(_hasVibrator ?? false)) return;
    try {
      await Vibration.cancel();
    } catch (error) {
      debugPrint('Haptics.cancel failed: $error');
    }
  }
}
