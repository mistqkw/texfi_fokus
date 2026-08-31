import 'package:flutter/material.dart';

import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';

/// Карточка приложения: умеренно скруглённая (8–12), с пиксельной рамкой
/// в 2px. Рамка, а не тень — тени в ретро-эстетике выглядят чужеродно.
class PixelCard extends StatelessWidget {
  const PixelCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.onTap,
    this.accent = false,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  /// Выделенная карточка — рамка фирменным синим.
  final bool accent;

  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final border = borderColor ?? (accent ? colors.accent : colors.divider);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
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

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.cardMediumAll,
      child: content,
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
