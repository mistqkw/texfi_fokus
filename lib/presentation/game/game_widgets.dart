import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';

/// Живой пиксельный спрайт: пока противник цел — подрагивает и мерцает,
/// когда побеждён — рассыпается по клеткам.
///
/// Анимация нарочно построена на целых клетках сетки, а не на плавном
/// сдвиге в долях пикселя: спрайт, который «едет» на полклетки, перестаёт
/// быть пиксель-артом и начинает выглядеть как размытая картинка.
class PixelCreature extends StatefulWidget {
  const PixelCreature({
    super.key,
    required this.rows,
    required this.color,
    this.size = 96,
    this.alive = true,
    this.animate = true,
    this.onDissolved,
  });

  final List<String> rows;
  final Color color;
  final double size;

  /// `false` — проигрывает распад и больше не возвращается.
  final bool alive;

  /// Полностью статичный спрайт: нужен на карте, где два десятка узлов
  /// дёргались бы разом и превращали экран в рябь.
  final bool animate;

  final VoidCallback? onDissolved;

  @override
  State<PixelCreature> createState() => _PixelCreatureState();
}

class _PixelCreatureState extends State<PixelCreature>
    with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late final AnimationController _dissolve = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate && widget.alive) _idle.repeat(reverse: true);
    if (!widget.alive) _dissolve.value = 1;
  }

  @override
  void didUpdateWidget(PixelCreature oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alive && !widget.alive) {
      _idle.stop();
      _dissolve.forward(from: 0).then((_) {
        if (mounted) widget.onDissolved?.call();
      });
    } else if (!oldWidget.alive && widget.alive) {
      _dissolve.value = 0;
      if (widget.animate) _idle.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _dissolve.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idle, _dissolve]),
        builder: (context, _) {
          final cells = widget.rows.length;
          final cell = widget.size / cells;

          // Подрагивание — ровно на одну клетку и только вниз: так существо
          // «дышит», а не прыгает.
          final jitter = widget.animate && widget.alive && _idle.value > 0.5
              ? cell
              : 0.0;

          return Transform.translate(
            offset: Offset(0, jitter),
            child: Opacity(
              opacity: widget.alive
                  ? (0.85 + 0.15 * _idle.value)
                  : (1 - _dissolve.value).clamp(0.0, 1.0),
              child: CustomPaint(
                painter: _CreaturePainter(
                  rows: widget.rows,
                  color: widget.color,
                  dissolve: _dissolve.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Отрисовщик с распадом.
///
/// Клетки исчезают не по порядку, а вразнобой — но вразнобой одинаково при
/// каждом показе: порог берётся из координат клетки, а не из генератора
/// случайных чисел. Иначе спрайт «кипел» бы на каждом кадре перерисовки.
class _CreaturePainter extends CustomPainter {
  const _CreaturePainter({
    required this.rows,
    required this.color,
    required this.dissolve,
  });

  final List<String> rows;
  final Color color;
  final double dissolve;

  /// Устойчивый псевдослучайный порог клетки, 0..1.
  double _threshold(int x, int y) {
    final n = math.sin(x * 12.9898 + y * 78.233) * 43758.5453;
    return (n - n.floorToDouble()).abs();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (rows.isEmpty) return;
    final cell = size.width / rows.length;
    final paint = Paint()..color = color;

    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      for (var x = 0; x < row.length; x++) {
        if (row[x] == '.') continue;
        if (dissolve > 0 && _threshold(x, y) < dissolve) continue;

        // При распаде уцелевшие клетки разлетаются вверх и в стороны.
        final drift = dissolve == 0
            ? Offset.zero
            : Offset(
                (_threshold(x + 7, y) - 0.5) * cell * 4 * dissolve,
                -dissolve * cell * 3,
              );

        canvas.drawRect(
          Rect.fromLTWH(
            x * cell + drift.dx,
            y * cell + drift.dy,
            // Нахлёст в полклетки — тот же приём, что в PixelSpritePainter:
            // без него на дробном devicePixelRatio видны швы.
            cell + 0.5,
            cell + 0.5,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CreaturePainter old) =>
      old.dissolve != dissolve || old.color != color || old.rows != rows;
}

/// Полоска в пиксельном стиле: не сглаженный прогресс, а набор блоков.
///
/// Плавный `LinearProgressIndicator` здесь смотрелся бы чужим ровно так же,
/// как Material-иконка внутри пиксельной кнопки, поэтому шкала намеренно
/// дискретна — видно, сколько «клеток» осталось.
class PixelStatBar extends StatelessWidget {
  const PixelStatBar({
    super.key,
    required this.value,
    required this.color,
    this.segments = 20,
    this.height = 12,
    this.background,
  });

  /// 0..1.
  final double value;
  final Color color;
  final int segments;
  final double height;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = (value.clamp(0.0, 1.0) * segments).round();

    return Container(
      height: height,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: background ?? colors.surfaceVariant,
        border: Border.all(color: colors.divider, width: AppRadius.pixelBorder),
      ),
      child: Row(
        children: [
          for (var i = 0; i < segments; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.5),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  color: i < filled ? color : Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Подписанная полоска: имя слева, цифры справа, шкала под ними.
class PixelStatRow extends StatelessWidget {
  const PixelStatRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.trailing,
    this.segments = 20,
  });

  final String label;
  final double value;
  final Color color;
  final String? trailing;
  final int segments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: context.text.chartLabel),
            if (trailing != null)
              Text(trailing!, style: context.text.chartLabel),
          ],
        ),
        AppSpacing.gapXs,
        PixelStatBar(value: value, color: color, segments: segments),
      ],
    );
  }
}
