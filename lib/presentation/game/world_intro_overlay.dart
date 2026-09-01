import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../l10n/app_localizations.dart';
import '../shared/pixel_background.dart';
import 'game_labels.dart';

/// Эпиграф мира — та же интонация, что у описаний дриферов: короткое
/// наблюдение, а не рекламное обещание.
String worldEpigraph(AppLocalizations l10n, int world) => switch (world) {
      1 => l10n.mapWorld1Epigraph,
      2 => l10n.mapWorld2Epigraph,
      _ => l10n.mapWorld3Epigraph,
    };

/// Заставка нового мира: имя крупно и одна фраза под ним.
///
/// Показывается ровно один раз на мир (см. `worldIntroProvider`) и живёт не
/// дольше двух секунд. Закрывается тапом в любую точку — и это здесь
/// обязательное свойство, а не любезность: в отличие от повышения уровня,
/// заставка мира встаёт между человеком и картой, на которую он шёл. Всё,
/// что стоит на пути, обязано убираться быстрее, чем успеет надоесть.
class WorldIntroOverlay extends StatefulWidget {
  const WorldIntroOverlay({super.key, required this.world});

  final int world;

  static Future<void> show(BuildContext context, int world) {
    Haptics.tap();
    return Navigator.of(context).push(
      pixelDissolveRoute<void>(
        WorldIntroOverlay(world: world),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<WorldIntroOverlay> createState() => _WorldIntroOverlayState();
}

class _WorldIntroOverlayState extends State<WorldIntroOverlay> {
  /// Самозакрытие. Двух секунд хватает на два коротких предложения, и это
  /// потолок: заставка, которую приходится пересиживать, из атмосферы
  /// превращается в задержку загрузки.
  static const Duration _hold = Duration(seconds: 2);

  bool _closing = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(_hold, _close);
  }

  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return GestureDetector(
      onTap: _close,
      behavior: HitTestBehavior.opaque,
      child: PixelBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: AppSpacing.screen,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.mapWorldIntroLabel.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: context.text.chartLabel.copyWith(
                        color: colors.textTertiary,
                      ),
                    ).animate().fadeIn(duration: AppMotion.fast),

                    AppSpacing.gapMd,
                    Text(
                      worldName(l10n, widget.world),
                      textAlign: TextAlign.center,
                      style: context.text.headline.copyWith(
                        color: colors.accent,
                      ),
                    )
                        .animate()
                        .fadeIn(
                          duration: AppMotion.normal,
                          delay: AppMotion.fast,
                        )
                        .slideY(begin: 0.25, end: 0, curve: AppMotion.snap),

                    AppSpacing.gapLg,
                    // Разделитель из тех же блоков, что и тропа на карте:
                    // заставка обязана выглядеть частью той же карты, на
                    // которую она открывается.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 5; i++)
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            color: colors.divider,
                          ),
                      ],
                    ).animate().fadeIn(
                          duration: AppMotion.fast,
                          delay: AppMotion.normal,
                        ),

                    AppSpacing.gapLg,
                    Text(
                      worldEpigraph(l10n, widget.world),
                      textAlign: TextAlign.center,
                      style: context.text.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ).animate().fadeIn(
                          duration: AppMotion.normal,
                          delay: AppMotion.slow,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
