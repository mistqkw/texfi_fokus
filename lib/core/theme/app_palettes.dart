import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_colors_ext.dart';

/// Две палитры приложения. Обе — пиксель-арт, но в разных ключах:
/// тёмная — чёрный + серый + фирменный синий (ретро-CRT), светлая — тёплая
/// оранжево-бежевая (ретро-бумага, Game Boy на солнце).
abstract final class AppPalettes {
  static const AppColorsExt dark = AppColorsExt(
    background: Color(0xFF0B0B0E),
    surface: Color(0xFF15151A),
    surfaceVariant: Color(0xFF1F1F26),
    divider: Color(0xFF2C2C35),
    accent: AppColors.brandBlue,
    onAccent: Color(0xFF06070C),
    accentShadow: AppColors.brandBlueDeep,
    textPrimary: Color(0xFFF2F3F7),
    textSecondary: Color(0xFF9A9AA8),
    textTertiary: Color(0xFF5C5C68),
    success: Color(0xFF3ED598),
    warning: Color(0xFFFFB648),
    danger: Color(0xFFFF6B6B),
    moodBad: AppColors.moodBad,
    moodNeutral: AppColors.moodNeutral,
    moodGood: AppColors.moodGood,
    moodFullFokus: AppColors.moodFullFokus,
    noise: Color(0x0DFFFFFF),
    scanline: Color(0x1A4A7DFB),
  );

  static const AppColorsExt light = AppColorsExt(
    background: Color(0xFFFCF5E9),
    surface: Color(0xFFFFFBF3),
    surfaceVariant: Color(0xFFF3E6D2),
    divider: Color(0xFFE0CDB0),
    accent: AppColors.brandBlue,
    onAccent: Color(0xFFFFFBF3),
    accentShadow: Color(0xFFD98A2B),
    textPrimary: Color(0xFF2A1F14),
    textSecondary: Color(0xFF6E5B45),
    textTertiary: Color(0xFFA08D72),
    success: Color(0xFF1B9E66),
    warning: Color(0xFFD98A2B),
    danger: Color(0xFFD64545),
    moodBad: Color(0xFFD64545),
    moodNeutral: Color(0xFFD98A2B),
    moodGood: Color(0xFF1B9E66),
    moodFullFokus: AppColors.brandBlue,
    noise: Color(0x0F8A6A3D),
    scanline: Color(0x14D98A2B),
  );

  static AppColorsExt forBrightness(Brightness brightness) =>
      brightness == Brightness.light ? light : dark;
}
