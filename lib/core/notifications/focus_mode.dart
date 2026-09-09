import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Тишина на время фокус-сессии.
///
/// Заглушить чужие уведомления умеет только система, и только по явно
/// выданному доступу к «Не беспокоить». Поэтому здесь три состояния, а не
/// два: режим может быть недоступен вовсе (не Android), доступен без
/// разрешения и доступен с разрешением. Экран настроек показывает разные
/// вещи в каждом из них — молча «включить» то, что не включится, было бы
/// хуже, чем не предлагать вовсе.
///
/// Свои напоминания приложение глушит само и без всякого разрешения (см.
/// `NotificationService.suspendReminders`); этот класс — только про чужие.
class FocusMode {
  const FocusMode({@visibleForTesting this.supportedOverride});

  /// Подмена ответа [isSupported] в тестах.
  ///
  /// Тесты идут на хосте, где `Platform.isAndroid` ложно всегда, и без этого
  /// шва проверить можно было бы ровно одно: что на Linux ничего не
  /// происходит. А проверять надо обратное — что на поддерживаемой платформе
  /// вызовы уходят в канал под правильными именами.
  @visibleForTesting
  final bool? supportedOverride;

  static const String channelName = 'com.texfi.texfi_fokus/focus_mode';

  static const MethodChannel _channel = MethodChannel(channelName);

  /// Есть ли вообще такая возможность на этой платформе.
  ///
  /// На десктопе и в вебе системного «Не беспокоить», которым можно было бы
  /// управлять из приложения, нет — там настройка не показывается.
  bool get isSupported =>
      supportedOverride ?? (!kIsWeb && Platform.isAndroid);

  /// Выдан ли доступ к политике уведомлений.
  Future<bool> isGranted() async {
    if (!isSupported) return false;
    return await _invoke('isGranted') ?? false;
  }

  /// Открывает системный экран, где доступ выдаётся вручную.
  ///
  /// Результат означает лишь «экран открылся»: согласие проверяется
  /// следующим [isGranted] после возврата в приложение.
  Future<bool> openAccessSettings() async {
    if (!isSupported) return false;
    return await _invoke('openAccessSettings') ?? false;
  }

  /// Включить тишину. Возвращает `false`, если не вышло — например, доступ
  /// отозвали уже после того, как настройку включили.
  Future<bool> enable() async {
    if (!isSupported) return false;
    return await _invoke('enable') ?? false;
  }

  /// Снять тишину и вернуть тот фильтр, что стоял до сессии.
  ///
  /// Безопасно вызывать лишний раз: если режим ставили не мы, нативная
  /// сторона ничего не трогает.
  Future<bool> disable() async {
    if (!isSupported) return false;
    return await _invoke('disable') ?? false;
  }

  /// Снять тишину, забытую прошлым запуском.
  ///
  /// Процесс могут выгрузить посреди сессии — тогда снимать режим будет
  /// некому, и человек останется в тишине неизвестно насколько. Вызывается
  /// на старте приложения.
  Future<void> restoreAfterCrash() async {
    if (!isSupported) return;
    await _invoke('restore');
  }

  Future<bool?> _invoke(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method);
    } on PlatformException catch (error) {
      debugPrint('FocusMode.$method failed: ${error.message}');
      return null;
    } on MissingPluginException {
      // Канал не зарегистрирован — сборка без нативной части. Не повод
      // падать: тишина это удобство, а не условие работы таймера.
      return null;
    }
  }
}
