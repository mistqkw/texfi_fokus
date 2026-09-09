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
/// Сетки 8×8 держат стилистику иконки приложения; там, где 8×8 не хватало на
/// читаемый силуэт (шестерёнка), взята 10×10 — глазом разницы в масштабе не
/// видно, а форма собирается.
abstract final class PixelSprites {
  // --- Нижняя навигация ---

  /// Главная: домик с дверью. Стены нарисованы контуром, а не заливкой —
  /// иначе на 20px силуэт схлопывался в сплошную арку.
  static const List<String> navHome = [
    '...xx...',
    '..xxxx..',
    '.xxxxxx.',
    'xxxxxxxx',
    '.x....x.',
    '.x.xx.x.',
    '.x.xx.x.',
    '.xxxxxx.',
  ];

  /// Привычки: рамка чекбокса с галочкой внутри.
  static const List<String> navHabits = [
    'xxxxxxxx',
    'x......x',
    'x.....xx',
    'x....xx.',
    'x.x.xx.x',
    'x.xxx..x',
    'x..x...x',
    'xxxxxxxx',
  ];

  /// Статистика: три столбика разной высоты.
  static const List<String> navStats = [
    '........',
    '......xx',
    '......xx',
    '...xx.xx',
    '...xx.xx',
    'xx.xx.xx',
    'xx.xx.xx',
    'xxxxxxxx',
  ];

  /// Настройки: шестерёнка. 10×10 — на 8×8 зубцы сливались с телом.
  static const List<String> navSettings = [
    '...xxxx...',
    '.x.xxxx.x.',
    '.xxxxxxxx.',
    'xxxx..xxxx',
    'xxx....xxx',
    'xxx....xxx',
    'xxxx..xxxx',
    '.xxxxxxxx.',
    '.x.xxxx.x.',
    '...xxxx...',
  ];

  // --- Общие элементы интерфейса ---

  /// Довольная «рожица» — тот же мотив, что в переключателе настроения.
  static const List<String> moodFace = [
    '........',
    '.xx..xx.',
    '.xx..xx.',
    '........',
    '.x....x.',
    '..xxxx..',
    '........',
    '........',
  ];

  /// Галочка — пиксельный чекбокс, «сыграно» в статистике.
  static const List<String> check = [
    '........',
    '.......x',
    '......xx',
    'x....xx.',
    'xx..xx..',
    '.xxxx...',
    '..xx....',
    '........',
  ];

  /// Треугольник «плей» на кнопке запуска сессии.
  static const List<String> play = [
    'xx......',
    'xxxx....',
    'xxxxxx..',
    'xxxxxxxx',
    'xxxxxxxx',
    'xxxxxx..',
    'xxxx....',
    'xx......',
  ];

  /// Две колонки — пауза.
  static const List<String> pause = [
    '.xx..xx.',
    '.xx..xx.',
    '.xx..xx.',
    '.xx..xx.',
    '.xx..xx.',
    '.xx..xx.',
    '.xx..xx.',
    '.xx..xx.',
  ];

  /// Сплошной квадрат — стоп.
  static const List<String> stop = [
    '........',
    '.xxxxxx.',
    '.xxxxxx.',
    '.xxxxxx.',
    '.xxxxxx.',
    '.xxxxxx.',
    '.xxxxxx.',
    '........',
  ];

  /// Треугольник с планкой — пропустить отрезок.
  static const List<String> skip = [
    'x....x..',
    'xx...xx.',
    'xxx..xxx',
    'xxxx.xxx',
    'xxxx.xxx',
    'xxx..xxx',
    'xx...xx.',
    'x....x..',
  ];

  /// Ползунки — ручная настройка сессии.
  static const List<String> sliders = [
    '..x.....',
    'xxxxxxxx',
    '..x.....',
    '........',
    '.....x..',
    'xxxxxxxx',
    '.....x..',
    '........',
  ];

  /// Песочные часы — логотип приложения.
  static const List<String> hourglass = [
    'xxxxxxxx',
    '.x....x.',
    '..x..x..',
    '...xx...',
    '...xx...',
    '..x..x..',
    '.x....x.',
    'xxxxxxxx',
  ];

