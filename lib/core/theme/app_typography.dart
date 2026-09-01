import 'package:flutter/material.dart';

import 'app_colors_ext.dart';

/// Типографика собрана из двух шрифтов:
///
///  * **Press Start 2P** — акцентные элементы: заголовки, цифры таймера,
///    счётчики. Настоящий пиксельный шрифт, он и задаёт всю стилистику.
///    Он крайне широкий и нечитаемый в длинных абзацах, поэтому — только
///    короткие строки.
///  * **Inter** — весь основной текст, описания, подписи. Читаемый гротеск,
///    тот же, что в остальных проектах TexFi.
///
/// Числовые стили (таймер, статистика) идут с табличными цифрами, чтобы
/// значение не «прыгало» по ширине на каждой смене секунды.
///
/// Оба шрифта лежат в `assets/fonts` и объявлены в pubspec, а не тянутся
/// `google_fonts` по сети. Приложение офлайновое: при недоступной сети
/// загрузка проваливалась молча, Flutter подставлял системный шрифт — и
/// заголовки с цифрами переставали быть пиксельными на всех экранах сразу.
/// Шрифт, на котором держится вся стилистика, не может зависеть от связи.
/// Пиксельный шрифт акцентных элементов — заголовки, цифры, счётчики.
const String pixelFontFamily = 'PressStart2P';

/// Основной текстовый шрифт — всё, что читается ради смысла.
const String sansFontFamily = 'Inter';

TextTheme buildAppTextTheme({required AppColorsExt colors}) {
  const tabular = [FontFeature.tabularFigures()];

  TextStyle pixel({
    required double size,
    required Color color,
    double? letterSpacing,
    double height = 1.4,
    List<FontFeature> features = const [],
  }) {
    return TextStyle(
      fontFamily: pixelFontFamily,
      fontSize: size,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFeatures: features,
    );
  }

  TextStyle sans({
    required double size,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
    double height = 1.35,
    List<FontFeature> features = const [],
  }) {
    return TextStyle(
      fontFamily: sansFontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFeatures: features,
    );
  }

  return TextTheme(
    // Цифры таймера — самый крупный элемент приложения.
    displayLarge: pixel(
      size: 40,
      color: colors.textPrimary,
      height: 1.1,
      features: tabular,
    ),
    // Крупные счётчики статистики и стрика.
    displayMedium: pixel(
      size: 22,
      color: colors.textPrimary,
      height: 1.2,
      features: tabular,
    ),
    // Средние числовые значения в карточках сводки.
    displaySmall: pixel(
      size: 14,
      color: colors.textPrimary,
      height: 1.3,
      features: tabular,
    ),
    // Заголовок экрана.
    headlineMedium: pixel(size: 14, color: colors.textPrimary),
    // Заголовок раздела/карточки.
    headlineSmall: pixel(size: 11, color: colors.textPrimary),
    // Подпись на кнопке — пиксельная, но мелкая.
    titleSmall: pixel(size: 9, color: colors.textPrimary, height: 1.5),

    titleMedium: sans(size: 16, weight: FontWeight.w600, color: colors.textPrimary),
    bodyLarge: sans(size: 15, weight: FontWeight.w400, color: colors.textPrimary),
    bodyMedium: sans(size: 14, weight: FontWeight.w400, color: colors.textSecondary),
    bodySmall: sans(
      size: 12,
      weight: FontWeight.w400,
      color: colors.textTertiary,
      letterSpacing: 0.2,
    ),
    labelLarge: sans(size: 14, weight: FontWeight.w600, color: colors.textPrimary),
    labelMedium: sans(
      size: 13,
      weight: FontWeight.w500,
      color: colors.textSecondary,
      letterSpacing: 0.1,
    ),
    // Числовые подписи в графиках: табличные цифры, обычный шрифт.
    labelSmall: sans(
      size: 11,
      weight: FontWeight.w500,
      color: colors.textTertiary,
      letterSpacing: 0.2,
      features: tabular,
    ),
  );
}
