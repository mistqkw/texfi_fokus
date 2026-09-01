import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_info.dart';
import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../core/utils/duration_format.dart';
import '../../data/providers/data_providers.dart';
import '../shared/notification_sync.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_radio.dart';
import '../shared/pixel_sprite.dart';
import 'settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const Map<String, String> _languageNames = {
    'en': 'English',
    'ru': 'Русский',
    'pl': 'Polski',
    'uk': 'Українська',
  };

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await ref.read(exportServiceProvider).exportToFile();
      Haptics.success();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsExportDone(path))),
      );
    } catch (error) {
      Haptics.warning();
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.settingsExportFailed}: $error')),
      );
    }
  }

  Future<void> _pickSummaryTime(BuildContext context, WidgetRef ref) async {
    final current = ref.read(dailySummaryTimeProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
    );
    if (picked == null || !context.mounted) return;
    final l10n = context.l10n;
    await ref
        .read(dailySummaryTimeProvider.notifier)
        .set(picked.hour * 60 + picked.minute);
    await syncNotifications(ref, l10n);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final sounds = ref.watch(soundsEnabledProvider);
    final vibration = ref.watch(vibrationEnabledProvider);
    final intensity = ref.watch(vibrationIntensityProvider);
    final notifications = ref.watch(notificationsEnabledProvider);
    final summaryTime = ref.watch(dailySummaryTimeProvider);

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.settingsTitle),
        ),
        body: ListView(
          padding: AppSpacing.screen,
          children: [
            PixelSectionHeader(title: l10n.settingsAppearance),
            PixelCard(
              child: Column(
                children: [
                  for (final mode in ThemeMode.values)
                    PixelRadioTile<ThemeMode>(
                      value: mode,
                      groupValue: themeMode,
                      title: switch (mode) {
                        ThemeMode.system => l10n.settingsThemeSystem,
                        ThemeMode.light => l10n.settingsThemeLight,
                        ThemeMode.dark => l10n.settingsThemeDark,
                      },
                      onChanged: (value) =>
                          ref.read(themeModeProvider.notifier).set(value),
                    ),
                ],
              ),
            ),
            AppSpacing.gapXl,
            PixelSectionHeader(title: l10n.settingsFeedback),
            PixelCard(
              child: Column(
                children: [
                  PixelSwitchTile(
                    value: sounds,
                    title: l10n.settingsSounds,
                    onChanged: (value) {
                      Haptics.tap();
                      ref.read(soundsEnabledProvider.notifier).set(value);
                    },
                  ),
                  PixelSwitchTile(
                    value: vibration,
                    title: l10n.settingsVibration,
                    onChanged: (value) {
                      ref.read(vibrationEnabledProvider.notifier).set(value);
                      // Отклик даём уже после включения — иначе включение
                      // вибрации ощущалось бы «немым».
                      if (value) Haptics.success();
                    },
                  ),
                  if (vibration) ...[
                    AppSpacing.gapSm,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.settingsVibrationIntensity,
                        style: context.text.label,
                      ),
                    ),
                    Slider(
                      value: intensity,
                      min: 0.2,
                      divisions: 8,
                      label: '${(intensity * 100).round()}%',
                      onChanged: (value) => ref
                          .read(vibrationIntensityProvider.notifier)
                          .set(value),
                      // Пробный импульс даём в конце жеста, а не на каждом
                      // микродвижении ползунка.
                      onChangeEnd: (_) => Haptics.moodGood(),
                    ),
                  ],
                ],
              ),
            ),
            AppSpacing.gapXl,
            PixelSectionHeader(title: l10n.settingsLanguage),
            PixelCard(
              // null здесь — не «ничего не выбрано», а осмысленное значение
              // «следовать системному языку».
              // Список полный: «системный» плюс все четыре языка из
              // supportedLocales, включая English.
              child: Column(
                children: [
                  for (final code in <String?>[
                    null,
                    for (final supported in supportedLocales)
                      supported.languageCode,
                  ])
                    PixelRadioTile<String?>(
                      value: code,
                      groupValue: locale?.languageCode,
                      title: code == null
                          ? l10n.settingsLanguageSystem
                          : (_languageNames[code] ?? code),
                      onChanged: (value) => ref
                          .read(localeProvider.notifier)
                          .set(value == null ? null : Locale(value)),
                    ),
                ],
              ),
            ),
            AppSpacing.gapXl,
            PixelSectionHeader(title: l10n.settingsNotifications),
            PixelCard(
              child: Column(
                children: [
                  PixelSwitchTile(
                    value: notifications,
                    title: l10n.settingsNotificationsEnabled,
                    onChanged: (value) async {
                      Haptics.tap();
                      await ref
                          .read(notificationsEnabledProvider.notifier)
                          .set(value);
                      if (value) {
                        await ref
                            .read(notificationServiceProvider)
                            .requestPermission();
                      }
                      await syncNotifications(ref, l10n);
                    },
                  ),
                  PixelOptionTile(
                    enabled: notifications,
                    leading: PixelSprite(
                      rows: PixelSprites.bell,
                      size: 20,
                      color: notifications
                          ? context.colors.accent
                          : context.colors.textTertiary,
                    ),
                    title: l10n.settingsDailyReminderTime,
                    trailing: Text(
                      DurationFormat.timeOfDay(summaryTime),
                      style: context.text.counterMedium,
                    ),
                    onTap: () => _pickSummaryTime(context, ref),
                  ),
                ],
              ),
            ),
            AppSpacing.gapXl,
            PixelSectionHeader(title: l10n.settingsData),
            PixelCard(
              child: PixelOptionTile(
                leading: PixelSprite(
                  rows: PixelSprites.download,
                  size: 20,
                  color: context.colors.accent,
                ),
                title: l10n.settingsExport,
                onTap: () => _export(context, ref),
              ),
            ),
            AppSpacing.gapXl,
            PixelSectionHeader(title: l10n.settingsAbout),
            PixelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppInfo.name, style: context.text.sectionTitle),
                  AppSpacing.gapSm,
                  Text(
                    l10n.settingsVersion(AppInfo.version),
                    style: context.text.caption,
                  ),
                  AppSpacing.gapSm,
                  Text(l10n.settingsAboutBody, style: context.text.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
