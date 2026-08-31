import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../core/utils/duration_format.dart';
import '../../domain/entities/habit_entity.dart';
import '../mood_checkin/mood_checkin_screen.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import 'home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final habits = ref.watch(todayHabitsProvider);

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.homeTitle),
        ),
        body: ListView(
          padding: AppSpacing.screen,
          children: [
            const _StreakAndFocusRow(),
            AppSpacing.gapXl,
            PixelButton(
              label: l10n.homeStartFocus,
              icon: Icons.play_arrow_rounded,
              onPressed: () {
                Navigator.of(context)
                    .push(pixelDissolveRoute<void>(const MoodCheckinScreen()));
              },
            ),
            AppSpacing.gapXl,
            PixelSectionHeader(title: l10n.homeTodayHabits),
            habits.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) =>
                  PixelCard(child: Text('$error', style: context.text.body)),
              data: (items) => _HabitsList(items: items),
            ),
          ],
        ),
      ),
    );
  }
}

/// Верхний блок: стрик слева, время в фокусе справа. Оба значения —
/// пиксельным шрифтом с табличными цифрами, чтобы не «дёргались».
class _StreakAndFocusRow extends ConsumerWidget {
  const _StreakAndFocusRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final streak = ref.watch(overallStreakProvider);
    final today = ref.watch(focusSecondsTodayProvider);
    final week = ref.watch(focusSecondsWeekProvider);

    // IntrinsicHeight, а не CrossAxisAlignment.stretch: строка живёт внутри
    // ListView, где высота не ограничена, и stretch запросил бы бесконечную.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PixelCard(
              accent: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.homeStreakLabel, style: context.text.caption),
                  AppSpacing.gapSm,
                  Text(
                    l10n.homeStreakValue(streak.valueOrNull ?? 0),
                    style: context.text.counterLarge.copyWith(
                      color: colors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.wGapMd,
          Expanded(
            child: PixelCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.homeSummaryTitle, style: context.text.caption),
                  AppSpacing.gapSm,
                  Text(
                    DurationFormat.compactFromSeconds(today.valueOrNull ?? 0),
                    style: context.text.counterLarge,
                  ),
                  AppSpacing.gapXs,
                  Text(
                    '${l10n.homeFocusWeek}: '
                    '${DurationFormat.compactFromSeconds(week.valueOrNull ?? 0)}',
                    style: context.text.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitsList extends ConsumerWidget {
  const _HabitsList({required this.items});

  final List<HabitWithStatus> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    if (items.isEmpty) {
      return PixelCard(
        child: Text(l10n.homeHabitsEmpty, style: context.text.body),
      );
    }

    final done = items.where((h) => h.doneToday).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _HabitTile(item: items[i])
                .animate()
                .fadeIn(duration: AppMotion.fast, delay: AppMotion.stagger * i)
                .slideY(begin: 0.08, end: 0, duration: AppMotion.fast),
          ),
        AppSpacing.gapSm,
        Text(
          done == items.length
              ? l10n.homeAllDone
              : l10n.homePending(items.length - done, items.length),
          style: context.text.caption,
        ),
      ],
    );
  }
}

class _HabitTile extends ConsumerWidget {
  const _HabitTile({required this.item});

  final HabitWithStatus item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = context.l10n;
    final toggle = ref.watch(toggleHabitProvider);

    return PixelCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      borderColor: item.doneToday ? colors.success : colors.divider,
      onTap: () {
        if (!item.doneToday) {
          Haptics.success();
        } else {
          Haptics.tap();
        }
        toggle(item.habit.id, !item.doneToday);
      },
      child: Row(
        children: [
          // Квадратный пиксельный чекбокс вместо материального: у него
          // нет скруглений и анимации «чернил».
          _PixelCheckbox(checked: item.doneToday),
          AppSpacing.wGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.habit.name,
                  style: context.text.title.copyWith(
                    decoration: item.doneToday
                        ? TextDecoration.lineThrough
                        : null,
                    color: item.doneToday
                        ? colors.textSecondary
                        : colors.textPrimary,
                  ),
                ),
                if (item.streak > 0) ...[
                  AppSpacing.gapXs,
                  Text(
                    l10n.habitStreakLabel(item.streak),
                    style: context.text.caption,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PixelCheckbox extends StatelessWidget {
  const _PixelCheckbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: AppMotion.fast,
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: checked ? colors.success : Colors.transparent,
        border: Border.all(
          color: checked ? colors.success : colors.divider,
          width: AppRadius.pixelBorder,
        ),
      ),
      child: checked
          ? Icon(Icons.check, size: 18, color: colors.onAccent)
          : null,
    );
  }
}
