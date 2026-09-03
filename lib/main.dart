import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_info.dart';
import 'core/haptics/haptics.dart';
import 'core/theme/app_motion.dart';
import 'core/theme/app_theme.dart';
import 'data/local/backup_scheduler.dart';
import 'data/providers/data_providers.dart';
import 'l10n/app_localizations.dart';
import 'presentation/boot/boot_gate.dart';
import 'presentation/settings/settings_providers.dart';
import 'presentation/settings/update_providers.dart';
import 'presentation/shared/app_entry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // Настройки читаем до первого кадра: тема и язык не должны «моргать».
  final prefs = await SharedPreferences.getInstance();

  // Возможности вибромотора опрашиваем один раз — дальше Haptics работает
  // синхронно из любого места.
  await Haptics.init();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TexFiFokusApp(),
    ),
  );
}

class TexFiFokusApp extends ConsumerStatefulWidget {
  const TexFiFokusApp({super.key});

  @override
  ConsumerState<TexFiFokusApp> createState() => _TexFiFokusAppState();
}

class _TexFiFokusAppState extends ConsumerState<TexFiFokusApp> {
  /// Инициализация уведомлений идёт под загрузочной заставкой: она трогает
  /// платформенные каналы и раньше просто откладывалась на первый кадр.
  /// Теперь заставка её прикрывает — и ждёт, если та окажется дольше
  /// анимации.
  Future<void> _initServices() {
    // Проверка обновлений запускается, но не ожидается: заставка не должна
    // ждать сеть. Если GitHub недоступен или лимит исчерпан — проверка молча
    // ничего не найдёт, и запуск от этого не изменится ни на кадр.
    unawaited(ref.read(updateControllerProvider.notifier).checkOnLaunch());

    // Резервная копия тоже не ожидается: она читает всю базу и пишет файл,
    // и держать ради этого заставку на экране незачем. Сама она проверит,
    // назрела ли, и в обычный запуск не сделает ничего.
    unawaited(_runScheduledBackup());

    // Уборка снимков, на которые больше никто не ссылается. Тоже не
    // ожидается — на запуск она влиять не должна.
    //
    // Именно на старте, и это не случайность: черновик сессии живёт в
    // памяти и холодный запуск не переживает, поэтому в этот момент
    // «прикреплённого, но ещё не сохранённого» снимка не существует по
    // построению. Убирать в любой другой момент значило бы гоняться за
    // файлом, который человек прямо сейчас держит в открытом check-in.
    unawaited(_sweepOrphanedPhotos());

    return ref.read(notificationServiceProvider).init();
  }

  Future<void> _sweepOrphanedPhotos() async {
    try {
      final keep = await ref.read(sessionRepositoryProvider).referencedPhotoPaths();
      final removed =
          await ref.read(sessionPhotoStoreProvider).deleteUnreferenced(keep);
      if (removed > 0) {
        debugPrint('session photos: removed $removed orphaned file(s)');
      }
    } catch (error, stack) {
      // Уборка — самое необязательное, что происходит на запуске. Упасть на
      // ней и не открыть приложение было бы несоизмеримо хуже мусора.
      debugPrint('sweeping orphaned session photos failed: $error\n$stack');
    }
  }

  Future<void> _runScheduledBackup() async {
    final path = await ref.read(backupRunnerProvider).runIfDue(
          enabled: ref.read(autoBackupEnabledProvider),
        );
    if (path == null || !mounted) return;
    // Дата под тумблером в настройках должна обновиться в этом же запуске,
    // а не после перезахода.
    ref.read(lastAutoBackupProvider.notifier).state = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // Читаем настройки отклика на первом кадре, чтобы статический Haptics
    // был согласован с ними ещё до того, как пользователь зайдёт в настройки.
    ref.watch(vibrationEnabledProvider);
    ref.watch(vibrationIntensityProvider);
    final accent = ref.watch(accentProvider);

    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(brightness: Brightness.light, accent: accent),
      darkTheme: AppTheme.build(brightness: Brightness.dark, accent: accent),
      themeMode: ref.watch(themeModeProvider),
      themeAnimationDuration: AppMotion.normal,
      locale: ref.watch(localeProvider),
      supportedLocales: supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BootGate(
        onReady: _initServices,
        child: const AppEntry(),
      ),
    );
  }
}
