import 'package:flutter/material.dart';

/// Спрайт, нарисованный по текстовой сетке: `'.'` — пусто, `'o'` —
/// полутон, всё остальное — закрашенный пиксель.
///
/// Полутон появился ради игрового слоя. Существо в двенадцати клетках
/// одной заливкой — это силуэт и ничего больше: у него не бывает ни глаза,
/// ни складки, ни перепонки, потому что любая внутренняя деталь либо
/// сливается с телом, либо прорезает в нём дыру и разваливает силуэт.
/// Второй тон даёт третье состояние клетки, и этого хватает на детали, не
/// теряя при этом жёсткого края.
///
/// Это единственный способ рисовать иконки в приложении: никаких PNG в
/// assets и никакого Material-набора там, где элемент должен читаться как
/// часть ретро-интерфейса. Сетка живёт в коде, поэтому иконку можно
/// перерисовать в редакторе, а не в графическом пакете.
///
/// Раньше та же логика лежала приватной копией в `mood_switcher.dart` и
/// `onboarding_screen.dart`; теперь ей пользуются и они, и таббар.
class PixelSprite extends StatelessWidget {
  const PixelSprite({
    super.key,
    required this.rows,
    required this.color,
    this.size = 24,
  });

  /// Квадратная сетка: строк столько же, сколько символов в строке.
  final List<String> rows;

  final Color color;

  /// Сторона квадрата в логических пикселях.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PixelSpritePainter(rows: rows, color: color),
      ),
    );
  }
}

/// Отрисовщик сетки. Публичный: его использует и [PixelSprite], и места,
/// где спрайт вписывается в уже готовый `SizedBox`/`AspectRatio`.
class PixelSpritePainter extends CustomPainter {
  const PixelSpritePainter({required this.rows, required this.color});

  final List<String> rows;
  final Color color;

  /// Насколько бледнее полутон.
  ///
  /// Подбиралось по размеру существа на карте, а не по крупному спрайту в
  /// бою: там клетка — меньше трёх пикселей, и разница должна оставаться
  /// заметной. Ниже трети полутон пропадает на светлой теме, выше половины
  /// перестаёт отличаться от заливки.
  static const double shadeAlpha = 0.42;

