import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Пресет акцентного тона.
///
/// Меняется ровно один цвет и два его производных — тень пиксельных кнопок
/// и подсветка сканлайнов. Всё остальное в палитре остаётся как было: смысл
/// пресета в том, чтобы интерфейс сменил настроение, а не рассыпался на
/// несогласованные цвета. Поэтому это перечисление, а не color picker.
enum AppAccent {
  /// Фирменный синий TexFi — общий для всей экосистемы, по умолчанию.
  blue(
    key: 'blue',
    color: AppColors.brandBlue,
    shadow: AppColors.brandBlueDeep,
    light: AppColors.brandBlueLight,
  ),

  mint(
    key: 'mint',
    color: Color(0xFF3ED598),
    shadow: Color(0xFF1F7F5B),
    light: Color(0xFF8FE9C4),
  ),

  amber(
    key: 'amber',
    color: Color(0xFFFFB648),
    shadow: Color(0xFFB37518),
    light: Color(0xFFFFD79A),
  ),

  magenta(
    key: 'magenta',
    color: Color(0xFFB980FF),
    shadow: Color(0xFF6F41B0),
    light: Color(0xFFD9B8FF),
  ),

  crimson(
    key: 'crimson',
    color: Color(0xFFFF6B6B),
    shadow: Color(0xFFB03B3B),
    light: Color(0xFFFFA8A8),
  );

  const AppAccent({
    required this.key,
    required this.color,
    required this.shadow,
    required this.light,
  });

  /// Стабильный ключ для настроек — порядок значений может измениться.
  final String key;

  final Color color;

  /// Глубокий оттенок: рамки и сплошные тени пиксельных кнопок.
  final Color shadow;

  /// Светлый оттенок: подсветка активных ячеек heatmap.
  final Color light;

  /// Полупрозрачная версия для сканлайнов фона.
  Color get scanline => color.withValues(alpha: 0.1);

  static AppAccent fromKey(String? key) {
    for (final accent in AppAccent.values) {
      if (accent.key == key) return accent;
    }
    return AppAccent.blue;
  }
}
