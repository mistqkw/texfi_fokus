import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../core/utils/duration_format.dart';
import '../../domain/entities/habit_entity.dart';
import '../shared/notification_sync.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_shadow.dart';
import 'habits_providers.dart';

const _uuid = Uuid();

/// Создание и правка привычки. Шаг с «наказанием» обязателен: именно он
/// отличает эту привычку от обычного списка дел — пользователь заранее
/// договаривается с собой о цене пропуска.
class HabitEditScreen extends ConsumerStatefulWidget {
  const HabitEditScreen({super.key, this.habit});

  final HabitEntity? habit;

  bool get isNew => habit == null;

  @override
  ConsumerState<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends ConsumerState<HabitEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.habit?.name ?? '');
  late final TextEditingController _punishmentController =
      TextEditingController(text: widget.habit?.punishment ?? '');

  late int _weekdayMask = widget.habit?.weekdayMask ?? HabitEntity.everyDayMask;
  late int? _reminderMinutes = widget.habit?.reminderMinutes;

  @override
  void dispose() {
    _nameController.dispose();
    _punishmentController.dispose();
    super.dispose();
  }

  void _toggleWeekday(int weekday) {
    final bit = 1 << (weekday - 1);
    final next = _weekdayMask ^ bit;
    // Привычка без единого дня недели никогда не сработает — не даём
    // снять последний день.
    if (next == 0) {
      Haptics.warning();
      return;
    }
    Haptics.tap();
    setState(() => _weekdayMask = next);
  }

  Future<void> _pickReminderTime() async {
    final initial = _reminderMinutes ?? 20 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    if (picked == null) return;
    setState(() => _reminderMinutes = picked.hour * 60 + picked.minute);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      Haptics.warning();
      return;
    }

    final l10n = context.l10n;
    final existing = widget.habit;
    final habit = HabitEntity(
      id: existing?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      punishment: _punishmentController.text.trim(),
      weekdayMask: _weekdayMask,
      reminderMinutes: _reminderMinutes,
      createdAt: existing?.createdAt ?? DateTime.now(),
      sortOrder: existing?.sortOrder ?? 0,
    );

    await ref.read(saveHabitProvider)(habit, isNew: widget.isNew);
    await syncNotifications(ref, l10n);
    if (!mounted) return;
    Haptics.success();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final weekdayLabels = l10n.habitDaysShort.split(' ');

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.isNew ? l10n.habitsAdd : l10n.habitEditTitle),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.habitNameLabel,
                  hintText: l10n.habitNameHint,
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? l10n.habitNameRequired
                    : null,
              ),
              AppSpacing.gapXl,
              PixelSectionHeader(title: l10n.habitFrequency),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var weekday = 1; weekday <= 7; weekday++)
                    _WeekdayToggle(
                      label: weekdayLabels.length >= weekday
                          ? weekdayLabels[weekday - 1]
                          : '$weekday',
                      selected: _weekdayMask & (1 << (weekday - 1)) != 0,
                      onTap: () => _toggleWeekday(weekday),
                    ),
                ],
              ),
              AppSpacing.gapXl,
              PixelSectionHeader(title: l10n.habitPunishmentLabel),
              TextFormField(
                controller: _punishmentController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: l10n.habitPunishmentHint,
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? l10n.habitPunishmentRequired
                    : null,
              ),
              AppSpacing.gapSm,
              Text(l10n.habitPunishmentExplainer, style: context.text.caption),
              AppSpacing.gapXl,
              PixelCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.habitReminderTime,
                        style: context.text.title,
                      ),
                    ),
                    TextButton(
                      onPressed: _pickReminderTime,
                      child: Text(
                        _reminderMinutes == null
                            ? l10n.habitReminderOff
                            : DurationFormat.timeOfDay(_reminderMinutes!),
                      ),
                    ),
                    if (_reminderMinutes != null)
                      IconButton(
                        tooltip: l10n.habitReminderOff,
                        icon: Icon(Icons.close, color: colors.textTertiary),
                        onPressed: () =>
                            setState(() => _reminderMinutes = null),
                      ),
                  ],
                ),
              ),
              AppSpacing.gapXxl,
              PixelButton(label: l10n.commonSave, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayToggle extends StatelessWidget {
  const _WeekdayToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      // Выбранный день утоплен в подложку, невыбранный стоит на тени —
      // состояние читается и без цвета.
      child: PixelShadowBox(
        shadowColor: colors.divider,
        borderRadius: AppRadius.controlNoneAll,
        pressed: selected,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? colors.accent.withValues(alpha: 0.2)
                : colors.surfaceVariant,
            border: Border.all(
              color: selected ? colors.accent : colors.divider,
              width: AppRadius.pixelBorder,
            ),
          ),
          child: Text(
            label,
            style: context.text.chartLabel.copyWith(
              color: selected ? colors.accent : colors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
