import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors_ext.dart';

/// Как выглядит конкретный мир на карте.
///
/// Отдельный файл, а не пара `switch` внутри экрана карты, по той же причине,
/// по которой у мира есть своё описание в правилах: «чем второй мир отличается от
/// третьего» — это одно решение, а не три разбросанных по виджетам.
///
/// Ограничение здесь важнее самой идеи: мир меняет **оттенок**, а не палитру.
/// Тёмная тема остаётся чёрно-серо-синей, светлая — оранжево-бежевой, и ни
/// один мир не имеет права выглядеть как другое приложение. Всё, что ниже,
/// живёт на альфе в районе одной десятой и читается боковым зрением.
abstract final class WorldStyle {
  /// Тон третьего мира. Единственный цвет, которого нет в палитре.
  ///
  /// «Длинный зал» — про монотонность и усталость, и ни акцентный синий
  /// (бодрый), ни янтарный (тревожный), ни зелёный (успех) этого не говорят.
  /// Пыльный индиго — соседний с фирменным синим тон, у которого убрана
  /// насыщенность: на фоне в 8% альфы он читается не как «другой цвет», а
  /// как выцветший тот же самый.
  static const Color _dustyIndigo = Color(0xFF6E6A94);

  /// Оттенок мира. Берётся из темы, а не задан константами: в светлой теме
  /// янтарный другой, и мир обязан меняться вместе с ней.
  ///
  /// Миры за пределами написанных возвращают акцент — честный нейтральный
  /// вариант. Придумать четвёртому миру характер до того, как у него
  /// появятся дриферы, значило бы решить за ещё не написанный контент.
  static Color tint(AppColorsExt colors, int world) => switch (world) {
        // Тихая комната — тот же акцент, что и везде. Первый мир не должен
        // выглядеть «покрашенным»: он задаёт норму, от которой отличаются
        // остальные.
        1 => colors.accent,

        // Громкое поле — янтарный. Тот же цвет, которым приложение помечает
        // «обрати внимание», и здесь он значит ровно это.
        2 => colors.warning,

        3 => _dustyIndigo,
        _ => colors.accent,
      };

  /// Насколько плотно мир «дышит» фоном. 0 — фон чистый.
  ///
  /// Первый мир почти пуст намеренно: тишина — это его содержание, и
  /// насыпать в неё крапа значило бы поспорить с собственным эпиграфом.
  static double density(int world) => switch (world) {
        1 => 0.35,
        2 => 1.0,
        3 => 0.7,
        _ => 0.5,
      };

  /// Как разложен фоновый крап. Не украшение ради украшения: расположение
  /// точек — это то же самое высказывание, что и имя мира.
  static WorldAtmosphereKind atmosphere(int world) => switch (world) {
        1 => WorldAtmosphereKind.scattered,
        2 => WorldAtmosphereKind.streaks,
        3 => WorldAtmosphereKind.columns,
        _ => WorldAtmosphereKind.scattered,
      };
}

/// Характер фонового крапа мира.
enum WorldAtmosphereKind {
  /// Редкие одиночные точки, разбросанные ровно. Тихая комната: пылинки в
  /// воздухе, и больше ничего не происходит.
  scattered,

  /// Короткие горизонтальные росчерки. Громкое поле: что-то всё время
  /// проносится мимо слева направо.
  streaks,

  /// Вертикальные ряды одинаковых отметин. Длинный зал: одно и то же,
  /// повторённое столько раз, что перестаёшь считать.
  columns,
}

/// Фон одного мира на карте: разреженный пиксельный крап в оттенке мира.
///
/// Рисуется [CustomPainter] и не анимируется. Оба решения намеренные:
/// живущий своей жизнью фон под списком узлов — это движение на периферии
/// зрения на экране приложения, которое просит сосредоточиться. Атмосфера
/// здесь работает как текстура бумаги, а не как заставка.
class WorldAtmosphere extends StatelessWidget {
  const WorldAtmosphere({super.key, required this.world});

  final int world;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColorsExt>()!;
    return CustomPaint(
      painter: _WorldAtmospherePainter(
        color: WorldStyle.tint(colors, world),
        kind: WorldStyle.atmosphere(world),
        density: WorldStyle.density(world),
        seed: world,
      ),
    );
  }
}

class _WorldAtmospherePainter extends CustomPainter {
  const _WorldAtmospherePainter({
    required this.color,
    required this.kind,
    required this.density,
    required this.seed,
  });

  final Color color;
  final WorldAtmosphereKind kind;
  final double density;
  final int seed;

  /// Сторона одной отметины. Ровно та же, что у клеток тропы и полосок
  /// прогресса: фон должен быть сделан из того же материала, что и всё
  /// остальное на экране, иначе он читается как чужая картинка под ним.
  static const double _cell = 3;

  /// Потолок альфы. Выше этого крап перестаёт быть фоном и начинает
  /// конкурировать с подписями узлов — а подписи здесь главнее.
  static const double _maxOpacity = 0.11;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || density <= 0) return;

    // Зерно от номера мира: расположение точек постоянно между кадрами,
    // перестроениями и запусками. Крап, который перетасовывается на каждой
    // перерисовке, — это мерцание, а не текстура.
    final random = Random(seed * 7919);
    final paint = Paint()..color = color.withValues(alpha: _maxOpacity);

    switch (kind) {
      case WorldAtmosphereKind.scattered:
        final count = (size.height * density / 18).round();
        for (var i = 0; i < count; i++) {
          canvas.drawRect(
            Rect.fromLTWH(
              (random.nextDouble() * size.width).floorToDouble(),
              (random.nextDouble() * size.height).floorToDouble(),
              _cell,
              _cell,
            ),
            paint,
          );
        }

      case WorldAtmosphereKind.streaks:
        // Росчерк — три-шесть клеток подряд с пропусками: не линия, а
        // обрывок движения.
        final count = (size.height * density / 26).round();
        for (var i = 0; i < count; i++) {
          final y = (random.nextDouble() * size.height).floorToDouble();
          final x = (random.nextDouble() * size.width * 0.85).floorToDouble();
          final length = 3 + random.nextInt(4);
          for (var c = 0; c < length; c++) {
            // Пропуск внутри росчерка: сплошная полоска выглядела бы
            // подчёркиванием, а не шумом.
            if (random.nextInt(4) == 0) continue;
            canvas.drawRect(
              Rect.fromLTWH(x + c * (_cell + 2), y, _cell, _cell),
              paint,
            );
          }
        }

      case WorldAtmosphereKind.columns:
        // Колонны стоят на строгой сетке, и в этом всё дело: единственный
        // мир, чей фон повторяется без вариаций.
        const spacing = 34.0;
        final columns = (size.width / spacing).floor();
        final steps = (size.height / spacing).floor();
        for (var cx = 0; cx <= columns; cx++) {
          for (var cy = 0; cy <= steps; cy++) {
            // Прореживание по плотности — детерминированное, из того же
            // генератора: сетка остаётся сеткой, но не сплошной.
            if (random.nextDouble() > density) continue;
            canvas.drawRect(
              Rect.fromLTWH(cx * spacing, cy * spacing, _cell, _cell * 2),
              paint,
            );
          }
        }
    }
  }

  @override
  bool shouldRepaint(_WorldAtmospherePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.kind != kind ||
      oldDelegate.density != density ||
      oldDelegate.seed != seed;
}
