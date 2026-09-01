import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/alarm_sound.dart';
import '../../core/constants/app_info.dart';
import '../../core/haptics/haptics.dart';
import '../../core/theme/app_accent.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../core/utils/duration_format.dart';
import '../../data/providers/data_providers.dart';
import '../game/character_screen.dart';
import '../game/game_providers.dart';
import '../game/game_sprites.dart';
import '../shared/notification_sync.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_radio.dart';
import '../shared/pixel_sprite.dart';
import 'alarm_sound_labels.dart';
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

  /// Порог короткого перерыва перебирается по кругу тапом, без отдельного
  /// экрана: значений всего четыре, и «выключено» среди них.
  static const List<int> _shortBreakSteps = [0, 3, 5, 10, 15];

  Future<void> _cycleShortBreak(WidgetRef ref) async {
    final current = ref.read(shortBreakMinutesProvider);
    final index = _shortBreakSteps.indexOf(current);
    final next = _shortBreakSteps[(index + 1) % _shortBreakSteps.length];
    Haptics.tap();
    await ref.read(shortBreakMinutesProvider.notifier).set(next);
  }

  Future<void> _pickNightCapHour(BuildContext context, WidgetRef ref) async {
    final current = ref.read(nightCapHourProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current, minute: 0),
    );
    if (picked == null) return;
    await ref.read(nightCapHourProvider.notifier).set(picked.hour);
  }

  /// Импорт выгрузки. Два вопроса подряд — какой файл и что делать с тем,
  /// что уже есть, — потому что «заменить» здесь означает стереть чужую
  /// историю без возможности отката.
  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final path = await showDialog<String>(
      context: context,
      builder: (context) => const _ImportPathDialog(),
    );
    if (path == null || path.trim().isEmpty || !context.mounted) return;

    final file = File(path.trim());
    if (!file.existsSync()) {
      Haptics.warning();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsImportNoFile)),
      );
      return;
    }

    final merge = await showDialog<bool>(
      context: context,
      builder: (context) => const _ImportModeDialog(),
    );
    if (merge == null || !context.mounted) return;

    try {
      final result = await ref
          .read(exportServiceProvider)
          .importFromFile(file, merge: merge);
      Haptics.success();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.settingsImportDone(
              result.habits,
              result.tasks,
              result.sessions,
            ),
          ),
        ),
      );
    } catch (error) {
      Haptics.warning();
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.settingsImportFailed}: $error')),
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
    final accent = ref.watch(accentProvider);
    final locale = ref.watch(localeProvider);
    final sounds = ref.watch(soundsEnabledProvider);
    final alarmSound = ref.watch(alarmSoundProvider);
    final vibration = ref.watch(vibrationEnabledProvider);
    final intensity = ref.watch(vibrationIntensityProvider);
    final notifications = ref.watch(notificationsEnabledProvider);
    final summaryTime = ref.watch(dailySummaryTimeProvider);
    final shortBreak = ref.watch(shortBreakMinutesProvider);
    final nightCap = ref.watch(nightCapEnabledProvider);
    final nightCapHour = ref.watch(nightCapHourProvider);

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
            AppSpacing.gapMd,
            PixelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.settingsAccent, style: context.text.title),
                  AppSpacing.gapSm,
                  Text(l10n.settingsAccentSubtitle, style: context.text.caption),
                  AppSpacing.gapMd,
                  Row(
                    children: [
                      for (final option in AppAccent.values)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: _AccentSwatch(
                            accent: option,
                            selected: option == accent,
                            onTap: () {
                              Haptics.tap();
                              ref.read(accentProvider.notifier).set(option);
                            },
                          ),
                        ),
                    ],
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
                  // Выбор сигнала показываем только при включённом звуке:
                  // перебирать пресеты, которые всё равно не прозвучат в
                  // конце сессии, — предложение ни о чём.
                  if (sounds) ...[
                    AppSpacing.gapSm,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.settingsAlarmSound,
                        style: context.text.label,
                      ),
                    ),
                    for (final sound in AlarmSound.values)
                      PixelRadioTile<AlarmSound>(
                        title: alarmSoundLabel(l10n, sound),
                        value: sound,
                        groupValue: alarmSound,
                        onChanged: (value) {
                          Haptics.tap();
                          ref.read(alarmSoundProvider.notifier).set(value);
                          // Прослушивание — часть выбора: человек должен
                          // услышать пресет в тот же момент, когда его
                          // выбрал, а не только в конце сессии.
                          ref
                              .read(alarmSoundPlayerProvider)
                              .preview(value);
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        l10n.settingsAlarmSoundHint,
                        style: context.text.caption,
                      ),
                    ),
                  ],
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
            const _GameModeSection(),
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
            PixelSectionHeader(title: l10n.settingsBurnout),
            PixelCard(
              child: Column(
                children: [
                  PixelOptionTile(
                    leading: PixelSprite(
                      rows: PixelSprites.hourglass,
                      size: 20,
                      color: context.colors.accent,
                    ),
                    title: l10n.settingsShortBreakWarning,
                    subtitle: shortBreak == 0
                        ? l10n.settingsShortBreakOff
                        : l10n.settingsShortBreakSubtitle(shortBreak),
                    trailing: Text(
                      shortBreak == 0 ? '—' : '$shortBreak',
                      style: context.text.counterMedium,
                    ),
                    onTap: () => _cycleShortBreak(ref),
                  ),
                  PixelSwitchTile(
                    value: nightCap,
                    title: l10n.settingsNightCap,
                    subtitle: l10n.settingsNightCapSubtitle,
                    onChanged: (value) {
                      Haptics.tap();
                      ref.read(nightCapEnabledProvider.notifier).set(value);
                    },
                  ),
                  PixelOptionTile(
                    enabled: nightCap,
                    leading: PixelSprite(
                      rows: PixelSprites.moodFace,
                      size: 20,
                      color: nightCap
                          ? context.colors.accent
                          : context.colors.textTertiary,
                    ),
                    title: l10n.settingsNightCapHour,
                    trailing: Text(
                      DurationFormat.timeOfDay(nightCapHour * 60),
                      style: context.text.counterMedium,
                    ),
                    onTap: () => _pickNightCapHour(context, ref),
                  ),
                ],
              ),
            ),
            AppSpacing.gapXl,
            PixelSectionHeader(title: l10n.settingsData),
            PixelCard(
              child: Column(
                children: [
                  PixelOptionTile(
                    leading: PixelSprite(
                      rows: PixelSprites.download,
                      size: 20,
                      color: context.colors.accent,
                    ),
                    title: l10n.settingsExport,
                    onTap: () => _export(context, ref),
                  ),
                  PixelOptionTile(
                    leading: PixelSprite(
                      rows: PixelSprites.upload,
                      size: 20,
                      color: context.colors.accent,
                    ),
                    title: l10n.settingsImport,
                    subtitle: l10n.settingsImportSubtitle,
                    onTap: () => _import(context, ref),
                  ),
                ],
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

/// Квадратик акцентного цвета. Выбранный обведён рамкой цвета текста —
/// собственным цветом его было бы не отличить от невыбранного.
class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final AppAccent accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.color,
          border: Border.all(
            color: selected ? colors.textPrimary : colors.divider,
            width: AppRadius.pixelBorder,
          ),
        ),
        child: selected
            ? PixelSprite(
                rows: PixelSprites.check,
                size: 16,
                color: colors.background,
              )
            : null,
      ),
    );
  }
}

