import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/screen/focus_screen_mode.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../data/providers/data_providers.dart';
import '../game/encounter_result_sheet.dart';
import '../mood_checkin/mood_checkin_providers.dart';
import '../planner/planner_providers.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_radio.dart';
import '../shared/pixel_sprite.dart';
import '../shared/quiet_timer_view.dart';
import '../shared/timer_dial.dart';
import 'session_finish_flow.dart';
import 'timer_alarm_sync.dart';
import 'timer_providers.dart';

/// Экран таймера. Центральный элемент — крутилка: она и показывает прогресс,
/// и позволяет подкрутить оставшееся время, не выходя из сессии.
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  /// Полноэкранный минималистичный режим: остаются только цифры и кольцо.
  bool _fullscreen = false;

  /// Тихий режим: монохромный вид и приглушённая яркость.
  bool _quiet = false;

  /// Экран не гаснет, пока открыт таймер; он же ведёт тихий режим.
  ///
  /// Поле, а не провайдер: снятие обязано отработать в `dispose()`, а
  /// читать провайдеры оттуда уже поздно — ровно та же причина, по которой
  /// полем держится [_notifications].
  final FocusScreenMode _screen = FocusScreenMode();

  bool _finishHandled = false;

  /// Сервис уведомлений держим полем: в `dispose()` читать провайдеры уже
  /// поздно, а снять будильники надо при любом исходе — включая уход с
  /// экрана системным жестом «назад».
  late final NotificationService _notifications =
      ref.read(notificationServiceProvider);

  @override
  void initState() {
    super.initState();
    // Первый график ставится сразу после первого кадра: с этого момента конец
    // сессии знает система, а не только живой Dart-таймер. Приложение можно
    // сворачивать, выгружать из памяти и блокировать экран.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncAlarms(ref.read(timerControllerProvider));
    });
    // На таймер смотрят — гасить экран посреди сессии незачем.
    _screen.enter();
  }

  @override
  void dispose() {
    // Экран закрыт — будильников быть не должно ни при каком исходе.
    _notifications.cancelTimerAlarms();
    // Единственный путь снятия: `dispose()` отрабатывает и при жесте «назад»,
    // и при системной кнопке, и при программном уходе после конца сессии.
    // Пониженная яркость, забытая здесь, пережила бы сам экран.
    _screen.release();
    super.dispose();
  }

  Future<void> _setQuiet(bool value) async {
    Haptics.tap();
    await _screen.setQuiet(value);
    if (mounted) setState(() => _quiet = value);
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

  /// Сессия закончилась — собираем всё, что пользователь готов рассказать, и
  /// сохраняем. Ни один из вопросов не обязателен: если лист просто закрыть,
  /// сигналом для обучения останется сам факт «дошёл / не дошёл».
  ///
  /// Сама последовательность живёт в [finishSession] и делится с экраном боя:
  /// сессия должна сохраняться одинаково независимо от того, с какого экрана
  /// её вели.
  Future<void> _handleFinish(TimerState state) async {
    if (_finishHandled) return;
    _finishHandled = true;

    final outcome = await finishSession(context, ref, state);
    if (outcome == null || !mounted) return;

    // Победа, поражение или новый уровень — единственные события, ради
    // которых стоит задержать пользователя ещё одним экраном.
    await showEncounterResultIfAny(context, ref);
    if (!mounted) return;

    if (outcome.restart) {
      // Черновик не сбрасываем: задача, настроение и категория те же — в
      // этом весь смысл быстрого повтора.
      Navigator.of(context).pushReplacement(
        pixelDissolveRoute<void>(const TimerScreen()),
      );
      return;
    }

    ref.read(sessionDraftProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final state = ref.watch(timerControllerProvider);
    final controller = ref.read(timerControllerProvider.notifier);

    ref.listen<TimerState>(timerControllerProvider, (previous, next) {
      // Сравниваем именно epoch, а не всё состояние: тик секунды меняет
      // `remaining`, но не сдвигает расчётный конец фазы — переставлять из-за
      // него системные будильники было бы расточительно.
      if (previous == null || previous.scheduleEpoch != next.scheduleEpoch) {
        _syncAlarms(next);
      }
      if (next.finished && !(previous?.finished ?? false)) {
        _handleFinish(next);
      }
    });

    final isFocus = state.phase == TimerPhase.focus;
    final phaseColor = isFocus ? colors.accent : colors.success;

    if (_quiet) {
      return PopScope(
        // «Назад» из тихого режима возвращает обычный вид, а не выходит из
        // сессии: человек приглушил экран, а не закончил работать.
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _setQuiet(false);
        },
        child: QuietTimerView(
          remaining: state.remaining,
          hint: l10n.timerQuietModeHint,
          onExit: () => _setQuiet(false),
        ),
      );
    }

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
          appBar: _fullscreen
              ? null
              : AppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _confirmStop,
                  ),
                  title: Text(
                    l10n.timerCycleOf(
                      state.cycleIndex + 1,
                      state.plan.cycles,
                    ),
                    style: context.text.sectionTitle,
                  ),
                  actions: [
                    IconButton(
                      tooltip: l10n.timerQuietMode,
                      icon: const Icon(Icons.nightlight_round),
                      onPressed: () => _setQuiet(true),
                    ),
                    IconButton(
                      tooltip: l10n.timerFullscreen,
                      icon: const Icon(Icons.fullscreen),
                      onPressed: () {
                        Haptics.tap();
                        setState(() => _fullscreen = true);
                      },
                    ),
                  ],
                ),
          body: SafeArea(
            child: GestureDetector(
              onDoubleTap: () {
                Haptics.tap();
                setState(() => _fullscreen = !_fullscreen);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: TimerDial(
                          progress: state.progress,
                          remaining: state.remaining,
                          accentColor: phaseColor,
                          enabled: !state.finished,
                          label: isFocus
                              ? l10n.timerFocusPhase
                              : l10n.timerBreakPhase,
                          onAdjustMinutes: controller.adjustMinutes,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: AppMotion.normal,
                      opacity: _fullscreen ? 0.35 : 1,
                      child: Column(
                        children: [
                          // Чеклист живёт над кнопками и только если у задачи
                          // есть подзадачи: пустая рамка «здесь мог быть
                          // список» отнимала бы место у самого таймера.
                          const _SessionChecklist(),
                          Text(
                            l10n.timerDialHint,
                            textAlign: TextAlign.center,
                            style: context.text.caption,
                          ),
                          AppSpacing.gapLg,
                          Row(
                            children: [
                              Expanded(
                                child: PixelButton(
                                  label: state.running
                                      ? l10n.timerPause
                                      : l10n.timerResume,
                                  sprite: state.running
                                      ? PixelSprites.pause
                                      : PixelSprites.play,
                                  onPressed:
                                      state.finished ? null : controller.toggle,
                                ),
                              ),
                              AppSpacing.wGapMd,
                              Expanded(
                                child: PixelButton(
                                  label: l10n.timerSkip,
                                  primary: false,
                                  sprite: PixelSprites.skip,
                                  onPressed: state.finished
                                      ? null
                                      : controller.skipPhase,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapMd,
                          PixelButton(
                            label: l10n.timerStop,
                            danger: true,
                            sprite: PixelSprites.stop,
                            onPressed: state.finished ? null : _confirmStop,
                          ),
                        ],
                      ),
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

/// Чеклист подзадач внутри сессии.
///
/// Отмечать пункты по ходу — единственное действие в таймере, которое не
/// про таймер: оно возвращает ощущение продвижения там, где кольцо
/// показывает только, что время идёт.
class _SessionChecklist extends ConsumerWidget {
  const _SessionChecklist();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskId = ref.watch(sessionDraftProvider).taskId;
    if (taskId == null) return const SizedBox.shrink();

    final subtasks = ref.watch(subtasksProvider(taskId)).valueOrNull ?? const [];
    if (subtasks.isEmpty) return const SizedBox.shrink();

    final planner = ref.watch(plannerRepositoryProvider);
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: PixelCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final subtask in subtasks)
              InkWell(
                onTap: () {
                  if (subtask.done) {
                    Haptics.tap();
                  } else {
                    Haptics.success();
                  }
                  planner.setSubtaskDone(subtask.id, !subtask.done);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      PixelCheckIndicator(checked: subtask.done, size: 16),
                      AppSpacing.wGapSm,
                      Expanded(
                        child: Text(
                          subtask.title,
                          style: context.text.caption.copyWith(
                            decoration: subtask.done
                                ? TextDecoration.lineThrough
                                : null,
                            color: subtask.done
                                ? colors.textTertiary
                                : colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
