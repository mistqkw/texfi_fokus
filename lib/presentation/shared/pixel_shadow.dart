import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';

/// Ретро-«тень»: не размытие, а тот же самый прямоугольник, сдвинутый на
/// несколько пикселей вниз-вправо. Ровно так тень рисовали интерфейсы, у
/// которых на неё было три цвета и ни одного альфа-канала.
///
/// Это единственная реализация приёма в приложении — им пользуются и
/// `PixelButton`, и `PixelCard`, и переключатели периода в статистике.
/// Отдельный виджет нужен, чтобы «объём» нигде не разъезжался на пиксель.
///
/// [pressed] сдвигает содержимое ровно на высоту тени и убирает её: элемент
/// проваливается, как физическая клавиша, а общий размер не меняется —
/// соседи не дёргаются.
///
/// Тень рисуется [CustomPaint] позади ребёнка, а не отдельным слоем в
/// [Stack]. Со Stack виджет переставал наследовать размер ребёнка: при
/// `StackFit.loose` тень растягивалась во всю доступную ширину (карточки
/// сводки на «Главной» получали синий хвост), а при `passthrough` уже сама
/// карточка растягивалась на весь экран. CustomPaint принимает размер
/// ребёнка и передаёт наверх его же intrinsic-размеры — то есть ведёт себя
/// как обычная обёртка.
class PixelShadowBox extends StatelessWidget {
  const PixelShadowBox({
    super.key,
    required this.child,
    required this.shadowColor,
    this.borderRadius = AppRadius.controlSmallAll,
    this.offset = AppRadius.pixelShadowOffset,
    this.pressed = false,
    this.enabled = true,
  });

  final Widget child;
  final Color shadowColor;
  final BorderRadius borderRadius;
  final double offset;
  final bool pressed;

  /// Выключенный элемент тени не отбрасывает — он «не нажимается».
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final shift = pressed ? offset : 0.0;

    // Отступ справа и снизу резервирует место под тень: без него элемент
    // занимал бы на 3px больше собственной раскладки.
    final body = Padding(
      padding: EdgeInsets.only(right: offset, bottom: offset),
      child: AnimatedContainer(
        duration: AppMotion.instant,
        curve: AppMotion.enter,
        transform: Matrix4.translationValues(shift, shift, 0),
        child: child,
      ),
    );

    if (!enabled || pressed) return body;

    return CustomPaint(
      painter: _PixelShadowPainter(
        color: shadowColor,
        radius: borderRadius,
        offset: offset,
      ),
      child: body,
    );
  }
}

class _PixelShadowPainter extends CustomPainter {
  const _PixelShadowPainter({
    required this.color,
    required this.radius,
    required this.offset,
  });

  final Color color;
  final BorderRadius radius;
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      offset,
      offset,
      size.width - offset,
      size.height - offset,
    );
    if (rect.isEmpty) return;
    canvas.drawRRect(
      radius.toRRect(rect),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_PixelShadowPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.offset != offset;
}
