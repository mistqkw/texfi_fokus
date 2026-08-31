import 'package:flutter/material.dart';

/// Именованный доступ к типографике поверх [TextTheme] — чтобы по экранам
/// не разъезжались размеры. Доступ из виджетов: `context.text`.
extension AppTextStylesContextX on BuildContext {
  AppTextStyles get text => AppTextStyles(Theme.of(this).textTheme);
}

class AppTextStyles {
  const AppTextStyles(this._tt);

  final TextTheme _tt;

  /// Цифры таймера — пиксельный шрифт, табличные цифры.
  TextStyle get timerDigits => _tt.displayLarge!;

  /// Крупный счётчик: стрик, «всего в фокусе».
  TextStyle get counterLarge => _tt.displayMedium!;

  /// Числовое значение в карточке сводки.
  TextStyle get counterMedium => _tt.displaySmall!;

  /// Заголовок экрана (пиксельный).
  TextStyle get headline => _tt.headlineMedium!;

  /// Заголовок раздела внутри экрана (пиксельный).
  TextStyle get sectionTitle => _tt.headlineSmall!;

  /// Подпись на пиксельной кнопке.
  TextStyle get pixelLabel => _tt.titleSmall!;

  /// Название элемента списка.
  TextStyle get title => _tt.titleMedium!;

  TextStyle get bodyLarge => _tt.bodyLarge!;
  TextStyle get body => _tt.bodyMedium!;
  TextStyle get caption => _tt.bodySmall!;
  TextStyle get label => _tt.labelMedium!;
  TextStyle get labelStrong => _tt.labelLarge!;

  /// Числовые подписи осей графиков.
  TextStyle get chartLabel => _tt.labelSmall!;
}
