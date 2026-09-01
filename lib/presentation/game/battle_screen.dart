import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../data/providers/data_providers.dart';
import '../../domain/entities/game_entities.dart';
import '../../domain/entities/game_rules.dart';
import '../../domain/entities/mood.dart';
import '../../l10n/app_localizations.dart';
import '../mood_checkin/mood_checkin_providers.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_sprite.dart';
import '../shared/timer_dial.dart';
import '../timer/session_finish_flow.dart';
import '../timer/timer_alarm_sync.dart';
import '../timer/timer_providers.dart';
import 'game_labels.dart';
import 'game_providers.dart';
import 'game_sprites.dart';
import 'game_widgets.dart';

/// Экран боя: та же сессия, что и на обычном таймере, но показанная как
/// столкновение с конкретным существом.
///
/// Почему это отдельный экран, а не карточка над таймером. Карточка отвечает
/// на вопрос «против кого», и на экране рекомендации этого достаточно. Но
/// сам заход — единственное, что в игровом слое вообще происходит, и если он
/// выглядит как строчка над крутилкой, то игры и нет: есть трекер с
/// картинкой. Здесь противник занимает экран, его полоска убывает на глазах,
/// и конец сессии — это событие с исходом, а не тихая запись в базу.
///
/// При этом ни одной собственной секунды здесь не отсчитывается: время ведёт
/// тот же [timerControllerProvider], что и обычный экран, а сессия
/// сохраняется общим [finishSession]. Игровой слой остаётся надстройкой —
/// он показывает то, что и так происходит, и ничего не решает за таймер.
class BattleScreen extends ConsumerStatefulWidget {
  const BattleScreen({super.key, required this.node});

