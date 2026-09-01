import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../domain/entities/game_entities.dart';
import '../../domain/entities/game_rules.dart';
import '../../domain/entities/mood.dart';
import '../mood_checkin/mood_checkin_providers.dart';
import '../shared/pixel_card.dart';
import 'game_labels.dart';
import 'game_providers.dart';
import 'game_sprites.dart';
import 'game_widgets.dart';

/// Карточка «против кого идёт бой».
///
/// Живёт и на карте, и на экране рекомендации — именно поэтому она отдельный
/// виджет, а не кусок экрана: показывать одного противника в двух местах и
/// расходиться в деталях было бы хуже, чем не показывать вовсе.
///
/// Надстройка чисто визуальная: она ничего не решает за движок рекомендаций
/// и не меняет параметры сессии. Пользователь по-прежнему стартует ту же
/// сессию, что и в обычном режиме, — просто теперь видит, на что она
/// потратится.
class EncounterCard extends ConsumerWidget {
  const EncounterCard({
    super.key,
    required this.node,
    this.compact = false,
  });

  final MapNodeEntity node;

  /// Ужатый вариант для экрана рекомендации: там карточка — вставка над уже
  /// существующим содержимым, и занимать пол-экрана она не должна.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;

    // Настроение читаем из черновика сессии: именно оно решает, будет ли
    // заход к боссу полноценным.
    final mood = ref.watch(sessionDraftProvider).mood;
    final needsFokus = node.isBoss && mood != Mood.fullFokus;

    final sprite = node.isBoss
        ? GameSprites.boss(node.world)
        : GameSprites.drifter(node.species);

    // Босс — тревожный тон, обычный дрифер — акцентный. Цвет здесь не
    // украшение: он единственный, что отличает «ещё один» от «этот».
    final tone = node.isBoss ? colors.danger : colors.accent;

    return PixelCard(
      accent: !node.isBoss,
      borderColor: node.isBoss ? colors.danger : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.encounterTitle, style: context.text.chartLabel),
          AppSpacing.gapSm,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PixelCreature(
                rows: sprite,
                color: tone,
                size: compact ? 56 : 84,
              ),
              AppSpacing.wGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(node.title(l10n), style: context.text.sectionTitle),
                    AppSpacing.gapXs,
                    if (!compact) ...[
                      Text(
                        node.flavor(l10n),
                        style: context.text.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      AppSpacing.gapSm,
                    ],
                    PixelStatRow(
                      label: node.isBoss ? l10n.mapBossNode : l10n.encounterTitle,
                      value: node.hpFraction,
                      color: tone,
                      trailing: l10n.encounterHp(node.currentHp, node.maxHp),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Недобитый противник и восстановившийся дрифер объясняются
          // словами. Молча изменившийся HP выглядел бы как потеря прогресса.
          if (node.wounded) ...[
            AppSpacing.gapSm,
            _Note(text: l10n.encounterWounded, color: colors.warning),
          ],

          if (node.isBoss) ...[
            AppSpacing.gapSm,
            _Note(text: l10n.encounterBossHint, color: colors.textSecondary),
            AppSpacing.gapSm,
            PixelStatRow(
              label: l10n.encounterBossStamina(
                node.playerHp,
                GameRules.bossPlayerHp,
              ),
              value: node.playerHp / GameRules.bossPlayerHp,
              color: colors.success,
              segments: GameRules.bossPlayerHp,
            ),
            AppSpacing.gapXs,
            Text(
              l10n.encounterBossStaminaHint,
              style: context.text.chartLabel.copyWith(
                color: colors.textTertiary,
              ),
            ),
            if (needsFokus) ...[
              AppSpacing.gapSm,
              _Note(text: l10n.encounterFokusMissing, color: colors.warning),
            ],
          ],
        ],
      ),
    );
  }
}

/// Короткая поясняющая строка с цветной чертой слева.
class _Note extends StatelessWidget {
  const _Note({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 3, height: 16, color: color),
        AppSpacing.wGapSm,
        Expanded(
          child: Text(
            text,
            style: context.text.caption.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// Карточка текущего противника, если игровой режим включён и противник есть.
///
/// Отдельный виджет ровно для того, чтобы экран рекомендации не оброс
/// проверками: в обычном режиме он вставляет сюда пустоту и об игре ничего
/// не знает.
class CurrentEncounterCard extends ConsumerWidget {
  const CurrentEncounterCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(gameModeOnProvider)) return const SizedBox.shrink();
    final node = ref.watch(currentNodeProvider);
    if (node == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: EncounterCard(node: node, compact: compact),
    );
  }
}
