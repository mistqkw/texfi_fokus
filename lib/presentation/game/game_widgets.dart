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
    duration: AppMotion.dissolve,
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
      return;
    }
    if (!oldWidget.alive && widget.alive) {
      _dissolve.value = 0;
    }

    // «Дыхание» включается и гаснет вслед за [animate]. Через это же поле
    // пауза таймера останавливает противника: на паузе он замирает, и
    // остановка времени видна на экране, а не только в подписи кнопки.
    final shouldIdle = widget.animate && widget.alive;
    if (shouldIdle && !_idle.isAnimating) {
      _idle.repeat(reverse: true);
    } else if (!shouldIdle && _idle.isAnimating) {
      _idle.stop();
      // Возврат в «выдох»: замерший на полувдохе спрайт выглядит смещённым
      // на клетку вниз, а не остановленным.
      _idle.value = 0;
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
              // При распаде спрайт не гасится целиком: гаснут отдельные
              // клетки, и общая прозрачность только смазала бы порядок,
              // ради которого эффект и сделан. Общее затухание включается
              // на последней четверти — убрать оставшиеся одиночные клетки.
              opacity: widget.alive
                  ? (0.85 + 0.15 * _idle.value)
                  : (1 - (_dissolve.value - 0.75) / 0.25).clamp(0.0, 1.0),
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

/// Устойчивый псевдослучайный «шум» клетки, 0..1.
///
/// Не `Random`: порог обязан быть одним и тем же на каждом кадре, иначе
/// спрайт «кипит» вместо того, чтобы рассыпаться.
double _cellNoise(int x, int y) {
  final n = math.sin(x * 12.9898 + y * 78.233) * 43758.5453;
  return (n - n.floorToDouble()).abs();
}

/// Порог исчезновения одной клетки спрайта при распаде, 0..1.
///
/// Клетка гаснет, когда прогресс распада перевалил её порог. Порог задаётся
/// в первую очередь **строкой**, и строки идут снизу вверх: существо
/// осыпается, как будто из-под него выбили опору. Ровно эта очерёдность
/// отличает «спрайт рассыпался» от «спрайт не загрузился» — случайная россыпь
/// по всей площади читается как сбой отрисовки, а не как исход боя.
///
/// Внутри строки добавлен небольшой шум ([_cellNoise]), иначе строки уходили
/// бы идеально ровными полосами — а это уже похоже на стирание, а не на
/// осыпание.
///
/// Вынесено из отрисовщика отдельной функцией, потому что это единственная
/// часть эффекта, у которой есть проверяемое поведение: порядок строк.
double creatureCellDissolveThreshold(int x, int y, int rowCount) {
  if (rowCount <= 1) return _cellNoise(x, y);

  // 0 у нижней строки, 1 у верхней.
  final rowShare = (rowCount - 1 - y) / (rowCount - 1);

  // Шаг между строками. Разброс шума внутри строки берётся долей от этого
  // шага, а не фиксированным числом: сетки в приложении бывают и 8×8, и
  // 10×10, а на десяти строках шаг меньше — фиксированный разброс начал бы
  // перекрывать соседние строки, и распад снова стал бы случайной россыпью.
  const span = 0.78;
  final step = span / (rowCount - 1);

  return (rowShare * span + _cellNoise(x, y) * step * 0.8).clamp(0.0, 1.0);
}

/// Отрисовщик с распадом.
class _CreaturePainter extends CustomPainter {
  const _CreaturePainter({
    required this.rows,
    required this.color,
    required this.dissolve,
  });

  final List<String> rows;
  final Color color;
  final double dissolve;

  @override
  void paint(Canvas canvas, Size size) {
    if (rows.isEmpty) return;
    final cell = size.width / rows.length;
    final paint = Paint()..color = color;

    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      for (var x = 0; x < row.length; x++) {
        if (row[x] == '.') continue;
        final threshold = creatureCellDissolveThreshold(x, y, rows.length);
        if (dissolve > 0 && threshold < dissolve) continue;

        // Уцелевшие клетки слегка оседают и расходятся в стороны — но
        // вниз, а не вверх: рассыпается то, что теряет опору.
        final drift = dissolve == 0
            ? Offset.zero
            : Offset(
                (_cellNoise(x + 7, y) - 0.5) * cell * 1.5 * dissolve,
                dissolve * cell * 1.2,
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
class PixelStatBar extends StatefulWidget {
  const PixelStatBar({
    super.key,
    required this.value,
    required this.color,
    this.segments = 20,
    this.height = 12,
    this.background,
    this.flashOnDecrease = false,
  });

  /// 0..1.
  final double value;
  final Color color;
  final int segments;
  final double height;
  final Color? background;

  /// Отбивать ли убыль отдельным ударом: вспышка рамки и короткая тряска.
  ///
  /// Только для полосок, где убыль — это событие (HP противника). На шкале
  /// опыта или недельной нормы то же движение было бы шумом: там значение
  /// меняется само собой, а не в ответ на что-то.
  final bool flashOnDecrease;

  @override
  State<PixelStatBar> createState() => _PixelStatBarState();
}

class _PixelStatBarState extends State<PixelStatBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hit = AnimationController(
    vsync: this,
    duration: AppMotion.pop,
  );

  @override
  void didUpdateWidget(PixelStatBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.flashOnDecrease) return;

    // Реагируем на переход через границу сегмента, а не на любое изменение
    // дроби: полоска дискретна, и вспышка на невидимой глазу убыли
    // выглядела бы как случайное подёргивание.
    final was = (oldWidget.value.clamp(0.0, 1.0) * oldWidget.segments).round();
    final now = (widget.value.clamp(0.0, 1.0) * widget.segments).round();
    if (now < was) _hit.forward(from: 0);
  }

  @override
  void dispose() {
    _hit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = (widget.value.clamp(0.0, 1.0) * widget.segments).round();

    return AnimatedBuilder(
      animation: _hit,
      builder: (context, child) {
        // Один короткий удар: вспышка гаснет к концу, а не пульсирует.
        final t = _hit.value;
        final punch = t == 0 ? 0.0 : math.sin(t * math.pi);

        return Transform.translate(
          // Тряска ровно на два пикселя и только по горизонтали: полоска
          // не должна уезжать из строки, в которой стоит.
          offset: Offset(punch * 2 * (t < 0.5 ? 1 : -1), 0),
          child: Container(
            height: widget.height,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: widget.background ?? colors.surfaceVariant,
              border: Border.all(
                color: Color.lerp(
                  colors.divider,
                  widget.color,
                  punch,
                )!,
                width: AppRadius.pixelBorder,
              ),
            ),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          for (var i = 0; i < widget.segments; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.5),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  color: i < filled ? widget.color : Colors.transparent,
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
    this.flashOnDecrease = false,
  });

  final String label;
  final double value;
  final Color color;
  final String? trailing;
  final int segments;

  /// См. [PixelStatBar.flashOnDecrease].
  final bool flashOnDecrease;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Подпись сжимается, цифры — нет.
        //
        // Раньше оба текста стояли в Row без ограничений, и на узком экране
        // пара «Уровень 8» + «120 / 250 XP» просто вылезала за карточку —
        // в отладочной сборке это исключение, в собранной — жёлтая полоска
        // поверх экрана персонажа. Обрезать здесь можно только имя: цифры
        // справа — это и есть содержание строки, и «120 / 2…» не значит
        // ничего.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: context.text.chartLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) ...[
              AppSpacing.wGapSm,
              Text(trailing!, style: context.text.chartLabel),
            ],
          ],
        ),
        AppSpacing.gapXs,
        PixelStatBar(
          value: value,
          color: color,
          segments: segments,
          flashOnDecrease: flashOnDecrease,
        ),
      ],
    );
  }
}

