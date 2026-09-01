import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../core/utils/duration_format.dart';
import '../../domain/entities/statistics.dart';
import '../shared/enum_labels.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_heatmap.dart';
import '../shared/pixel_shadow.dart';
import 'statistics_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.statsTitle),
        ),
        body: ListView(
          padding: AppSpacing.screen,
          children: const [
            _RangeSelector(),
            AppSpacing.gapLg,
            _SummaryRow(),
            AppSpacing.gapXl,
            _ActivitySection(),
            AppSpacing.gapXl,
            _FocusByDaySection(),
            AppSpacing.gapXl,
            _MoodSection(),
            AppSpacing.gapXl,
            _CategorySection(),
            AppSpacing.gapXl,
            _HabitSuccessSection(),
          ],
        ),
      ),
    );
  }
}

class _RangeSelector extends ConsumerWidget {
  const _RangeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final selected = ref.watch(statsRangeProvider);

    return Row(
      children: [
        for (final range in StatsRange.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () {
                  Haptics.tap();
                  ref.read(statsRangeProvider.notifier).state = range;
                },
                // Выбранный период «утоплен»: тень есть только у
                // невыбранного, ровно как у нажатой пиксельной кнопки.
                child: PixelShadowBox(
                  shadowColor: colors.divider,
                  borderRadius: AppRadius.controlNoneAll,
                  pressed: range == selected,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: range == selected
                          ? colors.accent.withValues(alpha: 0.18)
                          : colors.surfaceVariant,
                      border: Border.all(
                        color: range == selected
                            ? colors.accent
                            : colors.divider,
                        width: AppRadius.pixelBorder,
                      ),
                    ),
                    child: Text(
                      range == StatsRange.week
                          ? l10n.statsWeek
                          : l10n.statsMonth,
                      style: context.text.pixelLabel.copyWith(
                        color: range == selected
                            ? colors.accent
                            : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryRow extends ConsumerWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summary =
        ref.watch(statsSummaryProvider).valueOrNull ?? FocusSummary.empty;

    // Внутри ListView высота не ограничена, поэтому равную высоту карточек
    // задаёт IntrinsicHeight, а не stretch.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PixelCard(
              accent: true,
              child: _Figure(
                value: DurationFormat.compactFromSeconds(
                  summary.totalFocusSeconds,
                ),
                caption: l10n.statsTotalFocus,
              ),
            ),
          ),
          AppSpacing.wGapSm,
          Expanded(
            child: PixelCard(
              child: _Figure(
                value: '${summary.sessionCount}',
                caption: l10n.statsSessions,
              ),
            ),
          ),
          AppSpacing.wGapSm,
          Expanded(
            child: PixelCard(
              child: _Figure(
                value: '${(summary.completionRate * 100).round()}%',
                caption: l10n.statsCompletionRate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.caption});

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: context.text.counterMedium),
        ),
        AppSpacing.gapXs,
        Text(caption, style: context.text.caption),
      ],
    );
  }
}

