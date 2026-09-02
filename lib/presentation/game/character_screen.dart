import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../domain/entities/game_entities.dart';
import '../../domain/entities/game_rules.dart';
import '../../l10n/app_localizations.dart';
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
              AppSpacing.gapLg,
              _ScrapsCard(progress: progress),
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
            if (stage > 0) const PixelDivider(gap: AppSpacing.sm),
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

    // Три нуля выглядели одинаково и у того, кто только включил режим, и у
    // того, кто давно играет, но ни одной сессии не досиживает. Второму
    // молчать особенно вредно: именно ему нужно сказать, что победа — это
    // доведённая до конца сессия, а не начатая.
    final noWins = progress.drifterKills == 0 && progress.bossKills == 0;
    final everPlayed = progress.totalXp > 0;

    return PixelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (noWins) ...[
            Text(
              everPlayed
                  ? l10n.characterStatsNoWins
                  : l10n.characterStatsEmptyNew,
              style: context.text.body,
            ),
            const PixelDivider(gap: AppSpacing.md),
          ],
          _StatLine(
            sprite: GameSprites.drifterCreep,
            label: l10n.characterDriftersDefeated,
            value: '${progress.drifterKills}',
          ),
          const PixelDivider(gap: AppSpacing.md),
          _StatLine(
            sprite: GameSprites.nodeCleared,
            label: l10n.characterBossesDefeated,
            value: '${progress.bossKills}',
          ),
          const PixelDivider(gap: AppSpacing.md),
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

/// Обрывки — сквозная нить, спрятанная за боссами.
///
/// Живёт на экране персонажа, за иконкой в шапке карты, и это единственное
/// место, где её вообще можно прочитать. Так и задумано: приложение — это
/// таймер, и человек, который никогда сюда не заглянет, не пропустит ничего
/// из того, что делает таймер таймером. История не всплывает сама, не
/// прерывает сессию и не просит себя дочитать.
///
/// Открывается победами над боссами: [GameRules.unlockedLoreFragments].
/// Последний обрывок придерживается до полного прохождения карты — ему
/// нечего подытоживать раньше.
class _ScrapsCard extends StatelessWidget {
  const _ScrapsCard({required this.progress});

  final PlayerProgressEntity progress;

  /// Текст обрывка по его 1-based номеру.
  ///
  /// Тот же приём, что и у имён дриферов: домен не знает языка, перевод
  /// живёт рядом с интерфейсом. `_` в конце — не заглушка, а последний
  /// обрывок: их ровно столько, сколько миров, плюс один.
  static String _fragment(AppLocalizations l10n, int number) =>
      switch (number) {
        1 => l10n.loreFragment1,
        2 => l10n.loreFragment2,
        3 => l10n.loreFragment3,
        _ => l10n.loreFragment4,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    final unlocked = GameRules.unlockedLoreFragments(progress.bossKills);
    final total = GameRules.loreFragmentCount;

    return PixelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.loreTitle, style: context.text.sectionTitle),
          AppSpacing.gapXs,
          Text(
            l10n.loreBody,
            style: context.text.caption.copyWith(color: colors.textSecondary),
          ),

          if (unlocked == 0) ...[
            const PixelDivider(gap: AppSpacing.md),
            Text(
              l10n.loreEmpty,
              style: context.text.caption.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],

          for (var i = 1; i <= total; i++) ...[
            // Ненайденный обрывок всё равно показан строкой: видно, что
            // впереди что-то есть, но не видно что. Скрывать его целиком
            // значило бы, что до первой победы карточка выглядит пустой и
            // бессмысленной, а перечислять тексты заранее — что читать их
            // потом уже незачем.
            if (i <= unlocked || i == unlocked + 1) ...[
              const PixelDivider(gap: AppSpacing.md),
              Text(
                l10n.loreScrap(i).toUpperCase(),
                style: context.text.chartLabel.copyWith(
                  color: i <= unlocked ? colors.accent : colors.textTertiary,
                ),
              ),
              AppSpacing.gapXs,
              Text(
                i <= unlocked ? _fragment(l10n, i) : l10n.loreLocked,
                style: i <= unlocked
                    ? context.text.body
                    : context.text.caption.copyWith(
                        color: colors.textTertiary,
                      ),
              ),
            ],
          ],
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