/// Число, которое накручивается от нуля до итогового значения.
///
/// Опыт, появившийся уже готовой цифрой, читается как надпись на экране;
/// та же цифра, набранная на глазах, читается как начисление. Разница
/// целиком в том, видно ли событие в момент, когда оно происходит.
///
/// Счётчик идёт целыми числами: дробный опыт не существует, и промежуточные
/// «12.4» выдали бы, что это просто интерполяция.
class PixelCountUp extends StatelessWidget {
  const PixelCountUp({
    super.key,
    required this.value,
    required this.builder,
    this.duration = AppMotion.count,
    this.delay = Duration.zero,
  });

  /// Итоговое значение.
  final int value;

  /// Как показать промежуточное число. Строку собирает вызывающий: у опыта
  /// это «+12 XP» со своим склонением, и счётчик не должен об этом знать.
  final Widget Function(BuildContext context, int current) builder;

  final Duration duration;

  /// Пауза перед началом накрутки — чтобы счётчик не стартовал раньше, чем
  /// экран результата успел появиться.
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration + delay,
      // Быстро в начале, с замедлением к финальному числу: так последняя
      // цифра успевает прочитаться, а не мелькает.
      curve: Interval(
        duration.inMicroseconds == 0
            ? 0
            : delay.inMicroseconds / (duration + delay).inMicroseconds,
        1,
        curve: AppMotion.standard,
      ),
      builder: (context, t, _) => builder(context, (value * t).round()),
    );
  }
}
