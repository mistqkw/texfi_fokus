import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_sprite.dart';
import 'session_guard_providers.dart';

/// Мягкая пауза перед стартом сессии.
///
/// Возвращает `true`, если стартовать можно: либо предупреждать было не о
/// чем, либо пользователь настоял. Отказ — это `false`, и вызывающий просто
/// ничего не делает; никаких блокировок и таймаутов «остынь пять минут»
/// здесь нет и быть не должно.
Future<bool> confirmSessionStart(BuildContext context, WidgetRef ref) async {
  final warning = ref.read(startWarningProvider);
  if (warning == StartWarning.none) return true;

  Haptics.warning();
  final proceed = await showDialog<bool>(
    context: context,
    builder: (context) => _SessionGuardDialog(warning: warning),
  );
  return proceed ?? false;
}

class _SessionGuardDialog extends StatelessWidget {
  const _SessionGuardDialog({required this.warning});

  final StartWarning warning;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    final (title, body) = switch (warning) {
      StartWarning.burnoutStreak => (
          l10n.guardBurnoutTitle,
          l10n.guardBurnoutBody,
        ),
      StartWarning.shortBreak => (
          l10n.guardShortBreakTitle,
          l10n.guardShortBreakBody,
        ),
      StartWarning.none => ('', ''),
    };

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(AppSpacing.page),
      child: PixelCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PixelSprite(
                  rows: PixelSprites.hourglass,
                  size: 16,
                  color: colors.warning,
                ),
                AppSpacing.wGapSm,
                Expanded(
                  child: Text(
                    title,
                    style: context.text.sectionTitle.copyWith(
                      color: colors.warning,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapMd,
            Text(body, style: context.text.body),
            AppSpacing.gapXl,
            PixelButton(
              label: l10n.guardStartAnyway,
              primary: false,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            AppSpacing.gapMd,
            PixelButton(
              label: l10n.guardTakeABreak,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
