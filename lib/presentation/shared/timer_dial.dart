import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_motion.dart';

/// Круговая «крутилка» таймера: показывает прогресс и позволяет прямо во
/// время сессии подкрутить оставшееся время.
///
/// Кольцо нарисовано не гладкой дугой, а отдельными сегментами — это и есть
/// пиксельная стилистика, и заодно даёт понятную «зернистость»: один сегмент
/// читается как единица времени.
///
/// Тактильный отклик — ключевая часть жеста: щелчок даётся на каждые
/// [minutesPerTick] минут прокрутки, а не на каждый кадр, иначе вибромотор
/// превращается в сплошное гудение и жест перестаёт ощущаться дискретным.
class TimerDial extends StatefulWidget {
  const TimerDial({
    super.key,
    required this.progress,
    required this.remaining,
    required this.onAdjustMinutes,
    this.enabled = true,
    this.accentColor,
    this.minutesPerTick = 1,
    this.label,
  });

  /// 0..1 — доля пройденного времени текущей фазы.
  final double progress;

  /// Оставшееся время; отображается в центре крупными табличными цифрами.
  final Duration remaining;

  /// Вызывается с накопленной дельтой в минутах (может быть отрицательной).
  final ValueChanged<int> onAdjustMinutes;

  final bool enabled;
  final Color? accentColor;

  /// Сколько минут «стоит» один щелчок вибрации.
  final int minutesPerTick;

  /// Короткая подпись над цифрами — например, «ФОКУС» или «ПЕРЕРЫВ».
  final String? label;

  @override
  State<TimerDial> createState() => _TimerDialState();
}

class _TimerDialState extends State<TimerDial>
    with SingleTickerProviderStateMixin {
  /// Сколько полных оборотов «накручено» с начала жеста, в минутах.
  double _accumulatedMinutes = 0;
  int _lastAppliedTick = 0;
  double? _lastAngle;

  /// «Взятость» крутилки: 0 — отпущена, 1 — палец на ней.
  ///
  /// Пока отклик был только в цифрах, крутилка не отличалась от картинки:
  /// человек тянет за неё, число меняется, но сам элемент никак не
  /// подтверждает, что жест вообще принят. Масштаб это подтверждает раньше,
  /// чем успеет прочитаться цифра.
  late final AnimationController _grab = AnimationController(
    vsync: this,
    duration: AppMotion.pop,
  );

  @override
  void dispose() {
    _grab.dispose();
    super.dispose();
  }

  /// Один полный оборот = 60 минут. Так жест совпадает с часовой метафорой:
  /// четверть круга — 15 минут.
  static const double _minutesPerTurn = 60;

  double _angleOf(Offset local, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final vector = local - center;
    return math.atan2(vector.dy, vector.dx);
  }

  void _onPanStart(DragStartDetails details, Size size) {
    if (!widget.enabled) return;
    _grab.forward();
    _lastAngle = _angleOf(details.localPosition, size);
    _accumulatedMinutes = 0;
    _lastAppliedTick = 0;
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (!widget.enabled || _lastAngle == null) return;

    final angle = _angleOf(details.localPosition, size);
    var delta = angle - _lastAngle!;

    // Переход через ±pi даёт скачок на полный оборот — нормализуем, иначе
    // один пиксель движения читался бы как -59 минут.
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;

    _lastAngle = angle;
    _accumulatedMinutes += delta / (2 * math.pi) * _minutesPerTurn;

    final tick = (_accumulatedMinutes / widget.minutesPerTick).round();
    if (tick == _lastAppliedTick) return;

    final steps = tick - _lastAppliedTick;
    _lastAppliedTick = tick;
    Haptics.dialTick();
    widget.onAdjustMinutes(steps * widget.minutesPerTick);
  }

  void _onPanEnd() {
    _grab.reverse();
    _lastAngle = null;
    _accumulatedMinutes = 0;
    _lastAppliedTick = 0;
  }

  String _format(Duration d) {
    final total = d.isNegative ? Duration.zero : d;
    final minutes = total.inMinutes;
    final seconds = total.inSeconds % 60;
    final h = minutes ~/ 60;
    if (h > 0) {
      return '$h:${(minutes % 60).toString().padLeft(2, '0')}'
          ':${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}'
        ':${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = widget.accentColor ?? colors.accent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final size = Size(side, side);
        return SizedBox(
          width: side,
          height: side,
          child: GestureDetector(
            onPanStart: (d) => _onPanStart(d, size),
            onPanUpdate: (d) => _onPanUpdate(d, size),
            onPanEnd: (_) => _onPanEnd(),
            onPanCancel: _onPanEnd,
            child: AnimatedBuilder(
              animation: _grab,
              builder: (context, child) => Transform.scale(
                // Ровно 3%: жест должен ощущаться принятым, а не должен
                // перекомпоновывать экран под пальцем.
                scale: 1 + 0.03 * _grab.value,
                child: child,
              ),
              child: CustomPaint(
              painter: _DialPainter(
                progress: widget.progress.clamp(0.0, 1.0),
                accent: accent,
                track: colors.surfaceVariant,
                knob: widget.enabled ? accent : colors.textTertiary,
                grab: _grab,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.label != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          widget.label!,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: accent),
                        ),
                      ),
                    FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _format(widget.remaining),
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ),
          ),
        );
      },
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.progress,
    required this.accent,
    required this.track,
    required this.knob,
    required this.grab,
  }) : super(repaint: grab);

  final double progress;
  final Color accent;
  final Color track;
  final Color knob;

  /// 0..1 — насколько крутилка «взята». Подсвечивает ручку: за неё берутся
  /// пальцем, и именно она должна показать, что жест принят.
  final Animation<double> grab;

  /// Сегментов в круге. 60 — по минуте на сегмент при часовом обороте.
  static const int _segments = 60;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final ringWidth = radius * 0.14;
    final ringRadius = radius - ringWidth;

    final filled = (progress * _segments).round();
    final segmentPaint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < _segments; i++) {
      // Отсчёт от 12 часов по часовой стрелке.
      final angle = -math.pi / 2 + (i / _segments) * 2 * math.pi;
      final isFilled = i < filled;
      segmentPaint.color = isFilled ? accent : track;

      final blockSize = ringWidth * (isFilled ? 0.72 : 0.5);
      final position = Offset(
        center.dx + math.cos(angle) * ringRadius,
        center.dy + math.sin(angle) * ringRadius,
      );

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(angle + math.pi / 2);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: blockSize,
          height: blockSize * 1.4,
        ),
        segmentPaint,
      );
      canvas.restore();
    }

    // Ручка на границе заполнения — за неё «берутся» пальцем.
    final knobAngle = -math.pi / 2 + progress * 2 * math.pi;
    final knobCenter = Offset(
      center.dx + math.cos(knobAngle) * ringRadius,
      center.dy + math.sin(knobAngle) * ringRadius,
    );
    canvas.save();
    canvas.translate(knobCenter.dx, knobCenter.dy);
    canvas.rotate(knobAngle + math.pi / 2);
    final grabbed = grab.value;
    final knobSide = ringWidth * (1.15 + 0.35 * grabbed);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: knobSide,
        height: knobSide,
      ),
      Paint()..color = Color.lerp(knob, accent, grabbed) ?? knob,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) =>
      oldDelegate.grab != grab ||
      oldDelegate.progress != progress ||
      oldDelegate.accent != accent ||
      oldDelegate.track != track ||
      oldDelegate.knob != knob;
}
