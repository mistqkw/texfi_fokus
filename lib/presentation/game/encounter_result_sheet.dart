import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../domain/entities/game_entities.dart';
import '../../l10n/app_localizations.dart';
import '../shared/pixel_button.dart';
import 'game_labels.dart';
import 'game_providers.dart';
import 'game_sprites.dart';
import 'game_widgets.dart';

/// Итог игрового захода: победа над дрифером, победа над боссом, взятый
/// уровень — или поражение.
///
/// Поражение объясняется здесь же и теми же словами, что и всё остальное:
/// босс восстановился, выносливость тоже, ничего больше не потеряно. Скрытый
/// штраф, о котором пользователь узнаёт, случайно заметив полное HP, — это
/// не сложность, а обман.
class EncounterResultSheet extends StatelessWidget {
  const EncounterResultSheet({super.key, required this.result});

  final EncounterResult result;

  /// Показывает итог, если его есть смысл показывать.
  ///
  /// Обычный урон и мелкий опыт не прерывают поток: после каждой сессии
  /// всплывающий лист «нанесено 25 урона» превратился бы в шум. Останавливаем
  /// пользователя только на событиях — победа, поражение, новый уровень.
  static bool isWorthShowing(EncounterResult result) {
    return switch (result.outcome) {
      EncounterOutcome.drifterDefeated ||
      EncounterOutcome.bossDefeated ||
      EncounterOutcome.playerDefeated =>
        true,
      _ => result.leveledUpTo != null,
    };
  }

  ({String title, String body, List<String> sprite, bool good}) _content(
    AppLocalizations l10n,
  ) {
    final world = result.node?.world ?? 1;

    return switch (result.outcome) {
      EncounterOutcome.bossDefeated => (
          title: l10n.gameBossDefeated,
          body: l10n.gameBossDefeatedBody,
          sprite: GameSprites.boss(world),
          good: true,
        ),
      EncounterOutcome.playerDefeated => (
          title: l10n.gamePlayerDefeated,
          body: l10n.gamePlayerDefeatedBody,
          sprite: GameSprites.boss(world),
          good: false,
        ),
      EncounterOutcome.drifterDefeated => (
          title: l10n.gameDrifterDefeated,
          body: result.node?.flavor(l10n) ?? '',
          sprite: result.node == null
              ? GameSprites.avatarFlame
              : GameSprites.drifter(result.node!.species),
          good: true,
        ),
      _ => (
          title: l10n.gameLevelUp(result.leveledUpTo ?? 1),
          body: l10n.gameLevelUpBody,
          sprite: GameSprites.avatarAura,
          good: true,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final content = _content(l10n);

    // Побеждённый противник рассыпается: `alive: false` запускает распад.
    final defeated = result.outcome == EncounterOutcome.drifterDefeated ||
        result.outcome == EncounterOutcome.bossDefeated;

    return SafeArea(
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: _DefeatAnimation(
                sprite: content.sprite,
                color: content.good ? colors.accent : colors.danger,
                defeated: defeated,
              ),
            ),
            AppSpacing.gapLg,
            Text(
              content.title,
              textAlign: TextAlign.center,
              style: context.text.headline,
            ),
            AppSpacing.gapSm,
            Text(
              content.body,
              textAlign: TextAlign.center,
              style: context.text.body.copyWith(color: colors.textSecondary),
            ),
            if (result.xpGained > 0) ...[
              AppSpacing.gapMd,
              Text(
                l10n.gameXpGained(result.xpGained),
                textAlign: TextAlign.center,
                style: context.text.counterMedium.copyWith(
                  color: colors.accent,
                ),
              ),
            ],
            AppSpacing.gapXl,
            PixelButton(
              label: l10n.gameContinue,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Спрайт, который рассыпается через мгновение после появления.
///
/// Пауза нужна, чтобы победу было видно: мгновенный распад читается как
/// «спрайт не загрузился», а не как «ты его добил».
class _DefeatAnimation extends StatefulWidget {
  const _DefeatAnimation({
    required this.sprite,
    required this.color,
    required this.defeated,
  });

  final List<String> sprite;
  final Color color;
  final bool defeated;

  @override
  State<_DefeatAnimation> createState() => _DefeatAnimationState();
}

class _DefeatAnimationState extends State<_DefeatAnimation> {
  bool _alive = true;

  @override
  void initState() {
    super.initState();
    if (!widget.defeated) return;
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _alive = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PixelCreature(
      rows: widget.sprite,
      color: widget.color,
      size: 120,
      alive: _alive,
    );
  }
}

/// Показывает итог последнего захода, если он того стоит, и забирает его из
/// состояния — чтобы тот же экран не всплыл повторно при возврате.
Future<void> showEncounterResultIfAny(
  BuildContext context,
  WidgetRef ref,
) async {
  final result = ref.read(lastEncounterProvider);
  if (result == null) return;
  ref.read(lastEncounterProvider.notifier).clear();
  if (!EncounterResultSheet.isWorthShowing(result)) return;

  // Победа и поражение ощущаются по-разному ещё до того, как прочитан текст.
  if (result.outcome == EncounterOutcome.playerDefeated) {
    Haptics.warning();
  } else {
    Haptics.success();
  }

  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => EncounterResultSheet(result: result),
  );
}
