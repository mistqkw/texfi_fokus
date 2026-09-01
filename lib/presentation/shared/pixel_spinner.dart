import 'package:flutter/material.dart';

import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';

/// Индикатор ожидания в пиксельном языке.
///
/// Material `CircularProgressIndicator` — сглаженная дуга с плавным
/// вращением, то есть ровно то, чего в этом интерфейсе нет больше нигде:
/// весь остальной экран собран из квадратов с жёсткими краями. Здесь вместо
/// дуги четыре квадрата, зажигающиеся по кругу дискретными шагами.
///
/// Шаг намеренно крупный (не 60 кадров в секунду, а восемь состояний в
/// секунду): плавная анимация выдала бы ту же «материальность», от которой
/// мы и уходим.
class PixelSpinner extends StatefulWidget {
  const PixelSpinner({super.key, this.size = 8, this.label});

  /// Сторона одного квадрата.
  final double size;

  /// Необязательная подпись под индикатором. Ожидание без слов пугает
  /// сильнее, чем ожидание с объяснением, — но на короткой загрузке списка
  /// подпись только мигала бы, поэтому она не обязательна.
  final String? label;

  @override
  State<PixelSpinner> createState() => _PixelSpinnerState();
}

class _PixelSpinnerState extends State<PixelSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 640),
  )..repeat();

  /// Смещения четырёх квадратов по часовой стрелке.
  static const List<Offset> _cells = [
    Offset(0, 0),
    Offset(1, 0),
    Offset(1, 1),
    Offset(0, 1),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final side = widget.size;
    final gap = AppRadius.pixelBorder;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: side * 2 + gap,
          height: side * 2 + gap,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              // Восемь тактов на оборот: четыре квадрата успевают побывать
              // и яркими, и приглушёнными.
              final step = (_controller.value * 8).floor() % 4;
              return Stack(
                children: [
                  for (var i = 0; i < _cells.length; i++)
                    Positioned(
                      left: _cells[i].dx * (side + gap),
                      top: _cells[i].dy * (side + gap),
                      width: side,
                      height: side,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: i == step
                              ? colors.accent
                              : colors.accent.withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (widget.label case final label?) ...[
          AppSpacing.gapMd,
          Text(
            label,
            style: context.text.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