  /// Узел, на который идёт заход. Снимок на момент старта: пока сессия идёт,
  /// в базе он не меняется — урон записывается один раз, в конце.
  final MapNodeEntity node;

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen> {
  bool _finishHandled = false;

  /// Итог захода. Пока null — идёт бой; как только заполнен, экран целиком
  /// переключается на разбор.
  SessionFinishOutcome? _outcome;

  /// Сервис уведомлений держим полем: в `dispose()` читать провайдеры уже
  /// поздно, а снять будильники надо при любом исходе.
  late final NotificationService _notifications =
      ref.read(notificationServiceProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncAlarms(ref.read(timerControllerProvider));
    });
  }

  @override
  void dispose() {
    _notifications.cancelTimerAlarms();
    super.dispose();
  }

  Future<void> _syncAlarms(TimerState state) => syncTimerAlarms(
        notifications: _notifications,
        l10n: context.l10n,
        state: state,
        signal: ref.read(timerAlarmSignalProvider),
      );

  Future<void> _confirmStop() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.timerStopConfirmTitle),
        content: Text(l10n.timerStopConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.timerStopConfirmYes),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    ref.read(timerControllerProvider.notifier).stop();
  }

  Future<void> _handleFinish(TimerState state) async {
    if (_finishHandled) return;
    _finishHandled = true;

    final outcome = await finishSession(context, ref, state);
    if (outcome == null || !mounted) return;

    // Итог показывает этот экран, а не всплывающий лист поверх карты:
    // всплыть ему потом было бы уже нечем объяснить, и человек увидел бы
    // одно и то же событие дважды. Забираем его из общего состояния сами.
    ref.read(lastEncounterProvider.notifier).clear();

    if (outcome.encounter.outcome == EncounterOutcome.playerDefeated) {
      Haptics.warning();
    } else if (state.completedFully) {
      Haptics.success();
    }

    setState(() => _outcome = outcome);
  }

  void _leave() {
    final outcome = _outcome;
    if (outcome != null && outcome.restart) {
      // Черновик не сбрасываем: задача, настроение и категория те же.
      Navigator.of(context).pushReplacement(
        pixelDissolveRoute<void>(BattleScreen(node: widget.node)),
      );
      return;
    }
    ref.read(sessionDraftProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(timerControllerProvider);

    ref.listen<TimerState>(timerControllerProvider, (previous, next) {
      if (previous == null || previous.scheduleEpoch != next.scheduleEpoch) {
        _syncAlarms(next);
      }
      if (next.finished && !(previous?.finished ?? false)) {
        _handleFinish(next);
      }
    });

    final outcome = _outcome;

    return PopScope(
      // Уход назад посреди сессии — это тоже прерывание, и оно должно
      // попасть в статистику, а не потеряться.
      canPop: state.finished,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !state.finished) _confirmStop();
      },
      child: PixelBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: outcome == null
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _confirmStop,
                  )
                : null,
            title: Text(l10n.battleTitle, style: context.text.sectionTitle),
          ),
          body: SafeArea(
            child: outcome == null
                ? _BattleBody(
                    node: widget.node,
                    state: state,
                    onStop: _confirmStop,
                  )
                : _ResultBody(
                    node: widget.node,
                    outcome: outcome,
                    onContinue: _leave,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Ход боя: противник наверху, таймер под ним.
class _BattleBody extends ConsumerWidget {
  const _BattleBody({
    required this.node,
    required this.state,
    required this.onStop,
  });

  final MapNodeEntity node;
  final TimerState state;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final controller = ref.read(timerControllerProvider.notifier);

    // Настроение берётся то же, с которым сессия начиналась: от него зависит,
    // считается ли заход к боссу полноценным.
    final mood = ref.watch(sessionDraftProvider).mood;

    // Полоска HP считается той же формулой, что и настоящее начисление в
    // конце. Иначе она обещала бы одно, а запись давала другое — и это был бы
    // худший вид украшения: правдоподобное, но врущее.
    final hp = GameRules.previewHp(
      kind: node.kind,
      currentHp: node.currentHp,
      focusSeconds: state.focusSeconds,
      mood: mood,
    );
    final hpFraction = GameRules.previewHpFraction(
      kind: node.kind,
      currentHp: node.currentHp,
      maxHp: node.maxHp,
      focusSeconds: state.focusSeconds,
      mood: mood,
    );

    final tone = node.isBoss ? colors.danger : colors.accent;
    final isFocus = state.phase == TimerPhase.focus;

    return ListView(
      padding: AppSpacing.screen,
      children: [
        Center(
          child: PixelCreature(
            rows: node.isBoss
                ? GameSprites.boss(node.world)
                : GameSprites.drifter(node.species),
            color: tone,
            // Босс крупнее обычного дрифера прямо на экране, а не только на
            // словах: разница в весе противника должна читаться до того, как
            // прочитано хоть одно описание.
            size: node.isBoss ? 168 : 132,
            alive: hp > 0,
          ),
        ),
        // Запас под именем нарочно щедрый: у части силуэтов закрашена нижняя
        // строка сетки, и подпись вплотную читалась бы как часть существа.
        AppSpacing.gapLg,
        Text(
          node.title(l10n),
          textAlign: TextAlign.center,
          style: context.text.headline.copyWith(color: tone),
        ),
        AppSpacing.gapXs,
        Text(
          node.flavor(l10n),
          textAlign: TextAlign.center,
          style: context.text.caption.copyWith(color: colors.textSecondary),
        ),
        AppSpacing.gapLg,
        PixelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PixelStatRow(
                label: l10n.battleEnemyHp,
                value: hpFraction,
                color: tone,
                trailing: l10n.encounterHp(hp, node.maxHp),
              ),
              AppSpacing.gapSm,
              Text(l10n.battleProgressHint, style: context.text.caption),
              if (node.isBoss) ...[
                AppSpacing.gapMd,
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
                // Правило «сорвался — босс восстановился» проговаривается до
                // того, как оно сработает. Штраф, о котором узнаёшь постфактум,
                // случайно заметив полное HP, — это не сложность, а обман.
                Text(
                  l10n.battleBossStakes,
                  style: context.text.chartLabel.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                if (mood != Mood.fullFokus) ...[
                  AppSpacing.gapSm,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 3, height: 16, color: colors.warning),
                      AppSpacing.wGapSm,
                      Expanded(
                        child: Text(
                          l10n.encounterBossHint,
                          style: context.text.caption.copyWith(
                            color: colors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
        AppSpacing.gapXl,
        Center(
          child: SizedBox(
            width: 210,
            height: 210,
            child: TimerDial(
              progress: state.progress,
              remaining: state.remaining,
              accentColor: isFocus ? colors.accent : colors.success,
              enabled: !state.finished,
              label: isFocus ? l10n.timerFocusPhase : l10n.timerBreakPhase,
              onAdjustMinutes: controller.adjustMinutes,
            ),
          ),
        ),
        AppSpacing.gapSm,
        Text(
          l10n.battleTimerHint,
          textAlign: TextAlign.center,
          style: context.text.caption,
        ),
        AppSpacing.gapLg,
        Row(
          children: [
            Expanded(
              child: PixelButton(
                label: state.running ? l10n.timerPause : l10n.timerResume,
                sprite:
                    state.running ? PixelSprites.pause : PixelSprites.play,
                onPressed: state.finished ? null : controller.toggle,
              ),
            ),
            AppSpacing.wGapMd,
            Expanded(
              child: PixelButton(
                label: l10n.timerSkip,
                primary: false,
                sprite: PixelSprites.skip,
                onPressed: state.finished ? null : controller.skipPhase,
              ),
            ),
          ],
        ),
        AppSpacing.gapMd,
        PixelButton(
          label: l10n.timerStop,
          danger: true,
          sprite: PixelSprites.stop,
          onPressed: state.finished ? null : onStop,
        ),
      ],
    );
  }
}

/// Разбор захода: что стало с противником и что за это получено.
class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.node,
    required this.outcome,
    required this.onContinue,
  });

  final MapNodeEntity node;
  final SessionFinishOutcome outcome;
  final VoidCallback onContinue;

  /// Текст и тон исхода.
  ///
  /// Поражения здесь нет ни в одном варианте, и это не смягчение формулировок,
  /// а прямое следствие того, как устроен слой: оборванная сессия всё равно
  /// была работой, опыт за неё начисляется, а противник просто остался стоять.
  /// «Ты проиграл» было бы неправдой.
  ({String title, String body, bool good}) _content(AppLocalizations l10n) {
    return switch (outcome.encounter.outcome) {
      EncounterOutcome.bossDefeated => (
          title: l10n.battleBossVictoryTitle,
          body: l10n.gameBossDefeatedBody,
          good: true,
        ),
      EncounterOutcome.drifterDefeated => (
          title: l10n.battleVictoryTitle,
          body: l10n.battleVictoryBody,
          good: true,
        ),
      EncounterOutcome.playerDefeated => (
          title: l10n.battleBossResetTitle,
          body: l10n.battleBossResetBody,
          good: false,
        ),
      _ => (
          title: l10n.battleHeldTitle,
          body: l10n.battleHeldBody,
          good: false,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final content = _content(l10n);
    final encounter = outcome.encounter;

    final defeated = encounter.outcome == EncounterOutcome.drifterDefeated ||
        encounter.outcome == EncounterOutcome.bossDefeated;

    return ListView(
      padding: AppSpacing.screen,
      children: [
        Center(
          child: _DissolvingCreature(
            rows: node.isBoss
                ? GameSprites.boss(node.world)
                : GameSprites.drifter(node.species),
            color: content.good ? colors.accent : colors.textSecondary,
            defeated: defeated,
          ),
        ),
        AppSpacing.gapXxl,
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

        // Опыт показывается прямо здесь, а не капает молча в фоне: начисление,
        // которого не видно в момент, когда оно произошло, с тем же успехом
        // могло бы не происходить.
        if (encounter.xpGained > 0) ...[
          AppSpacing.gapXl,
          Center(
            child: Text(
              l10n.battleXpLine(encounter.xpGained),
              textAlign: TextAlign.center,
              style: context.text.counterMedium.copyWith(color: colors.accent),
            ),
          )
              .animate()
              .fadeIn(duration: AppMotion.slow, delay: AppMotion.normal)
              .slideY(begin: 0.4, end: 0, curve: AppMotion.snap),
        ],

        if (encounter.leveledUpTo != null) ...[
          AppSpacing.gapMd,
          Center(
            child: Text(
              l10n.gameLevelUp(encounter.leveledUpTo!),
              textAlign: TextAlign.center,
              style: context.text.sectionTitle.copyWith(color: colors.success),
            ),
          ),
        ],

        AppSpacing.gapXxl,
        PixelButton(label: l10n.gameContinue, onPressed: onContinue),
      ],
    );
  }
}

/// Спрайт, который рассыпается через мгновение после появления.
///
/// Пауза нужна, чтобы победу было видно: мгновенный распад читается как
/// «спрайт не загрузился», а не как «ты его добил».
class _DissolvingCreature extends StatefulWidget {
  const _DissolvingCreature({
    required this.rows,
    required this.color,
    required this.defeated,
  });

  final List<String> rows;
  final Color color;
  final bool defeated;

  @override
  State<_DissolvingCreature> createState() => _DissolvingCreatureState();
}

class _DissolvingCreatureState extends State<_DissolvingCreature> {
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
      rows: widget.rows,
      color: widget.color,
      size: 150,
      alive: _alive,
    );
  }
}
