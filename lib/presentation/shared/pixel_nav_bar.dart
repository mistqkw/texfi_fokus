import 'package:flutter/material.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import 'pixel_sprite.dart';

/// Одна вкладка нижней навигации.
class PixelNavItem {
  const PixelNavItem({required this.sprite, required this.label});

  /// Сетка спрайта из [PixelSprites].
  final List<String> sprite;

  final String label;
}

/// Нижняя навигация на собственных спрайтах.
///
/// Material `NavigationBar` приносил с собой круглую «пилюлю» под активной
/// иконкой и набор Icons — то есть ровно ту деталь, по которой интерфейс
/// читался как generic Material, несмотря на пиксельную тему. Здесь всё
/// своё: квадратная подложка активной вкладки, спрайты 8×8 (шестерёнка —
/// 10×10, на 8×8 у неё сливались зубцы) и верхняя граница в 2px вместо
/// тени.
class PixelNavBar extends StatelessWidget {
  const PixelNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<PixelNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.divider, width: AppRadius.pixelBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _PixelNavTab(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () {
                      if (i == currentIndex) return;
                      Haptics.tap();
                      onSelected(i);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PixelNavTab extends StatelessWidget {
  const _PixelNavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final PixelNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Активная вкладка — акцент, неактивная — приглушённый цвет темы:
    // серый в тёмной, тёплый бежево-коричневый в светлой.
    final color = selected ? colors.accent : colors.textTertiary;

    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Подложка активной вкладки — квадрат с рамкой, а не
              // material-«пилюля».
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? colors.accent.withValues(alpha: 0.16)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected ? colors.accent : Colors.transparent,
                    width: AppRadius.pixelBorder,
                  ),
                ),
                child: PixelSprite(rows: item.sprite, size: 20, color: color),
              ),
              AppSpacing.gapXs,
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.text.chartLabel.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
