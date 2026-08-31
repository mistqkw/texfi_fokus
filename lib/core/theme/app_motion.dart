import 'package:flutter/animation.dart';

/// Длительности и кривые анимаций. Ретро-эффекты (pixel-dissolve, сканлайн)
/// держим короткими: стилистика должна читаться, а не задерживать пользователя.
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 300);

  /// Разовый акцент — вспышка при завершении цикла таймера.
  static const Duration flourish = Duration(milliseconds: 600);

  /// Переход между экранами с pixel-dissolve.
  static const Duration route = Duration(milliseconds: 260);

  /// Пиксельные анимации не сглаживаем по времени сильнее, чем нужно:
  /// «ступенчатость» — часть стиля.
  static const Curve standard = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
  static const Curve snap = Curves.easeOutBack;

  /// Задержка между появлением соседних элементов списка.
  static const Duration stagger = Duration(milliseconds: 40);
}
