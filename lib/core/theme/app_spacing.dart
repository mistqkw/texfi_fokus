import 'package:flutter/widgets.dart';

/// Единая шкала отступов — сетка 4pt. Все расстояния берутся отсюда, а не
/// подбираются на глаз: иначе одно и то же «немного отступить» на разных
/// экранах превращается в 6, 8 и 10 пикселей.
abstract final class AppSpacing {
  /// 4 — микро-зазор: между пиксельной иконкой и её подписью.
  static const double xs = 4;

  /// 8 — зазор внутри одного смыслового блока (подпись → поле).
  static const double sm = 8;

  /// 12 — между соседними карточками в списке.
  static const double md = 12;

  /// 16 — между блоками одного раздела.
  static const double lg = 16;

  /// 20 — горизонтальные поля экрана.
  static const double page = 20;

  /// 24 — между разделами формы.
  static const double xl = 24;

  /// 32 — перед итоговым действием, вокруг пустых состояний.
  static const double xxl = 32;

  /// 40 — крупная пауза на онбординге и экране таймера.
  static const double huge = 40;

  /// Нижний отступ списков с плавающей кнопкой: FAB (56) + поля.
  static const double fabSafeBottom = 96;

  static const EdgeInsets screen = EdgeInsets.fromLTRB(page, sm, page, xxl);

  static const EdgeInsets screenWithFab =
      EdgeInsets.fromLTRB(page, sm, page, fabSafeBottom);

  static const EdgeInsets card = EdgeInsets.all(lg);

  static const Widget gapXs = SizedBox(height: xs);
  static const Widget gapSm = SizedBox(height: sm);
  static const Widget gapMd = SizedBox(height: md);
  static const Widget gapLg = SizedBox(height: lg);
  static const Widget gapXl = SizedBox(height: xl);
  static const Widget gapXxl = SizedBox(height: xxl);

  static const Widget wGapXs = SizedBox(width: xs);
  static const Widget wGapSm = SizedBox(width: sm);
  static const Widget wGapMd = SizedBox(width: md);
  static const Widget wGapLg = SizedBox(width: lg);
}
