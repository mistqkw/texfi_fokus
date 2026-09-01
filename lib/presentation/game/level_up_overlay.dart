import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../domain/entities/game_entities.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import 'game_labels.dart';
import 'game_providers.dart';
import 'game_sprites.dart';
import 'game_widgets.dart';

/// Повышение уровня во весь экран.
///
/// Это единственное место во всём приложении, где анимации разрешено
/// задержать человека, и разрешено ровно потому, что событие редкое: уровень
/// берётся не за сессию, а за несколько. Строчка «Уровень 5» в списке итогов
/// сообщает тот же факт и стоит ноль внимания — а значит, и получает ноль.
///
/// Закрывается только кнопкой. Автоматическое закрытие по таймеру здесь было
/// бы худшим из вариантов: либо человек не успел прочитать, либо экран висит
/// дольше, чем нужно, — и оба случая зависят от того, смотрел ли он в телефон
/// в этот момент.
class LevelUpOverlay extends ConsumerWidget {
  const LevelUpOverlay({super.key, required this.level});

  final int level;

  /// Показывает момент повышения поверх текущего экрана.
  static Future<void> show(BuildContext context, int level) {
    Haptics.success();
    return Navigator.of(context).push(
      pixelDissolveRoute<void>(
        LevelUpOverlay(level: level),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final progress = ref.watch(playerProgressProvider).valueOrNull ??
        const PlayerProgressEntity();

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screen,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Аватар появляется первым и с запасом по времени: новая
                  // деталь силуэта — это и есть то, что изменилось, и её
                  // должно быть видно раньше любых подписей.
                  // Обёртка не косметическая: у [PixelCreature] есть
                  // собственное поле `animate`, и оно перекрывает
                  // одноимённый метод-расширение flutter_animate —
                  // `PixelCreature(...).animate()` не компилируется, потому
                  // что читается как вызов булева поля. Анимируем контейнер.
                  Center(
                    child: PixelCreature(
                      rows: GameSprites.avatar(progress.avatarStage),
                      color: colors.accent,
                      size: 148,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: AppMotion.reveal)
                      .scaleXY(
                        begin: 0.6,
                        end: 1,
                        duration: AppMotion.reveal,
                        curve: AppMotion.snap,
                      ),

                  AppSpacing.gapXl,

                  // Звание крупнее номера: «Уголёк» — это то, кем человек
                  // стал, а «6» — то, каким это записано в базе.
                  Text(
                    rankLabel(l10n, progress.rank),
                    textAlign: TextAlign.center,
                    style: context.text.headline.copyWith(color: colors.accent),
                  )
                      .animate()
                      .fadeIn(
                        duration: AppMotion.normal,
                        delay: AppMotion.fast,
                      )
                      .slideY(begin: 0.3, end: 0, curve: AppMotion.snap),

                  AppSpacing.gapSm,
                  Text(
                    l10n.gameLevelUp(level),
                    textAlign: TextAlign.center,
                    style: context.text.title,
                  ).animate().fadeIn(
                        duration: AppMotion.normal,
                        delay: AppMotion.normal,
                      ),

                  AppSpacing.gapXs,
                  Text(
                    l10n.gameLevelUpBody,
                    textAlign: TextAlign.center,
                    style: context.text.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ).animate().fadeIn(
                        duration: AppMotion.normal,
                        delay: AppMotion.normal,
                      ),

                  AppSpacing.gapXs,
                  Text(
                    avatarStageLabel(l10n, progress.avatarStage),
                    textAlign: TextAlign.center,
                    style: context.text.caption.copyWith(
                      color: colors.textTertiary,
                    ),
                  ).animate().fadeIn(
                        duration: AppMotion.normal,
                        delay: AppMotion.normal,
                      ),

                  AppSpacing.gapXxl,
                  PixelButton(
                    label: l10n.gameContinue,
                    onPressed: () => Navigator.of(context).pop(),
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
    );
  }
}
