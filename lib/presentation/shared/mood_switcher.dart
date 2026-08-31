import 'package:flutter/material.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../domain/entities/mood.dart';

/// Переключатель настроения на четыре положения — центральный жест
/// приложения.
///
/// Работает и тапом по секции, и протяжкой. Вибрация даётся не «на любое
/// касание», а на каждое **изменение** состояния, и у каждого состояния она
/// своя: слабый одиночный импульс на «плохом», нарастающая очередь на
/// «full f0kus» (см. [Haptics.mood]). Смысл в том, чтобы состояние
/// чувствовалось рукой, а не только читалось глазами.
class MoodSwitcher extends StatefulWidget {
  const MoodSwitcher({
    super.key,
    required this.value,
    required this.onChanged,
    required this.labels,
  });

  final Mood value;
  final ValueChanged<Mood> onChanged;

  /// Подписи для четырёх состояний, в порядке [Mood.values].
  final List<String> labels;

  @override
  State<MoodSwitcher> createState() => _MoodSwitcherState();
}

class _MoodSwitcherState extends State<MoodSwitcher> {
  static const double _trackHeight = 64;

  void _selectFromOffset(double dx, double width) {
    final slot = (dx / (width / Mood.values.length))
        .floor()
        .clamp(0, Mood.values.length - 1);
    final mood = Mood.values[slot];
    if (mood == widget.value) return;
    Haptics.mood(mood.index);
    widget.onChanged(mood);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeColor = colors.moodByIndex(widget.value.index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MoodFace(mood: widget.value, color: activeColor),
        AppSpacing.gapLg,
        Text(
          widget.labels[widget.value.index],
          textAlign: TextAlign.center,
          style: context.text.headline.copyWith(color: activeColor),
        ),
        AppSpacing.gapLg,
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final slotWidth = width / Mood.values.length;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) =>
                  _selectFromOffset(details.localPosition.dx, width),
              onHorizontalDragStart: (details) =>
                  _selectFromOffset(details.localPosition.dx, width),
              onHorizontalDragUpdate: (details) =>
                  _selectFromOffset(details.localPosition.dx, width),
              child: SizedBox(
                height: _trackHeight,
                child: Stack(
                  children: [
                    // Дорожка: четыре одинаковые ячейки с разделителями.
                    Row(
                      children: [
                        for (final mood in Mood.values)
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: colors.surfaceVariant,
                                borderRadius: AppRadius.controlTinyAll,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${mood.index + 1}',
                                style: context.text.chartLabel,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Ползунок: намеренно квадратный, движется рывком между
                    // позициями, а не плавно по всему треку.
                    AnimatedPositioned(
                      duration: AppMotion.fast,
                      curve: AppMotion.snap,
                      left: slotWidth * widget.value.index,
                      width: slotWidth,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: AppRadius.controlTinyAll,
                          border: Border.all(
                            color: colors.textPrimary.withValues(alpha: 0.25),
                            width: AppRadius.pixelBorder,
                          ),
                        ),
                        child: Center(
                          child: _PixelBlocks(
                            count: widget.value.index + 1,
                            color: colors.onAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Столбики «уровня заряда» внутри ползунка: 1 блок на «плохом», 4 на
/// «full f0kus». Нужны, чтобы состояние читалось без цвета — например,
/// при дальтонизме.
class _PixelBlocks extends StatelessWidget {
  const _PixelBlocks({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            width: 5,
            height: 6.0 + i * 5,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            color: i < count ? color : color.withValues(alpha: 0.22),
          ),
      ],
    );
  }
}

/// Пиксельная «рожица» состояния — 8×8 сетка, нарисованная блоками.
/// Каждый уровень настроения имеет свою маску, поэтому переключатель
/// выглядит как ретро-спрайт, а не как эмодзи.
class _MoodFace extends StatelessWidget {
  const _MoodFace({required this.mood, required this.color});

  final Mood mood;
  final Color color;

  /// 8 строк по 8 символов: '.' — пусто, 'x' — пиксель.
  static const Map<Mood, List<String>> _sprites = {
    Mood.bad: [
      '........',
      '.xx..xx.',
      '.xx..xx.',
      '........',
      '........',
      '..xxxx..',
      '.x....x.',
      '........',
    ],
    Mood.neutral: [
      '........',
      '.xx..xx.',
      '.xx..xx.',
      '........',
      '........',
      '.xxxxxx.',
      '........',
      '........',
    ],
    Mood.good: [
      '........',
      '.xx..xx.',
      '.xx..xx.',
      '........',
      '.x....x.',
      '..xxxx..',
      '........',
      '........',
    ],
    Mood.fullFokus: [
      '..x..x..',
      '.xxxxxx.',
      '.x.xx.x.',
      '.xxxxxx.',
      '.x....x.',
      '..xxxx..',
      '...xx...',
      '..x..x..',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            painter: _SpritePainter(
              rows: _sprites[mood]!,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpritePainter extends CustomPainter {
  const _SpritePainter({required this.rows, required this.color});

  final List<String> rows;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / rows.length;
    final paint = Paint()..color = color;
    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      for (var x = 0; x < row.length; x++) {
        if (row[x] != 'x') continue;
        canvas.drawRect(
          Rect.fromLTWH(x * cell, y * cell, cell, cell),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) =>
      oldDelegate.rows != rows || oldDelegate.color != color;
}
