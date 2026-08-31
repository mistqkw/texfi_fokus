import 'package:flutter/material.dart';

import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/statistics.dart';

/// Календарь активности в духе GitHub contributions, но пиксель-арт:
/// квадратные ячейки без скруглений, разделённые видимым «швом» в 2px,
/// и всего пять ступеней яркости вместо плавной шкалы — градиент здесь
/// смотрелся бы чужеродно.
class PixelHeatmap extends StatelessWidget {
  const PixelHeatmap({
    super.key,
    required this.days,
    this.cellSize = 14,
    this.onDayTap,
  });

  /// Дни по возрастанию даты. Пропусков быть не должно: сетка рисуется
  /// подряд, и дырка сдвинула бы календарь.
  final List<DailyFocus> days;

  final double cellSize;
  final ValueChanged<DailyFocus>? onDayTap;

  /// Порог в минутах для верхней ступени яркости. Всё, что выше, — максимум.
  static const int _maxMinutes = 120;

  int _level(DailyFocus day) {
    final minutes = day.focusMinutes;
    if (minutes <= 0) return 0;
    if (minutes < 15) return 1;
    if (minutes < 45) return 2;
    if (minutes < _maxMinutes) return 3;
    return 4;
  }

  Color _colorFor(BuildContext context, int level) {
    final colors = context.colors;
    return switch (level) {
      0 => colors.surfaceVariant,
      1 => colors.accent.withValues(alpha: 0.28),
      2 => colors.accent.withValues(alpha: 0.52),
      3 => colors.accent.withValues(alpha: 0.76),
      _ => colors.accent,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    // Сетку выравниваем по неделям: первая колонка начинается с понедельника,
    // иначе строки перестают соответствовать дням недели.
    final leadingBlanks = days.first.day.weekday - 1;
    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (final day in days) _HeatCell(
          color: _colorFor(context, _level(day)),
          onTap: onDayTap == null ? null : () => onDayTap!(day),
        ),
    ];

    final weeks = (cells.length / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var week = 0; week < weeks; week++)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Column(
                    children: [
                      for (var d = 0; d < 7; d++)
                        () {
                          final index = week * 7 + d;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: SizedBox(
                              width: cellSize,
                              height: cellSize,
                              child: index < cells.length ? cells[index] : null,
                            ),
                          );
                        }(),
                    ],
                  ),
                ),
            ],
          ),
        ),
        AppSpacing.gapSm,
        _Legend(colorFor: (level) => _colorFor(context, level)),
      ],
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.color, this.onTap});

  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cell = DecoratedBox(
      decoration: BoxDecoration(color: color),
      child: const SizedBox.expand(),
    );
    if (onTap == null) return cell;
    return GestureDetector(onTap: onTap, child: cell);
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.colorFor});

  final Color Function(int level) colorFor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var level = 0; level < 5; level++)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(left: 3),
            color: colorFor(level),
          ),
      ],
    );
  }
}