  @override
  void paint(Canvas canvas, Size size) {
    if (rows.isEmpty) return;
    final cell = size.width / rows.length;
    final solid = Paint()..color = color;
    // Полутон — тот же цвет, а не серый: спрайту цвет задают снаружи, и он
    // меняется вместе с миром, состоянием узла и темой. Серый на цветном
    // выглядел бы грязью.
    final shade = Paint()..color = color.withValues(alpha: shadeAlpha);
    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      for (var x = 0; x < row.length; x++) {
        final paint = switch (row[x]) {
          '.' => null,
          'o' => shade,
          _ => solid,
        };
        if (paint == null) continue;
        // Ячейки рисуются с нахлёстом в полпикселя: иначе между соседними
        // прямоугольниками на дробном devicePixelRatio видны швы.
        canvas.drawRect(
          Rect.fromLTWH(x * cell, y * cell, cell + 0.5, cell + 0.5),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PixelSpritePainter oldDelegate) =>
      oldDelegate.rows != rows || oldDelegate.color != color;
}

/// Каталог спрайтов приложения.
///
/// Сетка у всех одна — 12×12. Было 8×8 и местами 10×10, и это не работало
/// по двум причинам сразу. На восьми клетках у иконки нет места ни на одну
/// деталь сверх силуэта: колокольчик, лампочка и корзина превращались в три
/// похожих пятна, а шестерёнка настроек на двадцати пикселях — в кашу.
/// Разнобой же сеток означал, что одна и та же иконка в разных местах
/// экрана выглядит разной толщины.
///
/// Двенадцать клеток дают деталь, а полутон — вторую глубину: у дома есть
/// окна, у камеры объектив, у месяца край. И ровно двенадцать не случайно:
/// самый частый размер иконки здесь — двенадцать пикселей, то есть клетка
/// приходится ровно на пиксель экрана.
abstract final class PixelSprites {
  // --- Нижняя навигация ---

  /// Главная: домик с дверью. Стены нарисованы контуром, а не заливкой —
  /// иначе на 20px силуэт схлопывался в сплошную арку.
  static const List<String> navHome = [
    '.....xx.....',
    '....xxxx....',
    '...xxxxxx...',
    '..xxxxxxxx..',
    '.xxxxxxxxxx.',
    'xxxxxxxxxxxx',
    '.x........x.',
    '.x.oo..oo.x.',
    '.x.oo..oo.x.',
    '.x...xx...x.',
    '.x...xx...x.',
    '.xxxxxxxxxx.',
  ];

  /// Привычки: рамка чекбокса с галочкой внутри.
  static const List<String> navHabits = [
    'xxxxxxxxxxxx',
    'xoooooooooox',
    'xoo......oox',
    'xoo.....xxox',
    'xoo....xxoox',
    'xoo...xxo.ox',
    'xoox.xxo..ox',
    'xooxxxxo..ox',
    'xoo.xxo...ox',
    'xoo..o....ox',
    'xoooooooooox',
    'xxxxxxxxxxxx',
  ];

  /// Статистика: три столбика разной высоты.
  static const List<String> navStats = [
    '............',
    '.o.........o',
    '.o.......xxx',
    '.o.......xxx',
    '.o....xx.xxx',
    '.o....xx.xxx',
    '.o.xxxxx.xxx',
    '.o.xxxxx.xxx',
    '.oxxxxxxxxxx',
    '.oxxxxxxxxxx',
    '.xxxxxxxxxxx',
    '............',
  ];

  /// Настройки: шестерёнка. 10×10 — на 8×8 зубцы сливались с телом.
  static const List<String> navSettings = [
    '....xxxx....',
    '.x..xoox..x.',
    '.xx..xx..xx.',
    '..xxo..oxx..',
    'xxxo....oxxx',
    'xxo......oxx',
    'xxo......oxx',
    'xxxo....oxxx',
    '..xxo..oxx..',
    '.xx..xx..xx.',
    '.x..xoox..x.',
    '....xxxx....',
  ];

  // --- Общие элементы интерфейса ---

  /// Довольная «рожица» — тот же мотив, что в переключателе настроения.
  static const List<String> moodFace = [
    '...xxxxxx...',
    '..xoooooox..',
    '.xo......ox.',
    'xo..xx.xx.ox',
    'xo..xx.xx.ox',
    'xo........ox',
    'xox......xox',
    'xo.xx..xx.ox',
    '.xo.xxxx.ox.',
    '..xoooooox..',
    '...xxxxxx...',
    '............',
  ];

  /// Галочка — пиксельный чекбокс, «сыграно» в статистике.
  static const List<String> check = [
    '............',
    '..........xx',
    '.........xxo',
    '........xxo.',
    'xx.....xxo..',
    'xxx...xxo...',
    '.xxx.xxo....',
    '..xxxxo.....',
    '...xxo......',
    '....o.......',
    '............',
    '............',
  ];

  /// Треугольник «плей» на кнопке запуска сессии.
  static const List<String> play = [
    'xx..........',
    'xxxx........',
    'xxxxxx......',
    'xxxxxxxx....',
    'xxxxxxxxxx..',
    'xxxxxxxxxxxx',
    'xxxxxxxxxxxx',
    'xxxxxxxxxx..',
    'xxxxxxxxo...',
    'xxxxxxo.....',
    'xxxxo.......',
    'xxo.........',
  ];

  /// Две колонки — пауза.
  static const List<String> pause = [
    '..xxx..xxx..',
    '..xox..xox..',
    '..xox..xox..',
    '..xox..xox..',
    '..xox..xox..',
    '..xox..xox..',
    '..xox..xox..',
    '..xox..xox..',
    '..xox..xox..',
    '..xox..xox..',
    '..xox..xox..',
    '..xxx..xxx..',
  ];

  /// Сплошной квадрат — стоп.
  static const List<String> stop = [
    '............',
    '.xxxxxxxxxx.',
    '.xoooooooox.',
    '.xoxxxxxxox.',
    '.xoxxxxxxox.',
    '.xoxxxxxxox.',
    '.xoxxxxxxox.',
    '.xoxxxxxxox.',
    '.xoxxxxxxox.',
    '.xoooooooox.',
    '.xxxxxxxxxx.',
    '............',
  ];

  /// Треугольник с планкой — пропустить отрезок.
  static const List<String> skip = [
    'xx.......xx.',
    'xxxx.....xx.',
    'xxxxxx...xx.',
    'xxxxxxxx.xx.',
    'xxxxxxxxxxx.',
    'xxxxxxxxxxx.',
    'xxxxxxxxxxx.',
    'xxxxxxxxxxx.',
    'xxxxxxxx.xx.',
    'xxxxxo...xx.',
    'xxxo.....xx.',
    'xo.......xx.',
  ];

  /// Ползунки — ручная настройка сессии.
  static const List<String> sliders = [
    '............',
    '...xx.......',
    'xxxxxxxxxxxx',
    'xxxxxxxxxxxx',
    '...xx.......',
    '............',
    '............',
    '.......xx...',
    'xxxxxxxxxxxx',
    'xxxxxxxxxxxx',
    '.......xx...',
    '............',
  ];

  /// Песочные часы — логотип приложения.
  static const List<String> hourglass = [
    'xxxxxxxxxxxx',
    'xxxxxxxxxxxx',
    '.xoooooooox.',
    '..xoooooox..',
    '...xoooox...',
    '....xoox....',
    '....xoox....',
    '...xxxxxx...',
    '..xxxxxxxx..',
    '.xxxxxxxxxx.',
    'xxxxxxxxxxxx',
    'xxxxxxxxxxxx',
  ];

  /// «Лампочка» инсайта: наблюдение о том, как человек работает.
  static const List<String> insight = [
    '...xxxxxx...',
    '..xxxxxxxx..',
    '.xxo....oxx.',
    'xxo......oxx',
    'xxo......oxx',
    'xxo......oxx',
    '.xxo....oxx.',
    '..xxxxxxxx..',
    '...xoooox...',
    '...xxxxxx...',
    '....xxxx....',
    '.....xx.....',
  ];

  /// Колокольчик напоминания.
  static const List<String> bell = [
    '.....xx.....',
    '....xxxx....',
    '...xxooxx...',
    '..xxooooxx..',
    '..xxooooxx..',
    '.xxooooooxx.',
    '.xxooooooxx.',
    'xxxxxxxxxxxx',
    'xxxxxxxxxxxx',
    '............',
    '....xxxx....',
    '.....xx.....',
  ];

  /// Фотоаппарат — прикрепить снимок к сессии. Корпус, видоискатель сверху
  /// и объектив кольцом: на восьми клетках это единственная форма, которая
  /// читается камерой, а не просто прямоугольником.
  static const List<String> camera = [
    '............',
    '..xxx.......',
    '..xox.......',
    'xxxxxxxxxxxx',
    'xo........ox',
    'xo..xxxx..ox',
    'xo.xxooxx.ox',
    'xo.xxooxx.ox',
    'xo..xxxx..ox',
    'xo........ox',
    'xxxxxxxxxxxx',
    '............',
  ];

  /// Стрелка вниз — экспорт данных.
  static const List<String> download = [
    '.....xx.....',
    '.....xx.....',
    '.....xx.....',
    '.....xx.....',
    '.....xx.....',
    'xo...xx...ox',
    'xxo..xx..oxx',
    '.xxo.xx.oxx.',
    '..xxxxxxxx..',
    '...xxxxxx...',
    '....xxxx....',
    '.....xx.....',
  ];

  /// Стрелка вверх — импорт. Тот же силуэт, что у выгрузки, перевёрнутый:
  /// пара «вниз/вверх» читается быстрее любой другой метафоры.
  static const List<String> upload = [
    '.....xx.....',
    '....xxxx....',
    '...xxxxxx...',
    '..xxxxxxxx..',
    '.xxo.xx.oxx.',
    'xxo..xx..oxx',
    'xo...xx...ox',
    '.....xx.....',
    '.....xx.....',
    '.....xx.....',
    '.....xx.....',
    '.....xx.....',
  ];

  /// Плюс — добавление привычки.
  static const List<String> plus = [
    '............',
    '.....xx.....',
    '.....xx.....',
    '.....xx.....',
    '.....xx.....',
    '.xxxxxxxxxx.',
    '.xxxxxxxxxx.',
    '.....xx.....',
    '.....xx.....',
    '.....xx.....',
    '.....xx.....',
    '............',
  ];

  /// Лупа — фильтр длинного списка привычек.
  static const List<String> search = [
    '..xxxxxx....',
    '.xxoooo.x...',
    'xxo....oxx..',
    'xo......ox..',
    'xo......ox..',
    'xo......ox..',
    'xxo....oxx..',
    '.xxoooooxx..',
    '..xxxxxxxx..',
    '.......xxxx.',
    '........xxxx',
    '.........xxx',
  ];

  /// Крестик — закрыть, снять, удалить строку. Самая частая иконка в
  /// приложении: до этого во всех шести местах стояла Material `Icons.close`,
  /// единственная сглаженная фигура среди рубленых.
  static const List<String> close = [
    '............',
    '.xx......xx.',
    '.xxo....oxx.',
    '..xxo..oxx..',
    '...xxooxx...',
    '....xxxx....',
    '....xxxx....',
    '...xxooxx...',
    '..xxo..oxx..',
    '.xxo....oxx.',
    '.xx......xx.',
    '............',
  ];

  /// Корзина — удаление привычки.
  static const List<String> trash = [
    '....xxxx....',
    '..xxxxxxxx..',
    'xxxxxxxxxxxx',
    '............',
    'xxxxxxxxxxxx',
    'xoxo.xx.oxox',
    'xoxo.xx.oxox',
    'xoxo.xx.oxox',
    'xoxo.xx.oxox',
    'xoxo.xx.oxox',
    '.xxxxxxxxxx.',
    '..xxxxxxxx..',
  ];

  /// Месяц — тихий (ночной) режим таймера.
  static const List<String> moon = [
    '...xxxxxx...',
    '..xxxxxxo...',
    '.xxxxxo.....',
    'xxxxxo......',
    'xxxxo.......',
    'xxxxo.......',
    'xxxxo.......',
    'xxxxo.......',
    'xxxxxo......',
    '.xxxxxo.....',
    '..xxxxxxo...',
    '...xxxxxx...',
  ];

  /// Углы рамки — разворот таймера на весь экран.
  static const List<String> fullscreen = [
    'xxxx....xxxx',
    'xxxx....xxxx',
    'xxo......oxx',
    'xo........ox',
    '............',
    '............',
    '............',
    '............',
    'xo........ox',
    'xxo......oxx',
    'xxxx....xxxx',
    'xxxx....xxxx',
  ];

  /// Минус — шаг вниз в ручной настройке сессии.
  static const List<String> minus = [
    '............',
    '............',
    '............',
    '............',
    '............',
    '.xxxxxxxxxx.',
    '.xxxxxxxxxx.',
    '............',
    '............',
    '............',
    '............',
    '............',
  ];

  /// Круговая стрелка — повторяемость привычки.
  static const List<String> repeat = [
    '...xxxxxx...',
    '..xxoooxxx..',
    '.xxo....oxx.',
    'xxo......oxx',
    'xo..........',
    'xo..........',
    'xo..........',
    'xxo......oxx',
    '.xxo....oxx.',
    '..xxoooxxx..',
    '...xxxxxx...',
    '.....xxo....',
  ];

  /// Зарубка — мелкая метка долгого стрика. Нарочно самая незаметная фигура
  /// в наборе: она стоит рядом с названием привычки и не должна с ним
  /// соперничать.
  static const List<String> notch = [
    '.....xx.....',
    '.....xx.....',
    '..o..xx..o..',
    '..xo.xx.ox..',
    '..xxxxxxxx..',
    '...xxxxxx...',
    '..xxo..oxx..',
    '..xo....ox..',
    '..o......o..',
    '............',
    '............',
    '............',
  ];
}
