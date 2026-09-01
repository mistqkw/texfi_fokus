import 'package:flutter/material.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../domain/entities/mood.dart';
import 'pixel_sprite.dart';

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
/// выглядит как ретро-спрайт, а не как эмодзи. Рисуется общим
/// [PixelSprite] — тем же, что и иконки нижней навигации.
class _MoodFace extends StatefulWidget {
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

  /// Промежуточный кадр перехода: глаза закрыты, рот — одна черта.
  ///
  /// Кроссфейд между двумя спрайтами дал бы на пару кадров полупрозрачную
  /// кашу из обоих лиц — то есть ровно то, чего в пиксель-арте не бывает.
  /// Ретро-спрайты переключаются кадрами, поэтому смена состояния идёт
  /// через «моргание»: лицо закрывается и открывается уже новым.
  static const List<String> _blink = [
    '........',
    '........',
    '.xx..xx.',
    '........',
    '........',
    '..xxxx..',
    '........',
    '........',
  ];

  @override
  State<_MoodFace> createState() => _MoodFaceState();
}

class _MoodFaceState extends State<_MoodFace>
    with SingleTickerProviderStateMixin {
  /// Длительность совпадает с [AppMotion.pop] — тем же, чем отбивается
  /// нажатие. Вибро-отклик даётся в момент смены состояния (см.
  /// [_MoodSwitcherState._selectFromOffset]), а этот контроллер стартует в
  /// том же кадре из `didUpdateWidget`: рука и глаз получают подтверждение
  /// одновременно, а не с разбегом в пару кадров.
  late final AnimationController _swap = AnimationController(
    vsync: this,
    duration: AppMotion.pop,
  );

  @override
  void didUpdateWidget(_MoodFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) _swap.forward(from: 0);
  }

  @override
  void dispose() {
    _swap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Center(
        child: AnimatedBuilder(
          animation: _swap,
          builder: (context, _) {
            // Три кадра, а не плавная кривая: закрыт — закрыт — открыт.
            // Спрайт всегда нарисован целиком и всегда непрозрачен.
            final blinking = _swap.isAnimating && _swap.value < 0.45;
            return PixelSprite(
              rows: blinking
                  ? _MoodFace._blink
                  : _MoodFace._sprites[widget.mood]!,
              color: widget.color,
              size: 96,
            );
          },
        ),
      ),
    );
  }
}
