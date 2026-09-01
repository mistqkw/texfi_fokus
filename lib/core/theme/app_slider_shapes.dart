import 'package:flutter/material.dart';

import 'app_radius.dart';

/// Квадратный ползунок слайдера. Material рисует круг с «ореолом» нажатия —
/// последний круглый контрол на экране настроек; здесь вместо него блок
/// с той же пиксельной рамкой, что у остальных элементов.
class PixelSliderThumb extends SliderComponentShape {
  const PixelSliderThumb({
    required this.color,
    required this.borderColor,
    this.size = 16,
  });

  final Color color;
  final Color borderColor;
  final double size;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(size, size);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final rect = Rect.fromCenter(center: center, width: size, height: size);
    context.canvas
      ..drawRect(rect, Paint()..color = color)
      ..drawRect(
        rect,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppRadius.pixelBorder,
      );
  }
}
