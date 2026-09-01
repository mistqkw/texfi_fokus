import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../domain/entities/game_entities.dart';
import '../../domain/entities/game_rules.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_card.dart';
import 'game_labels.dart';
import 'game_providers.dart';
import 'game_sprites.dart';
import 'game_widgets.dart';

/// Экран персонажа: кто ты сейчас и сколько осталось до следующей ступени.
///
/// Аватар намеренно не человек — огонёк. Антропоморфная фигурка потребовала
/// бы решений, которых приложение не должно принимать за пользователя (пол,
/// возраст, цвет кожи), а огонёк растёт вместе с ним и не изображает никого
/// конкретного.
class CharacterScreen extends ConsumerWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final progress =
        ref.watch(playerProgressProvider).valueOrNull ??
            const PlayerProgressEntity();

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.characterTitle),
        ),
        body: SingleChildScrollView(
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AvatarCard(progress: progress),
              AppSpacing.gapLg,
              _StagesCard(progress: progress),
              AppSpacing.gapLg,
              _StatsCard(progress: progress),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.progress});

  final PlayerProgressEntity progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final breakdown = GameRules.levelXpBreakdown(progress.totalXp);
    final remaining = breakdown.needed - breakdown.current;

    return PixelCard(
      accent: true,
      child: Column(
        children: [
          PixelCreature(
            rows: GameSprites.avatar(progress.avatarStage),
            color: colors.accent,
            size: 132,
          ),
          AppSpacing.gapMd,
          // Звание крупнее номера уровня: «Уголёк» говорит о продвижении
          // больше, чем «5», и меняется достаточно часто, чтобы это было
          // видно между двумя перерисовками аватара.
          Text(
            rankLabel(l10n, progress.rank),
            style: context.text.headline.copyWith(color: colors.accent),
          ),
          AppSpacing.gapXs,
          Text(
            l10n.characterLevel(progress.level),
            style: context.text.title,
          ),
          AppSpacing.gapXs,
          Text(
            avatarStageLabel(l10n, progress.avatarStage),
            style: context.text.caption.copyWith(color: colors.textSecondary),
          ),
          AppSpacing.gapLg,
          PixelStatRow(
            label: l10n.characterXp(breakdown.current, breakdown.needed),
            value: progress.levelProgress,
            color: colors.accent,
            trailing: l10n.characterToNextLevel(remaining),
          ),
        ],
      ),
    );
  }
}

/// Лестница ступеней: как персонаж будет выглядеть дальше.
///
/// Показывается целиком, включая недостижимые пока ступени. Спрятать их было
/// бы честнее «по-игровому», но экран персонажа на первом уровне — это ровно
/// тот случай, когда всё вокруг равно нулю, и единственное, что может
/// объяснить, зачем сюда возвращаться, — видимая дорога впереди. Ступени
/// нарочно не сюрприз: сюрприз тут — встреча с существом на карте, а не
/// собственный аватар.
class _StagesCard extends StatelessWidget {
  const _StagesCard({required this.progress});

  final PlayerProgressEntity progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final nextLevel = progress.nextAvatarStageLevel;

    return PixelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.characterStagesTitle, style: context.text.sectionTitle),
          AppSpacing.gapSm,
          Text(l10n.characterStagesBody, style: context.text.caption),
          AppSpacing.gapLg,
          for (var stage = 0;
              stage < GameRules.avatarStageCount;
              stage++) ...[
            if (stage > 0) const Divider(height: AppSpacing.lg),
            _StageRow(
              stage: stage,
              unlockLevel: GameRules.avatarStageLevels[stage],
              reached: progress.avatarStage >= stage,
              current: progress.avatarStage == stage,
            ),
          ],
          AppSpacing.gapLg,
          Text(
            nextLevel == null
                ? l10n.characterFinalStage
                : l10n.characterNextStage(nextLevel),
            style: context.text.chartLabel.copyWith(color: colors.accent),
          ),
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.unlockLevel,
    required this.reached,
    required this.current,
  });

  final int stage;
  final int unlockLevel;

  /// Ступень уже пройдена или идёт сейчас.
  final bool reached;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    // Недостижимая пока ступень приглушена, но показана целиком: силуэт
    // будущего огонька — и есть то, ради чего на этот экран возвращаются.
    final tone = current
        ? colors.accent
        : (reached ? colors.textSecondary : colors.textTertiary);

    return Row(
      children: [
        PixelCreature(
          rows: GameSprites.avatar(stage),
          color: tone,
          size: 40,
          animate: current,
        ),
        AppSpacing.wGapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                avatarStageLabel(l10n, stage),
                style: context.text.body.copyWith(color: tone),
              ),
              AppSpacing.gapXs,
              Text(
                l10n.characterStageAtLevel(unlockLevel),
                style: context.text.chartLabel.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        if (current)
          Text(
            l10n.characterStageCurrent,
            style: context.text.chartLabel.copyWith(color: colors.accent),
          ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.progress});

  final PlayerProgressEntity progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PixelCard(
      child: Column(
        children: [
          _StatLine(
            sprite: GameSprites.drifterCreep,
            label: l10n.characterDriftersDefeated,
            value: '${progress.drifterKills}',
          ),
          const Divider(height: AppSpacing.xl),
          _StatLine(
            sprite: GameSprites.nodeCleared,
            label: l10n.characterBossesDefeated,
            value: '${progress.bossKills}',
          ),
          const Divider(height: AppSpacing.xl),
          _StatLine(
            sprite: GameSprites.avatarFlame,
            label: l10n.characterTotalXp,
            value: '${progress.totalXp}',
          ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.sprite,
    required this.label,
    required this.value,
  });

  final List<String> sprite;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        PixelCreature(
          rows: sprite,
          color: colors.textSecondary,
          size: 24,
          animate: false,
        ),
        AppSpacing.wGapMd,
        Expanded(child: Text(label, style: context.text.body)),
        Text(value, style: context.text.counterMedium),
      ],
    );
  }
}
