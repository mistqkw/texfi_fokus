import 'package:flutter/material.dart';

import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import 'pixel_shadow.dart';

/// Карточка приложения: умеренно скруглённая (8–12), с пиксельной рамкой
/// в 2px и сплошной ретро-тенью со смещением — тем же приёмом, что у
/// [PixelButton], а не мягким Material-блюром.
///
/// [raised] отвечает за тень. По умолчанию она есть: без неё карточки
/// читались как плоские прямоугольники и весь пиксельный «объём»
/// оставался только на одной кнопке. Выключать её стоит там, где карточка
/// вложена в другую или прижата к краю экрана.
class PixelCard extends StatelessWidget {
  const PixelCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.onTap,
    this.onLongPress,
    this.accent = false,
    this.borderColor,
    this.raised = true,
    this.background,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  /// Долгое нажатие — для второстепенного действия, которому не место в
  /// постоянно видимой кнопке.
  final VoidCallback? onLongPress;

  /// Выделенная карточка — рамка фирменным синим.
  final bool accent;

  final Color? borderColor;
  final Color? background;

  /// Сплошная тень со смещением.
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final border = borderColor ?? (accent ? colors.accent : colors.divider);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? colors.surface,
        borderRadius: AppRadius.cardMediumAll,
        border: Border.all(color: border, width: AppRadius.pixelBorder),
      ),
      // ListTile и прочие Material-виджеты рисуют фон и отклик на ближайшем
      // Material-предке. Без этой прослойки они оказались бы под заливкой
      // карточки, и Flutter справедливо об этом ругается.
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );

    final tappable = onTap == null && onLongPress == null
        ? content
        : InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: AppRadius.cardMediumAll,
            child: content,
          );

    if (!raised) return tappable;

    // Тень карточки — приглушённый вариант её же рамки: у акцентной
    // карточки синяя, у обычной цвет разделителя. Так «объём» появляется
    // везде, но не превращает список в лес одинаковых плашек.
    return PixelShadowBox(
      shadowColor: accent
          ? colors.accentShadow
          : (borderColor ?? colors.divider),
      borderRadius: AppRadius.cardMediumAll,
      child: tappable,
    );
  }
}

/// Заголовок раздела пиксельным шрифтом с короткой «линейкой» справа —
/// разделяет экран на блоки без тяжёлых контейнеров.
class PixelSectionHeader extends StatelessWidget {
  const PixelSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: context.text.sectionTitle),
          AppSpacing.wGapMd,
          Expanded(
            child: Container(height: 2, color: colors.divider),
          ),
          if (trailing != null) ...[
            AppSpacing.wGapMd,
            trailing!,
          ],
        ],
      ),
    );
  }
}
