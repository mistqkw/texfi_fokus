import 'dart:math' as math;

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
import '../../domain/entities/insight.dart';
import '../mood_checkin/mood_checkin_screen.dart';
import '../planner/day_plan_screen.dart';
import '../shared/enum_labels.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_radio.dart';
import '../shared/pixel_sprite.dart';
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
            const _InsightCard(),
            AppSpacing.gapXl,
            PixelButton(
              label: l10n.homeStartFocus,
              sprite: PixelSprites.play,
              onPressed: () {
                Navigator.of(context)
                    .push(pixelDissolveRoute<void>(const MoodCheckinScreen()));
              },
            ),
            AppSpacing.gapMd,
            PixelButton(
              label: l10n.homePlanDay,
              primary: false,
              sprite: PixelSprites.sliders,
              onPressed: () {
                Haptics.tap();
                Navigator.of(context)
                    .push(pixelDissolveRoute<void>(const DayPlanScreen()));
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
                  AppSpacing.gapXs,
                  // Стрик считается по привычкам, а не по сессиям: без этой
                  // подписи «Стрик: 1 д» рядом с «В фокусе: 0m» читается
                  // как расхождение в данных.
                  Text(l10n.homeStreakBasis, style: context.text.caption),
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

/// Одно наблюдение о том, как человек работает, — на основе его же истории.
///
/// Это видимая отдача от всего, что движок насчитал внутри: без неё
/// «адаптивность» остаётся словом из описания в сторе. Карточки нет, пока
/// данных не хватает на честное утверждение, — приветственная заглушка
/// вроде «скоро тут что-то появится» занимала бы место и не сообщала ничего.
class _InsightCard extends ConsumerWidget {
  const _InsightCard();

  String _text(BuildContext context, Insight insight) {
    final l10n = context.l10n;
    return switch (insight.kind) {
      InsightKind.bestMood => l10n.insightBestMood(
          insight.mood!.label(l10n),
          insight.percent,
        ),
      InsightKind.bestWeekday => l10n.insightBestWeekday(
          weekdayShortLabel(l10n, insight.weekday!),
          insight.minutes,
        ),
      InsightKind.bestTimeOfDay => l10n.insightBestTime(
          insight.timeOfDay!.label(l10n),
          insight.percent,
        ),
      InsightKind.bestTechnique => l10n.insightBestTechnique(
          insight.technique!.label(l10n),
          insight.percent,
        ),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final insight = ref.watch(homeInsightProvider).valueOrNull;
    if (insight == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: PixelCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PixelSprite(
                  rows: PixelSprites.insight,
                  size: 14,
                  color: colors.accent,
                ),
                AppSpacing.wGapSm,
                Text(
                  l10n.insightTitle,
                  style: context.text.chartLabel.copyWith(color: colors.accent),
                ),
              ],
            ),
            AppSpacing.gapSm,
            Text(_text(context, insight), style: context.text.body),
            AppSpacing.gapXs,
            Text(
              l10n.insightBasis(insight.sampleSize),
              style: context.text.caption,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: AppMotion.normal)
        .slideY(begin: 0.06, end: 0, duration: AppMotion.normal);
  }
}

class _HabitsList extends ConsumerStatefulWidget {
  const _HabitsList({required this.items});

  final List<HabitWithStatus> items;

  @override
  ConsumerState<_HabitsList> createState() => _HabitsListState();
}

class _HabitsListState extends ConsumerState<_HabitsList>
    with SingleTickerProviderStateMixin {
  /// Вспышка на закрытие последней привычки за день.
  ///
  /// Фраза «Все цели на сегодня закрыты» и до этого появлялась в нужный
  /// момент — но появлялась молча, ниже последней карточки, куда в момент
  /// нажатия никто не смотрит. Вспышка не сообщает ничего нового: она только
  /// переводит взгляд туда, где ответ уже написан.
  ///
  /// Отбивается ровно переход «оставалась одна → не осталось ни одной».
  /// На экране, открытом с уже закрытым днём, ничего не мигает: это был бы
  /// не отклик на действие, а приветствие.
  late final AnimationController _allDone = AnimationController(
    vsync: this,
    duration: AppMotion.flourish,
  );

  static int _doneCount(List<HabitWithStatus> items) =>
      items.where((h) => h.doneToday).length;

  bool _complete(List<HabitWithStatus> items) =>
      items.isNotEmpty && _doneCount(items) == items.length;

  @override
  void didUpdateWidget(_HabitsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_complete(oldWidget.items) && _complete(widget.items)) {
      _allDone.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _allDone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final items = widget.items;

    if (items.isEmpty) {
      return PixelCard(
        child: Text(l10n.homeHabitsEmpty, style: context.text.body),
      );
    }

    final done = _doneCount(items);

    return AnimatedBuilder(
      animation: _allDone,
      builder: (context, child) {
        // Два коротких удара вместо одного длинного затухания: ровная
        // синусоида читалась бы как подсветка, а пара вспышек — как отбивка.
        final t = _allDone.value;
        final punch = t == 0 || t == 1 ? 0.0 : math.sin(t * math.pi * 2).abs();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.success.withValues(alpha: punch),
              width: AppRadius.pixelBorder,
            ),
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _HabitTile(item: items[i])
                  .animate()
                  .fadeIn(
                    duration: AppMotion.fast,
                    delay: AppMotion.stagger * i,
                  )
                  .slideY(begin: 0.08, end: 0, duration: AppMotion.fast),
            ),
          AppSpacing.gapSm,
          Text(
            done == items.length
                ? l10n.homeAllDone
                : l10n.homePending(items.length - done, items.length),
            style: context.text.caption.copyWith(
              color: done == items.length ? colors.success : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitTile extends ConsumerStatefulWidget {
  const _HabitTile({required this.item});

  final HabitWithStatus item;

  @override
  ConsumerState<_HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends ConsumerState<_HabitTile> {
  /// Заморозка прячется за долгим нажатием и раскрывается по тапу на
  /// подпись: это редкое действие, и постоянная кнопка рядом с чекбоксом
  /// приглашала бы ею пользоваться.
  bool _showFreeze = false;

  Future<void> _toggleFreeze() async {
    final item = widget.item;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final ok = await ref.read(toggleFreezeProvider)(
      item.habit.id,
      !item.frozenToday,
    );
    if (!mounted) return;

    if (!ok && !item.frozenToday) {
      Haptics.warning();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.habitFreezeUnavailable)),
      );
      return;
    }
    Haptics.success();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final item = widget.item;
    final toggle = ref.watch(toggleHabitProvider);
    final habit = item.habit;

    final borderColor = item.frozenToday
        ? colors.warning
        : (item.doneToday ? colors.success : colors.divider);

    return PixelCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      borderColor: borderColor,
      onTap: () {
        if (item.frozenToday) {
          // Замороженный день не отмечают — сначала снимают заморозку.
          Haptics.warning();
          setState(() => _showFreeze = true);
          return;
        }
        if (!item.doneToday) {
          Haptics.success();
        } else {
          Haptics.tap();
        }
        toggle(habit.id, !item.doneToday);
      },
      onLongPress: habit.freezeEnabled
          ? () {
              Haptics.tap();
              setState(() => _showFreeze = !_showFreeze);
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Квадратный пиксельный чекбокс вместо материального: ни
              // скруглений, ни анимации «чернил», а галочка — спрайт.
              PixelCheckIndicator(
                checked: item.doneToday,
                color: item.frozenToday ? colors.warning : null,
              ),
              AppSpacing.wGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
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
                        habit.frequency == HabitFrequencyType.timesPerWeek
                            ? l10n.habitStreakWeeks(item.streak)
                            : l10n.habitStreakLabel(item.streak),
                        style: context.text.caption,
                      ),
                    ],
                    if (habit.frequency ==
                        HabitFrequencyType.timesPerWeek) ...[
                      AppSpacing.gapXs,
                      Text(
                        l10n.habitWeekProgress(
                          item.doneThisWeek,
                          habit.timesPerWeek,
                        ),
                        style: context.text.caption.copyWith(
                          color: item.weeklyQuotaMet
                              ? colors.success
                              : colors.textTertiary,
                        ),
                      ),
                    ],
                    if (item.frozenToday) ...[
                      AppSpacing.gapXs,
                      Text(
                        l10n.habitFrozenToday,
                        style: context.text.caption.copyWith(
                          color: colors.warning,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Награда показывается ровно тогда, когда заслужена: висящая
          // всё время, она превратилась бы в обещание, а не в событие.
          if (item.rewardEarned) ...[
            AppSpacing.gapMd,
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
                    l10n.habitRewardEarned(item.streak),
                    style: context.text.chartLabel.copyWith(
                      color: colors.success,
                    ),
                  ),
                  AppSpacing.gapXs,
                  Text(habit.reward!, style: context.text.body),
                ],
              ),
            ),
          ],

          if (_showFreeze && habit.freezeEnabled) ...[
            AppSpacing.gapMd,
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.frozenToday
                        ? l10n.habitFreezeUndoHint
                        : (item.freezeAvailable
                            ? l10n.habitFreezeHint
                            : l10n.habitFreezeUnavailable),
                    style: context.text.caption,
                  ),
                ),
                AppSpacing.wGapMd,
                PixelButton(
                  label: item.frozenToday
                      ? l10n.habitFreezeUndo
                      : l10n.habitFreezeToday,
                  primary: false,
                  expand: false,
                  onPressed: item.frozenToday || item.freezeAvailable
                      ? _toggleFreeze
                      : null,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