  /// «Лампочка» инсайта: наблюдение о том, как человек работает.
  static const List<String> insight = [
    '..xxxx..',
    '.xxxxxx.',
    'xx.xx.xx',
    'xx.xx.xx',
    '.xxxxxx.',
    '..xxxx..',
    '..x..x..',
    '..xxxx..',
  ];

  /// Колокольчик напоминания.
  static const List<String> bell = [
    '...xx...',
    '..xxxx..',
    '.xxxxxx.',
    '.xxxxxx.',
    'xxxxxxxx',
    'xxxxxxxx',
    '........',
    '...xx...',
  ];

  /// Фотоаппарат — прикрепить снимок к сессии. Корпус, видоискатель сверху
  /// и объектив кольцом: на восьми клетках это единственная форма, которая
  /// читается камерой, а не просто прямоугольником.
  static const List<String> camera = [
    '........',
    '..xx....',
    'xxxxxxxx',
    'x..xx..x',
    'x.x..x.x',
    'x.x..x.x',
    'x..xx..x',
    'xxxxxxxx',
  ];

  /// Стрелка вниз — экспорт данных.
  static const List<String> download = [
    '...xx...',
    '...xx...',
    '...xx...',
    'x..xx..x',
    'xx.xx.xx',
    '.xxxxxx.',
    '..xxxx..',
    '...xx...',
  ];

  /// Стрелка вверх — импорт. Тот же силуэт, что у выгрузки, перевёрнутый:
  /// пара «вниз/вверх» читается быстрее любой другой метафоры.
  static const List<String> upload = [
    '...xx...',
    '..xxxx..',
    '.xxxxxx.',
    'xx.xx.xx',
    'x..xx..x',
    '...xx...',
    '...xx...',
    '...xx...',
  ];

  /// Плюс — добавление привычки.
  static const List<String> plus = [
    '........',
    '...xx...',
    '...xx...',
    'xxxxxxxx',
    'xxxxxxxx',
    '...xx...',
    '...xx...',
    '........',
  ];

  /// Лупа — фильтр длинного списка привычек.
  static const List<String> search = [
    '.xxxx...',
    'x....x..',
    'x....x..',
    'x....x..',
    '.xxxx...',
    '....xx..',
    '.....xx.',
    '......xx',
  ];

  /// Крестик — закрыть, снять, удалить строку. Самая частая иконка в
  /// приложении: до этого во всех шести местах стояла Material `Icons.close`,
  /// единственная сглаженная фигура среди рубленых.
  static const List<String> close = [
    '........',
    '.x....x.',
    '.xx..xx.',
    '..xxxx..',
    '..xxxx..',
    '.xx..xx.',
    '.x....x.',
    '........',
  ];

  /// Корзина — удаление привычки.
  static const List<String> trash = [
    '..xxxx..',
    'xxxxxxxx',
    '........',
    'xxxxxxxx',
    'x.x..x.x',
    'x.x..x.x',
    'x.x..x.x',
    '.xxxxxx.',
  ];

  /// Месяц — тихий (ночной) режим таймера.
  static const List<String> moon = [
    '..xxxx..',
    '.xx...x.',
    'xx......',
    'xx......',
    'xx......',
    'xx......',
    '.xx...x.',
    '..xxxx..',
  ];

  /// Углы рамки — разворот таймера на весь экран.
  static const List<String> fullscreen = [
    'xxx..xxx',
    'x......x',
    'x......x',
    '........',
    '........',
    'x......x',
    'x......x',
    'xxx..xxx',
  ];

  /// Минус — шаг вниз в ручной настройке сессии.
  static const List<String> minus = [
    '........',
    '........',
    '........',
    'xxxxxxxx',
    'xxxxxxxx',
    '........',
    '........',
    '........',
  ];

  /// Круговая стрелка — повторяемость привычки.
  static const List<String> repeat = [
    '..xxxx..',
    '.x....x.',
    'x......x',
    'x.......',
    'x......x',
    '.x....x.',
    '..xxxx..',
    '....x...',
  ];

  /// Зарубка — мелкая метка долгого стрика. Нарочно самая незаметная фигура
  /// в наборе: она стоит рядом с названием привычки и не должна с ним
  /// соперничать.
  static const List<String> notch = [
    '...xx...',
    '...xx...',
    '.x.xx.x.',
    '.xxxxxx.',
    '..xxxx..',
    '.xx..xx.',
    '.x....x.',
    '........',
  ];
}
