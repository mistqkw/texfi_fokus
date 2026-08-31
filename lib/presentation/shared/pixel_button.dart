import 'package:flutter/material.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';

/// Блочная кнопка с ретро-«тенью»: сплошной прямоугольник со смещением
/// вместо размытия. При нажатии кнопка съезжает на эти же пиксели и тень
/// исчезает — как физическая клавиша.
class PixelButton extends StatefulWidget {
  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
    this.expand = true,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

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

    const offset = AppRadius.pixelShadowOffset;
    final shift = _pressed ? offset : 0.0;

    final body = AnimatedContainer(
      duration: AppMotion.instant,
      curve: AppMotion.enter,
      transform: Matrix4.translationValues(shift, shift, 0),
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
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: 16,
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
      child: Stack(
        children: [
          // Нижний слой и есть «тень»: тот же прямоугольник, смещённый вниз-вправо.
          if (_enabled)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(left: offset, top: offset),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: shadowColor,
                    borderRadius: AppRadius.controlSmallAll,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: offset, bottom: offset),
            child: body,
          ),
        ],
      ),
    );
  }
}
