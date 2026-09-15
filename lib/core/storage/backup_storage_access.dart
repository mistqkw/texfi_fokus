import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Доступ к общему внутреннему хранилищу, куда пишутся резервные копии.
///
/// Тот же принцип, что и у [FocusMode]: доступ выдаётся не диалогом, а
/// отдельным системным экраном, и результат самого перехода на него не
/// значит согласия — согласие проверяется следующим [hasAccess] после
/// возврата в приложение.
class BackupStorageAccess {
  const BackupStorageAccess({@visibleForTesting this.supportedOverride});

  /// Подмена ответа [isSupported] в тестах — по той же причине, что и в
  /// [FocusMode]: тесты идут на хосте, где `Platform.isAndroid` ложно всегда.
  @visibleForTesting
  final bool? supportedOverride;

  static const String channelName = 'com.texfi.texfi_fokus/backup_storage';

  static const MethodChannel _channel = MethodChannel(channelName);

  /// Есть ли вообще такое понятие на этой платформе. На десктопе «Документы»
  /// доступны без всякого отдельного разрешения — там спрашивать нечего.
  bool get isSupported => supportedOverride ?? (!kIsWeb && Platform.isAndroid);

  /// Выдан ли доступ к общему хранилищу. На платформах без этого понятия —
  /// всегда `true`: там сам вопрос не встаёт.
  Future<bool> hasAccess() async {
    if (!isSupported) return true;
    return await _invoke('hasAccess') ?? false;
  }

  /// Открывает системный экран «Доступ ко всем файлам».
  Future<bool> requestManageStorage() async {
    if (!isSupported) return true;
    return await _invoke('requestManageStorage') ?? false;
  }

  /// Открывает папку `TexFi Backup` в системном приложении «Файлы».
  ///
  /// Возвращает `false`, если открыть не вышло (нет подходящего приложения,
  /// либо доступ ещё не выдан) — тогда экран импорта сам покажет путь
  /// текстом вместо того, чтобы промолчать.
  Future<bool> openBackupFolder() async {
    if (!isSupported) return false;
    return await _invoke('openBackupFolder') ?? false;
  }

  Future<bool?> _invoke(String method) async {
    try {
      return await _channel.invokeMethod<bool>(method);
    } on PlatformException catch (error) {
      debugPrint('BackupStorageAccess.$method failed: ${error.message}');
      return null;
    } on MissingPluginException {
      // Канал не зарегистрирован — сборка без нативной части. Импорт и
      // экспорт остаются доступны, просто без ярлыка на системную папку.
      return null;
    }
  }
}
