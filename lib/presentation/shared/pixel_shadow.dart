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
    // Отступ справа и снизу резервирует место под тень: без него элемент
    // занимал бы на 3px больше собственной раскладки.
    final body = Padding(
      padding: EdgeInsets.only(right: offset, bottom: offset),
      child: child,
    );

    if (!enabled) return body;

    // Сдвиг содержимого и убыль тени идут от одного значения.
    //
    // Раньше содержимое уезжало за [AppMotion.instant], а тень пропадала
    // мгновенно — на те же 90 мс кнопка оставалась в верхнем положении, но
    // уже без объёма, и нажатие читалось как мигание, а не как утапливание.
    // Физическая клавиша так себя не ведёт: она уходит вниз ровно настолько,
    // насколько закрывает собой тень.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: pressed ? 1 : 0),
      duration: AppMotion.instant,
      curve: AppMotion.enter,
      builder: (context, t, child) {
        final shift = offset * t;
        return CustomPaint(
          painter: _PixelShadowPainter(
            color: shadowColor,
            radius: borderRadius,
            offset: offset,
            // Тень не просто исчезает — её съедает опускающийся элемент.
            visible: 1 - t,
          ),
          child: Transform.translate(
            offset: Offset(shift, shift),
            child: child,
          ),
        );
      },
      child: body,
    );
  }
}

class _PixelShadowPainter extends CustomPainter {
  const _PixelShadowPainter({
    required this.color,
    required this.radius,
    required this.offset,
    this.visible = 1,
  });

  final Color color;
  final BorderRadius radius;
  final double offset;

  /// 0..1 — сколько тени осталось видно. Тень не растворяется прозрачностью,
  /// а укорачивается: полупрозрачный блок здесь был бы единственным местом
  /// в интерфейсе, где «объём» размывается.
  final double visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (visible <= 0) return;
    final shown = offset * visible;
    final rect = Rect.fromLTWH(
      offset,
      offset,
      size.width - offset - (offset - shown),
      size.height - offset - (offset - shown),
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
      oldDelegate.offset != offset ||
      oldDelegate.visible != visible;
}
