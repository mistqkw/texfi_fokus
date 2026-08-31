import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../core/utils/duration_format.dart';
import '../../domain/entities/habit_entity.dart';
import '../shared/notification_sync.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_card.dart';
import 'habit_edit_screen.dart';
import 'habits_providers.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    HabitEntity habit,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.habitDeleteConfirmTitle),
        content: Text(l10n.habitDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    Haptics.warning();
    await ref.read(deleteHabitProvider)(habit.id);
    await syncNotifications(ref, l10n);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final habits = ref.watch(allHabitsProvider);

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.habitsTitle),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Haptics.tap();
            Navigator.of(context).push(
              pixelDissolveRoute<void>(const HabitEditScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: habits.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Padding(
            padding: AppSpacing.screen,
            child: Text('$error', style: context.text.body),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: AppSpacing.screen,
                child: PixelCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.habitsEmpty, style: context.text.title),
                      AppSpacing.gapSm,
                      Text(l10n.habitsEmptyHint, style: context.text.body),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: AppSpacing.screenWithFab,
              itemCount: items.length,
              separatorBuilder: (_, _) => AppSpacing.gapMd,
              itemBuilder: (context, index) => _HabitCard(
                habit: items[index],
                onEdit: () {
                  Haptics.tap();
                  Navigator.of(context).push(
                    pixelDissolveRoute<void>(
                      HabitEditScreen(habit: items[index]),
                    ),
                  );
                },
                onDelete: () => _confirmDelete(context, ref, items[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.onEdit,
    required this.onDelete,
  });

  final HabitEntity habit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _frequencyLabel(BuildContext context) {
    final l10n = context.l10n;
    if (habit.isDaily) return l10n.habitDaily;
    final labels = l10n.habitDaysShort.split(' ');
    final days = <String>[
      for (var weekday = 1; weekday <= 7; weekday++)
        if (habit.isScheduledOnWeekday(weekday) && labels.length >= weekday)
          labels[weekday - 1],
    ];
    return days.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return PixelCard(
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(habit.name, style: context.text.title),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colors.textTertiary),
                onPressed: onDelete,
              ),
            ],
          ),
          AppSpacing.gapSm,
          Row(
            children: [
              Icon(Icons.repeat, size: 14, color: colors.textTertiary),
              AppSpacing.wGapXs,
              Expanded(
                child: Text(
                  _frequencyLabel(context),
                  style: context.text.caption,
                ),
              ),
              if (habit.reminderMinutes != null) ...[
                Icon(
                  Icons.notifications_none,
                  size: 14,
                  color: colors.textTertiary,
                ),
                AppSpacing.wGapXs,
                Text(
                  DurationFormat.timeOfDay(habit.reminderMinutes!),
                  style: context.text.caption,
                ),
              ],
            ],
          ),
          AppSpacing.gapMd,
          // «Наказание» показываем прямо в карточке: договорённость с собой
          // работает, только пока она на виду.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              border: Border(
                left: BorderSide(color: colors.warning, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.habitPunishmentLabel,
                  style: context.text.chartLabel,
                ),
                AppSpacing.gapXs,
                Text(habit.punishment, style: context.text.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
