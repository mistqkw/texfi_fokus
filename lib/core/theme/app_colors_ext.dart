import 'package:flutter/material.dart';

/// Семантические цвета темы. Доступ из виджетов — `context.colors`.
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  const AppColorsExt({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.divider,
    required this.accent,
    required this.onAccent,
    required this.accentShadow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.moodBad,
    required this.moodNeutral,
    required this.moodGood,
    required this.moodFullFokus,
    required this.noise,
    required this.scanline,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color divider;
  final Color accent;
  final Color onAccent;

  /// Тень «пиксельной» кнопки — сплошной прямоугольник со смещением,
  /// как у ретро-интерфейсов, вместо мягкого blur.
  final Color accentShadow;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color success;
  final Color warning;
  final Color danger;

  final Color moodBad;
  final Color moodNeutral;
  final Color moodGood;
  final Color moodFullFokus;

  /// Цвет пиксельного крапа на фоне — очень низкая альфа, чтобы текстура
  /// читалась, но не мешала тексту.
  final Color noise;

  /// Цвет горизонтальных «сканлайнов» в переходах между экранами.
  final Color scanline;

  /// Редкая окраска: один и тот же жёлтый в обеих темах.
  ///
  /// Не поле расширения, а константа: он не участвует в палитрах и не
  /// перекрашивается вместе с акцентом — в этом весь смысл. Достаточно
  /// светлый, чтобы читаться на тёмном фоне, и достаточно насыщенный,
  /// чтобы не теряться на светлом.
  static const Color rareGold = Color(0xFFF2B01E);

  /// Цвет состояния настроения по его индексу 0..3.
  Color moodByIndex(int index) => switch (index) {
        0 => moodBad,
        1 => moodNeutral,
        2 => moodGood,
        _ => moodFullFokus,
      };

  @override
  AppColorsExt copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? divider,
    Color? accent,
    Color? onAccent,
    Color? accentShadow,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? moodBad,
    Color? moodNeutral,
    Color? moodGood,
    Color? moodFullFokus,
    Color? noise,
    Color? scanline,
  }) {
    return AppColorsExt(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      divider: divider ?? this.divider,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentShadow: accentShadow ?? this.accentShadow,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      moodBad: moodBad ?? this.moodBad,
      moodNeutral: moodNeutral ?? this.moodNeutral,
      moodGood: moodGood ?? this.moodGood,
      moodFullFokus: moodFullFokus ?? this.moodFullFokus,
      noise: noise ?? this.noise,
      scanline: scanline ?? this.scanline,
    );
  }

  @override
  AppColorsExt lerp(ThemeExtension<AppColorsExt>? other, double t) {
    if (other is! AppColorsExt) return this;
    return AppColorsExt(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentShadow: Color.lerp(accentShadow, other.accentShadow, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      moodBad: Color.lerp(moodBad, other.moodBad, t)!,
      moodNeutral: Color.lerp(moodNeutral, other.moodNeutral, t)!,
      moodGood: Color.lerp(moodGood, other.moodGood, t)!,
      moodFullFokus: Color.lerp(moodFullFokus, other.moodFullFokus, t)!,
      noise: Color.lerp(noise, other.noise, t)!,
      scanline: Color.lerp(scanline, other.scanline, t)!,
    );
  }
}

extension AppColorsContextX on BuildContext {
  AppColorsExt get colors => Theme.of(this).extension<AppColorsExt>()!;
}