class _ActivitySection extends ConsumerWidget {
  const _ActivitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final days = ref.watch(heatmapDaysProvider).valueOrNull ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PixelSectionHeader(title: l10n.statsActivity),
        PixelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PixelHeatmap(days: days),
              AppSpacing.gapSm,
              Text(l10n.statsActivityHint, style: context.text.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _FocusByDaySection extends ConsumerWidget {
  const _FocusByDaySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final days = ref.watch(statsDailyFocusProvider).valueOrNull ?? const [];

    final maxMinutes = days.fold<int>(
      0,
      (max, d) => d.focusMinutes > max ? d.focusMinutes : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PixelSectionHeader(title: l10n.statsFocusByDay),
        PixelCard(
          child: days.isEmpty || maxMinutes == 0
              ? Text(l10n.statsEmpty, style: context.text.body)
              : SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceBetween,
                      maxY: (maxMinutes * 1.2).ceilToDouble(),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= days.length) {
                                return const SizedBox.shrink();
                              }
                              // На месяце подписываем каждый пятый день:
                              // иначе подписи сливаются в полосу.
                              final step = days.length > 10 ? 5 : 1;
                              if (index % step != 0) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${days[index].day.day}',
                                  style: context.text.chartLabel,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var i = 0; i < days.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: days[i].focusMinutes.toDouble(),
                                width: days.length > 10 ? 6 : 16,
                                // Квадратные столбики — часть пиксельного языка.
                                borderRadius: BorderRadius.zero,
                                color: colors.accent,
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: (maxMinutes * 1.2),
                                  color: colors.surfaceVariant,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// Настроение против результата. Самый содержательный график приложения:
/// он показывает, в каком состоянии пользователь реально доводит сессии до
/// конца — а это часто не то состояние, в котором он думает, что работает.
class _MoodSection extends ConsumerWidget {
  const _MoodSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final stats = ref.watch(statsMoodProvider).valueOrNull ?? const [];
    final withData = stats.where((s) => s.total > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PixelSectionHeader(title: l10n.statsMoodBreakdown),
        PixelCard(
          child: withData.isEmpty
              ? Text(l10n.statsEmpty, style: context.text.body)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final stat in withData) ...[
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            color: colors.moodByIndex(stat.mood.index),
                          ),
                          AppSpacing.wGapSm,
                          Expanded(
                            child: Text(
                              stat.mood.label(l10n),
                              style: context.text.label,
                            ),
                          ),
                          Text(
                            '${(stat.completionRate * 100).round()}% · '
                            '${stat.total}',
                            style: context.text.chartLabel,
                          ),
                        ],
                      ),
                      AppSpacing.gapXs,
                      _PixelBar(
                        value: stat.completionRate,
                        color: colors.moodByIndex(stat.mood.index),
                      ),
                      AppSpacing.gapMd,
                    ],
                    Text(
                      l10n.statsMoodBreakdownHint,
                      style: context.text.caption,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Полоса из дискретных сегментов вместо гладкого прогресса.
class _PixelBar extends StatelessWidget {
  const _PixelBar({required this.value, required this.color});

  final double value;
  final Color color;

  static const int _segments = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = (value.clamp(0.0, 1.0) * _segments).round();
    return Row(
      children: [
        for (var i = 0; i < _segments; i++)
          Expanded(
            child: Container(
              height: 10,
              margin: const EdgeInsets.only(right: 2),
              color: i < filled ? color : colors.surfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _CategorySection extends ConsumerWidget {
  const _CategorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats = ref.watch(statsCategoryProvider).valueOrNull ?? const [];
    final total = stats.fold<int>(0, (sum, s) => sum + s.focusSeconds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PixelSectionHeader(title: l10n.statsByCategory),
        PixelCard(
          child: stats.isEmpty || total == 0
              ? Text(l10n.statsEmpty, style: context.text.body)
              : Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 28,
                          sections: [
                            for (var i = 0; i < stats.length; i++)
                              PieChartSectionData(
                                value: stats[i].focusSeconds.toDouble(),
                                color:
                                    AppColors.categoryPalette[i %
                                        AppColors.categoryPalette.length],
                                radius: 26,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.wGapLg,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < stats.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    color:
                                        AppColors.categoryPalette[i %
                                            AppColors.categoryPalette.length],
                                  ),
                                  AppSpacing.wGapSm,
                                  Expanded(
                                    child: Text(
                                      stats[i].category.label(l10n),
                                      style: context.text.label,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    DurationFormat.compactFromSeconds(
                                      stats[i].focusSeconds,
                                    ),
                                    style: context.text.chartLabel,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _HabitSuccessSection extends ConsumerWidget {
  const _HabitSuccessSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final stats = ref.watch(statsHabitSuccessProvider).valueOrNull ?? const [];
    final withData = stats.where((s) => s.scheduledDays > 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PixelSectionHeader(title: l10n.statsHabitSuccess),
        PixelCard(
          child: withData.isEmpty
              ? Text(l10n.statsEmpty, style: context.text.body)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final stat in withData) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stat.habitName,
                              style: context.text.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${stat.completedDays}/${stat.scheduledDays}',
                            style: context.text.chartLabel,
                          ),
                        ],
                      ),
                      AppSpacing.gapXs,
                      _PixelBar(value: stat.rate, color: colors.success),
                      AppSpacing.gapMd,
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
