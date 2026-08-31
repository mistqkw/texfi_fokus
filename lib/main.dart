import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_info.dart';
import 'core/haptics/haptics.dart';
import 'core/theme/app_motion.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/data_providers.dart';
import 'l10n/app_localizations.dart';
import 'presentation/settings/settings_providers.dart';
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
  @override
  void initState() {
    super.initState();
    // Инициализация уведомлений — после первого кадра: она трогает
    // платформенные каналы и не должна задерживать запуск.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Читаем настройки отклика на первом кадре, чтобы статический Haptics
    // был согласован с ними ещё до того, как пользователь зайдёт в настройки.
    ref.watch(vibrationEnabledProvider);
    ref.watch(vibrationIntensityProvider);

    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(brightness: Brightness.light),
      darkTheme: AppTheme.build(brightness: Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      themeAnimationDuration: AppMotion.normal,
      locale: ref.watch(localeProvider),
      supportedLocales: supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AppEntry(),
    );
  }
}
