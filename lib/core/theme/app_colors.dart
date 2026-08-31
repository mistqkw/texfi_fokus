import 'package:flutter/material.dart';

/// Цвета, не зависящие от выбранной темы. Используются там, где нет доступа
/// к BuildContext (сидинг БД, палитра категорий задач) и как единый источник
/// фирменного акцента для обеих тем.
abstract final class AppColors {
  /// Фирменный синий TexFi. Общий для всей экосистемы.
  static const Color brandBlue = Color(0xFF4A7DFB);

  /// Более глубокий оттенок акцента — рамки, тени пиксельных кнопок.
  static const Color brandBlueDeep = Color(0xFF2B4FB0);

  /// Светлый оттенок акцента — подсветка активных ячеек heatmap.
  static const Color brandBlueLight = Color(0xFF8FB0FF);

  static const Color moodBad = Color(0xFFFF6B6B);
  static const Color moodNeutral = Color(0xFFFFB648);
  static const Color moodGood = Color(0xFF3ED598);
  static const Color moodFullFokus = brandBlue;

  /// Порядок задаёт цвета категорий задач в графиках статистики.
  static const List<Color> categoryPalette = [
    brandBlue,
    Color(0xFF3ED598),
    Color(0xFFFFB648),
    Color(0xFFB980FF),
    Color(0xFF3ED5D5),
    Color(0xFFFF8FCF),
  ];
}
