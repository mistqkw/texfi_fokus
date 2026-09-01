import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../core/utils/duration_format.dart';
import '../../domain/entities/habit_entity.dart';
import '../shared/notification_sync.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_spinner.dart';
import '../shared/pixel_sprite.dart';
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
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.controlSmallAll,
          ),
          child: PixelSprite(
            rows: PixelSprites.plus,
            size: 20,
            color: context.colors.onAccent,
          ),
        ),
        body: habits.when(
          loading: () => const Center(child: PixelSpinner()),
          // Текст исключения пользователю ничего не говорит и читается как
          // поломка. Дампы остаются логам.
          error: (_, _) => Padding(
            padding: AppSpacing.screen,
            child: Text(l10n.commonLoadError, style: context.text.body),
          ),
          data: (items) {
            if (items.isEmpty) {
              // ListView, а не Padding: под жёсткими ограничениями экрана
              // карточка растягивалась во всю высоту и висела пустой
              // плашкой до самого таббара.
              return ListView(
                padding: AppSpacing.screen,
                children: [
                  PixelCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.habitsEmpty, style: context.text.title),
                        AppSpacing.gapSm,
                        Text(l10n.habitsEmptyHint, style: context.text.body),
                      ],
                    ),
                  ),
                ],
              );
            }

            // Поле поиска появляется только на длинном списке: на пяти
            // привычках оно отняло бы высоту у самого списка, не дав ничего
            // взамен.
            final searchable = items.length >= habitSearchThreshold;
            final query = ref.watch(habitSearchQueryProvider);
            final shown = searchable ? filterHabits(items, query) : items;

            if (searchable && shown.isEmpty) {
              return ListView(
                padding: AppSpacing.screen,
                children: [
                  const _HabitSearchField(),
                  AppSpacing.gapMd,
                  PixelCard(
                    child: Text(
                      l10n.habitsSearchNothing,
                      style: context.text.body,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: AppSpacing.screenWithFab,
              itemCount: shown.length + (searchable ? 1 : 0),
              separatorBuilder: (_, _) => AppSpacing.gapMd,
              itemBuilder: (context, index) {
                if (searchable && index == 0) return const _HabitSearchField();
                final habit = shown[index - (searchable ? 1 : 0)];
                return _HabitCard(
                  habit: habit,
                  onEdit: () {
                    Haptics.tap();
                    Navigator.of(context).push(
                      pixelDissolveRoute<void>(HabitEditScreen(habit: habit)),
                    );
                  },
                  onDelete: () => _confirmDelete(context, ref, habit),
                );
              },
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
    if (habit.frequency == HabitFrequencyType.timesPerWeek) {
      return l10n.habitTimesPerWeekValue(habit.timesPerWeek);
    }
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
                icon: PixelSprite(
                rows: PixelSprites.trash,
                size: 16,
                color: colors.textTertiary,
              ),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          AppSpacing.gapSm,
          Row(
            children: [
              PixelSprite(
                rows: PixelSprites.repeat,
                size: 12,
                color: colors.textTertiary,
              ),
              AppSpacing.wGapXs,
              Expanded(
                child: Text(
                  _frequencyLabel(context),
                  style: context.text.caption,
                ),
              ),
              if (habit.reminderMinutes != null) ...[
                PixelSprite(
                  rows: PixelSprites.bell,
                  size: 12,
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
          // «Наказание» — вложенный блок, поэтому без собственной тени:
          // объём даёт карточка снаружи. Рамка — сплошная в 2px, цветом
          // предупреждения, а не одна полоска слева.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              border: Border.all(
                color: colors.warning,
                width: AppRadius.pixelBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.habitPunishmentLabel,
                  style: context.text.chartLabel.copyWith(
                    color: colors.warning,
                  ),
                ),
                AppSpacing.gapXs,
                // Договорённость с собой бывает длинной: она переносится
                // целиком, а не обрезается многоточием.
                Text(
                  habit.punishment,
                  style: context.text.body,
                  softWrap: true,
                ),
              ],
            ),
          ),
          // Награда — та же договорённость с собой, только с другой стороны.
          // Показываем её рядом с наказанием и тем же блоком: иначе кнут
          // выглядел бы единственным содержанием привычки.
          if (habit.hasReward) ...[
            AppSpacing.gapSm,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                border: Border.all(
                  color: colors.success,
                  width: AppRadius.pixelBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.habitRewardAfter(habit.rewardStreakDays),
                    style: context.text.chartLabel.copyWith(
                      color: colors.success,
                    ),
                  ),
                  AppSpacing.gapXs,
                  Text(habit.reward!, style: context.text.body, softWrap: true),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Поле фильтра над длинным списком привычек.
///
/// Собственный контроллер, а не чтение провайдера в `initialValue`: иначе
/// каждое нажатие клавиши перестраивало бы поле из состояния и роняло
/// позицию курсора.
class _HabitSearchField extends ConsumerStatefulWidget {
  const _HabitSearchField();

  @override
  ConsumerState<_HabitSearchField> createState() => _HabitSearchFieldState();
}

class _HabitSearchFieldState extends ConsumerState<_HabitSearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: ref.read(habitSearchQueryProvider));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final query = ref.watch(habitSearchQueryProvider);

    return PixelCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          PixelSprite(
            rows: PixelSprites.search,
            size: 16,
            color: colors.textTertiary,
          ),
          AppSpacing.wGapSm,
          Expanded(
            child: TextField(
              controller: _controller,
              style: context.text.body,
              decoration: InputDecoration(
                hintText: l10n.habitsSearchHint,
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) =>
                  ref.read(habitSearchQueryProvider.notifier).state = value,
            ),
          ),
          // Крестик только когда есть что стирать: пустое поле с кнопкой
          // очистки выглядит как неработающая кнопка.
          if (query.isNotEmpty)
            IconButton(
              icon: PixelSprite(
                rows: PixelSprites.close,
                size: 12,
                color: colors.textTertiary,
              ),
              onPressed: () {
                Haptics.tap();
                _controller.clear();
                ref.read(habitSearchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
    );
  }
}