/// Путь к файлу вводится руками: системный файловый диалог потянул бы ещё
/// один плагин ради одной кнопки, а путь выгрузки приложение и так
/// показывает после экспорта.
class _ImportPathDialog extends StatefulWidget {
  const _ImportPathDialog();

  @override
  State<_ImportPathDialog> createState() => _ImportPathDialogState();
}

class _ImportPathDialogState extends State<_ImportPathDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(AppSpacing.page),
      child: PixelCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.settingsImport, style: context.text.sectionTitle),
            AppSpacing.gapMd,
            Text(l10n.settingsImportPathHint, style: context.text.body),
            AppSpacing.gapMd,
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: '/home/…/backup.json'),
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
            AppSpacing.gapXl,
            PixelButton(
              label: l10n.commonNext,
              onPressed: () => Navigator.of(context).pop(_controller.text),
            ),
            AppSpacing.gapMd,
            PixelButton(
              label: l10n.commonCancel,
              primary: false,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Слияние или замена. Замена подписана прямо: «сотрёт всё, что есть» —
/// на этом экране эвфемизм стоил бы кому-то всей истории.
class _ImportModeDialog extends StatelessWidget {
  const _ImportModeDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(AppSpacing.page),
      child: PixelCard(
        borderColor: colors.warning,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsImportWarnTitle,
              style: context.text.sectionTitle.copyWith(color: colors.warning),
            ),
            AppSpacing.gapMd,
            Text(l10n.settingsImportWarnBody, style: context.text.body),
            AppSpacing.gapXl,
            PixelButton(
              label: l10n.settingsImportMerge,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            AppSpacing.gapMd,
            PixelButton(
              label: l10n.settingsImportReplace,
              danger: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            AppSpacing.gapMd,
            PixelButton(
              label: l10n.commonCancel,
              primary: false,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}


/// Переключатель игрового режима.
///
/// Вынесен в отдельный виджет, а не вписан в общий список: он единственный
/// в настройках, кто подписан на БД, и перестраивать из-за него весь экран
/// на каждое изменение опыта было бы расточительно.
class _GameModeSection extends ConsumerWidget {
  const _GameModeSection();

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.gameReset),
        content: Text(l10n.gameResetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.gameReset),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(gameRepositoryProvider).resetProgress();
    Haptics.warning();
    messenger.showSnackBar(SnackBar(content: Text(l10n.gameResetDone)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final enabled = ref.watch(gameModeOnProvider);
    final progress = ref.watch(playerProgressProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PixelSectionHeader(title: l10n.gameSectionTitle),
        PixelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PixelSwitchTile(
                value: enabled,
                title: l10n.gameModeToggle,
                subtitle: l10n.gameModeSubtitle,
                onChanged: (value) async {
                  Haptics.tap();
                  await ref.read(gameRepositoryProvider).setEnabled(value);
                },
              ),

              // Обещание «данные не пропадут» стоит написать прямо, а не
              // оставлять пользователю проверять его выключением.
              AppSpacing.gapSm,
              Text(
                l10n.gameModeOffNote,
                style: context.text.caption.copyWith(
                  color: colors.textTertiary,
                ),
              ),

              if (enabled) ...[
                AppSpacing.gapMd,
                PixelOptionTile(
                  leading: PixelSprite(
                    rows: GameSprites.avatarFlame,
                    size: 20,
                    color: colors.accent,
                  ),
                  title: l10n.characterTitle,
                  subtitle: progress == null
                      ? null
                      : l10n.characterLevel(progress.level),
                  onTap: () {
                    Haptics.tap();
                    Navigator.of(context).push(
                      pixelDissolveRoute<void>(const CharacterScreen()),
                    );
                  },
                ),
                PixelOptionTile(
                  leading: PixelSprite(
                    rows: GameSprites.nodeCleared,
                    size: 20,
                    color: colors.danger,
                  ),
                  title: l10n.gameReset,
                  subtitle: l10n.gameResetSubtitle,
                  onTap: () => _confirmReset(context, ref),
                ),
              ],
            ],
          ),
        ),
        AppSpacing.gapXl,
      ],
    );
  }
}
