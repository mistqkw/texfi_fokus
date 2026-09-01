import 'package:flutter/material.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import 'pixel_sprite.dart';

/// Индикатор выбора: квадратная рамка в 2px, внутри — квадратная заливка.
///
/// Material `Radio` — идеальный круг с чернильной анимацией; в пиксельном
/// интерфейсе он выглядит деталью из другого приложения. Здесь ни
/// скруглений, ни сглаживания: состояние переключается, а не «перетекает».
class PixelRadioIndicator extends StatelessWidget {
  const PixelRadioIndicator({super.key, required this.selected, this.size = 20});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          border: Border.all(
            color: selected ? colors.accent : colors.divider,
            width: AppRadius.pixelBorder,
          ),
        ),
        child: selected
            ? Center(
                child: SizedBox(
                  width: size / 2.5,
                  height: size / 2.5,
                  child: ColoredBox(color: colors.accent),
                ),
              )
            : null,
      ),
    );
  }
}

/// Квадратный чекбокс с пиксельной галочкой-спрайтом.
class PixelCheckIndicator extends StatelessWidget {
  const PixelCheckIndicator({
    super.key,
    required this.checked,
    this.size = 26,
    this.color,
  });

  final bool checked;
  final double size;

  /// Цвет заливки в отмеченном состоянии; по умолчанию — «успех».
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final on = color ?? colors.success;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: checked ? on : Colors.transparent,
          border: Border.all(
            color: checked ? on : colors.divider,
            width: AppRadius.pixelBorder,
          ),
        ),
        child: checked
            ? Center(
                child: PixelSprite(
                  rows: PixelSprites.check,
                  size: size * 0.62,
                  color: colors.onAccent,
                ),
              )
            : null,
      ),
    );
  }
}

/// Тумблер: квадратная дорожка и квадратный «ползунок», который
/// перескакивает между двумя позициями, а не плавно едет.
class PixelToggleIndicator extends StatelessWidget {
  const PixelToggleIndicator({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 44,
      height: 24,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: value
              ? colors.accent.withValues(alpha: 0.24)
              : colors.surfaceVariant,
          border: Border.all(
            color: value ? colors.accent : colors.divider,
            width: AppRadius.pixelBorder,
          ),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(3),
            // Высота задаётся явно: без неё ColoredBox в Align схлопывался
            // в нулевую полоску и тумблер выглядел пустой рамкой.
            child: SizedBox(
              width: 12,
              height: 14,
              child: ColoredBox(
                color: value ? colors.accent : colors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Строка списка с любым пиксельным индикатором слева.
///
/// Заменяет `RadioListTile`/`SwitchListTile`: те тянут за собой Material-
/// геометрию (круглые контролы, чернильный отклик, свои отступы), из-за
/// которой настройки выглядели чужеродно на фоне остальных экранов.
class PixelOptionTile extends StatelessWidget {
  const PixelOptionTile({
    super.key,
    required this.title,
    required this.leading,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;

  /// Индикатор состояния — [PixelRadioIndicator], [PixelToggleIndicator]…
  final Widget leading;

  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: enabled && onTap != null
          ? () {
              Haptics.tap();
              onTap!();
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Opacity(opacity: enabled ? 1 : 0.4, child: leading),
            AppSpacing.wGapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.title.copyWith(
                      color: enabled ? colors.textPrimary : colors.textTertiary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: context.text.caption),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[AppSpacing.wGapMd, trailing!],
          ],
        ),
      ),
    );
  }
}

/// Готовая строка-переключатель с пиксельным тумблером справа от подписи.
class PixelSwitchTile extends StatelessWidget {
  const PixelSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.title.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: context.text.caption),
                  ],
                ],
              ),
            ),
            AppSpacing.wGapMd,
            PixelToggleIndicator(value: value),
          ],
        ),
      ),
    );
  }
}

/// Строка выбора одного значения из списка.
class PixelRadioTile<T> extends StatelessWidget {
  const PixelRadioTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return PixelOptionTile(
      title: title,
      subtitle: subtitle,
      leading: PixelRadioIndicator(selected: value == groupValue),
      onTap: () => onChanged(value),
    );
  }
}
