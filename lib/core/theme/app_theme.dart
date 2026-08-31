import 'package:flutter/material.dart';

import 'app_colors_ext.dart';
import 'app_page_transitions.dart';
import 'app_palettes.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData build({required Brightness brightness}) {
    final colors = AppPalettes.forBrightness(brightness);
    final textTheme = buildAppTextTheme(colors: colors);

    final colorScheme = ColorScheme(
      brightness: brightness,
      surface: colors.background,
      onSurface: colors.textPrimary,
      primary: colors.accent,
      onPrimary: colors.onAccent,
      secondary: colors.accent,
      onSecondary: colors.onAccent,
      error: colors.danger,
      onError: colors.onAccent,
      surfaceContainerHighest: colors.surfaceVariant,
      outline: colors.divider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],
      // Ретро-интерфейс не «расплывается» под пальцем: вместо чернильной
      // волны Material — мгновенная смена состояния.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: colors.divider,
      textTheme: textTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PixelDissolvePageTransitionsBuilder(),
          TargetPlatform.linux: PixelDissolvePageTransitionsBuilder(),
          TargetPlatform.windows: PixelDissolvePageTransitionsBuilder(),
          TargetPlatform.macOS: PixelDissolvePageTransitionsBuilder(),
        },
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardMediumAll,
          side: BorderSide(color: colors.divider, width: 1),
        ),
      ),
      iconTheme: IconThemeData(color: colors.textPrimary),
      // Кнопки — почти квадратные, с пиксельной рамкой: блочный ретро-вид.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          disabledBackgroundColor: colors.surfaceVariant,
          disabledForegroundColor: colors.textTertiary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.xl,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.controlSmallAll,
          ),
          textStyle: textTheme.titleSmall,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.divider, width: AppRadius.pixelBorder),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.xl,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.controlSmallAll,
          ),
          textStyle: textTheme.titleSmall,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.controlSmallAll,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.controlSmallAll,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textTertiary),
        labelStyle: textTheme.labelMedium,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.controlSmallAll,
          borderSide: BorderSide(color: colors.divider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlSmallAll,
          borderSide: BorderSide(color: colors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlSmallAll,
          borderSide: BorderSide(color: colors.accent, width: AppRadius.pixelBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlSmallAll,
          borderSide: BorderSide(color: colors.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.controlSmallAll,
          borderSide: BorderSide(color: colors.danger, width: AppRadius.pixelBorder),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.accent
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(colors.onAccent),
        side: BorderSide(color: colors.divider, width: AppRadius.pixelBorder),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.controlNoneAll,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.onAccent
              : colors.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.accent
              : colors.surfaceVariant,
        ),
        trackOutlineColor: WidgetStateProperty.all(colors.divider),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.surfaceVariant,
        thumbColor: colors.accent,
        overlayColor: colors.accent.withValues(alpha: 0.12),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardLargeAll,
          side: BorderSide(color: colors.divider, width: AppRadius.pixelBorder),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.cardLarge),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.accent.withValues(alpha: 0.18),
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: AppRadius.controlSmallAll,
        ),
        labelTextStyle: WidgetStateProperty.all(textTheme.labelSmall),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.accent
                : colors.textTertiary,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceVariant,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.controlSmallAll,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondary,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.cardSmallAll,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.surfaceVariant,
        circularTrackColor: colors.surfaceVariant,
      ),
    );
  }

  /// Палитра без BuildContext — нужна на самом первом кадре и в тестах.
  static AppColorsExt colorsFor(Brightness brightness) =>
      AppPalettes.forBrightness(brightness);
}
