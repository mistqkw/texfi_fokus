import 'package:flutter/material.dart';

import '../../core/theme/app_colors_ext.dart';

/// Фоновая пиксельная текстура: редкий детерминированный крап поверх
/// сплошного цвета.
///
/// Смысл — убрать ощущение «пустой чёрной заливки», не мешая читаемости:
/// точки размером в 2 логических пикселя с альфой около 5% глаз замечает
/// как фактуру, но не как шум под текстом.
class PixelBackground extends StatelessWidget {
  const PixelBackground({super.key, required this.child, this.density = 0.06});

  final Widget child;

  /// Доля закрашенных ячеек сетки, 0..1.
  final double density;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: CustomPaint(
        painter: _PixelNoisePainter(color: colors.noise, density: density),
        child: child,
      ),
    );
  }
}

class _PixelNoisePainter extends CustomPainter {
  const _PixelNoisePainter({required this.color, required this.density});

  final Color color;
  final double density;

  static const double _cell = 6;
  static const double _dot = 2;

  /// Тот же целочисленный хеш, что и в переходах: узор обязан быть
  /// одинаковым между кадрами, иначе фон начнёт «кипеть» при перерисовке.
  double _noise(int x, int y) {
    var h = x * 73856093 ^ y * 19349663;
    h = (h ^ (h >> 13)) * 1274126177;
    h = h ^ (h >> 16);
    return (h & 0xFFFF) / 0xFFFF;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (density <= 0) return;
    final paint = Paint()..color = color;
    final cols = (size.width / _cell).ceil();
    final rows = (size.height / _cell).ceil();
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        if (_noise(x, y) > density) continue;
        canvas.drawRect(
          Rect.fromLTWH(x * _cell, y * _cell, _dot, _dot),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PixelNoisePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.density != density;
}
