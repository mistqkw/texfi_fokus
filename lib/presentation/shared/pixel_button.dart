import 'package:flutter/material.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import 'pixel_shadow.dart';
import 'pixel_sprite.dart';

/// Блочная кнопка с ретро-«тенью» (см. [PixelShadowBox]): при нажатии
/// съезжает на её высоту и тень исчезает — как физическая клавиша.
///
/// Иконка задаётся спрайтом ([sprite]), а не [IconData]: набор Material
/// внутри пиксельной кнопки сразу выдаёт, что интерфейс собран из чужих
/// деталей.
class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.sprite,
    this.primary = true,
    this.expand = true,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Сетка спрайта из [PixelSprites].
  final List<String>? sprite;

  /// Заливка акцентом; иначе — прозрачная кнопка с рамкой.
  final bool primary;

  final bool expand;
  final bool danger;

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = widget.danger
        ? colors.danger
        : (widget.primary ? colors.accent : Colors.transparent);
    final foreground = widget.primary || widget.danger
        ? colors.onAccent
        : colors.textPrimary;
    final borderColor = widget.primary || widget.danger ? base : colors.divider;
    final shadowColor = widget.danger
        ? colors.danger.withValues(alpha: 0.5)
        : (widget.primary ? colors.accentShadow : colors.divider);

    final body = Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: _enabled ? base : colors.surfaceVariant,
        borderRadius: AppRadius.controlSmallAll,
        border: Border.all(
          color: _enabled ? borderColor : colors.divider,
          width: AppRadius.pixelBorder,
        ),
      ),
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.sprite != null) ...[
            PixelSprite(
              rows: widget.sprite!,
              size: 14,
              color: _enabled ? foreground : colors.textTertiary,
            ),
            AppSpacing.wGapSm,
          ],
          Flexible(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: context.text.pixelLabel.copyWith(
                color: _enabled ? foreground : colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: _enabled
          ? () {
              Haptics.tap();
              widget.onPressed!.call();
            }
          : null,
      child: PixelShadowBox(
        shadowColor: shadowColor,
        enabled: _enabled,
        pressed: _pressed,
        child: body,
      ),
    );
  }
}
