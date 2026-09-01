import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/haptics/haptics.dart';
import '../../data/providers/data_providers.dart';
import '../../domain/entities/focus_technique.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/session_entity.dart';
import '../mood_checkin/mood_checkin_providers.dart';

const _uuid = Uuid();

enum TimerPhase { focus, rest }

/// Параметры запускаемой сессии — либо взятые из рекомендации, либо
/// собранные пользователем вручную.
class TimerPlan {
  const TimerPlan({
    required this.technique,
    required this.focusMinutes,
    required this.breakMinutes,
    required this.cycles,
    this.soundOnEnd = true,
    this.autoStartNext = true,
    this.wasRecommended = true,
    this.wasManualOverride = false,
  });

  factory TimerPlan.fromRecommendation(Recommendation recommendation) {
    return TimerPlan(
      technique: recommendation.technique,
      focusMinutes: recommendation.focusMinutes,
      breakMinutes: recommendation.breakMinutes,
      cycles: recommendation.cycles,
    );
  }

  final FocusTechnique technique;
  final int focusMinutes;
  final int breakMinutes;
  final int cycles;
  final bool soundOnEnd;
  final bool autoStartNext;
  final bool wasRecommended;

  /// Пользователь выбрал технику, отличную от рекомендованной. Долетает до
  /// [SessionEntity] и делает сигнал для движка слабее.
  final bool wasManualOverride;

  TimerPlan copyWith({
    FocusTechnique? technique,
    int? focusMinutes,
    int? breakMinutes,
    int? cycles,
    bool? soundOnEnd,
    bool? autoStartNext,
    bool? wasRecommended,
    bool? wasManualOverride,
  }) {
    return TimerPlan(
      technique: technique ?? this.technique,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      cycles: cycles ?? this.cycles,
      soundOnEnd: soundOnEnd ?? this.soundOnEnd,
      autoStartNext: autoStartNext ?? this.autoStartNext,
      wasRecommended: wasRecommended ?? this.wasRecommended,
      wasManualOverride: wasManualOverride ?? this.wasManualOverride,
    );
  }
}

class TimerState {
  const TimerState({
    required this.plan,
    required this.phase,
    required this.cycleIndex,
    required this.remaining,
    required this.phaseTotal,
    required this.running,
    required this.finished,
    required this.focusSeconds,
    required this.startedAt,
    this.completedFully = false,
  });

  final TimerPlan plan;
  final TimerPhase phase;

  /// 0-based номер текущего цикла.
  final int cycleIndex;

  final Duration remaining;
  final Duration phaseTotal;
  final bool running;

  /// Сессия закончилась — успешно или досрочно.
  final bool finished;

  /// Все запланированные циклы фокуса пройдены.
  final bool completedFully;

  /// Фактически проведённое в фокусе время, без перерывов.
  final int focusSeconds;

  final DateTime startedAt;

  /// Доля пройденного времени текущей фазы, 0..1.
  double get progress {
    if (phaseTotal.inSeconds == 0) return 0;
    final passed = phaseTotal.inSeconds - remaining.inSeconds;
    return (passed / phaseTotal.inSeconds).clamp(0.0, 1.0);
  }

  TimerState copyWith({
    TimerPhase? phase,
    int? cycleIndex,
    Duration? remaining,
    Duration? phaseTotal,
    bool? running,
    bool? finished,
    bool? completedFully,
    int? focusSeconds,
  }) {
    return TimerState(
      plan: plan,
      phase: phase ?? this.phase,
      cycleIndex: cycleIndex ?? this.cycleIndex,
      remaining: remaining ?? this.remaining,
      phaseTotal: phaseTotal ?? this.phaseTotal,
      running: running ?? this.running,
      finished: finished ?? this.finished,
      completedFully: completedFully ?? this.completedFully,
      focusSeconds: focusSeconds ?? this.focusSeconds,
      startedAt: startedAt,
    );
  }
}

/// Ведёт обратный отсчёт и переходы между фазами.
///
/// Время считается тиками по секунде, а не разницей часов: пользователь может
/// подкрутить оставшееся время диском прямо посреди фазы, и «правильное»
/// время окончания в этот момент перестаёт существовать. Зато фактическое
/// время в фокусе накапливается отдельным счётчиком и от подкруток не
/// страдает — в статистику попадает только реально отсиженное.
class TimerController extends StateNotifier<TimerState> {
  TimerController(TimerPlan plan)
      : super(
          TimerState(
            plan: plan,
            phase: TimerPhase.focus,
            cycleIndex: 0,
            remaining: Duration(minutes: plan.focusMinutes),
            phaseTotal: Duration(minutes: plan.focusMinutes),
            running: true,
            finished: false,
            focusSeconds: 0,
            startedAt: DateTime.now(),
          ),
        ) {
    _start();
  }

  Timer? _ticker;

  void _start() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!state.running || state.finished) return;

    final next = state.remaining - const Duration(seconds: 1);
    final focusSeconds = state.phase == TimerPhase.focus
        ? state.focusSeconds + 1
        : state.focusSeconds;

    if (next.inSeconds > 0) {
      state = state.copyWith(remaining: next, focusSeconds: focusSeconds);
      return;
    }

    state = state.copyWith(remaining: Duration.zero, focusSeconds: focusSeconds);
    _advancePhase();
  }

  void _advancePhase() {
    final plan = state.plan;

    if (state.phase == TimerPhase.focus) {
      final isLastCycle = state.cycleIndex >= plan.cycles - 1;
      if (isLastCycle) {
        Haptics.sessionComplete();
        if (plan.soundOnEnd) SystemSound.play(SystemSoundType.alert);
        _finish(completedFully: true);
        return;
      }

      Haptics.cycleComplete();
      if (plan.soundOnEnd) SystemSound.play(SystemSoundType.alert);
      state = state.copyWith(
        phase: TimerPhase.rest,
        remaining: Duration(minutes: plan.breakMinutes),
        phaseTotal: Duration(minutes: plan.breakMinutes),
        running: plan.autoStartNext,
      );
      return;
    }

    // Перерыв закончился — следующий цикл фокуса.
    Haptics.cycleComplete();
    state = state.copyWith(
      phase: TimerPhase.focus,
      cycleIndex: state.cycleIndex + 1,
      remaining: Duration(minutes: plan.focusMinutes),
      phaseTotal: Duration(minutes: plan.focusMinutes),
      running: plan.autoStartNext,
    );
  }

  void pause() {
    if (state.finished) return;
    state = state.copyWith(running: false);
  }

  void resume() {
    if (state.finished) return;
    state = state.copyWith(running: true);
  }

  void toggle() => state.running ? pause() : resume();

  /// Пропустить текущую фазу целиком.
  void skipPhase() {
    if (state.finished) return;
    state = state.copyWith(remaining: Duration.zero);
    _advancePhase();
  }

  /// Подкрутка диском. Оставшееся время не может уйти ниже нуля; если его
  /// увеличили сверх исходной длительности фазы, растёт и знаменатель
  /// прогресса — иначе кольцо «переполнилось» бы.
  void adjustMinutes(int delta) {
    if (state.finished) return;
    final next = state.remaining + Duration(minutes: delta);
    final clamped = next.isNegative ? Duration.zero : next;
    state = state.copyWith(
      remaining: clamped,
      phaseTotal: clamped > state.phaseTotal ? clamped : state.phaseTotal,
    );
  }

  /// Досрочная остановка пользователем.
  void stop() => _finish(completedFully: false);

  void _finish({required bool completedFully}) {
    _ticker?.cancel();
    _ticker = null;
    state = state.copyWith(
      running: false,
      finished: true,
      completedFully: completedFully,
      remaining: Duration.zero,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

/// План устанавливается до перехода на экран таймера.
final timerPlanProvider = StateProvider<TimerPlan?>((ref) => null);

final timerControllerProvider =
    StateNotifierProvider.autoDispose<TimerController, TimerState>((ref) {
  final plan = ref.watch(timerPlanProvider);
  if (plan == null) {
    throw StateError('timerPlanProvider must be set before opening the timer');
  }
  final controller = TimerController(plan);
  ref.onDispose(controller.dispose);
  return controller;
});

/// Сохраняет завершённую сессию и скармливает её результат движку
/// рекомендаций. Одна операция: обучение не должно «забыться» из-за того,
/// что экран закрыли раньше времени.
final saveSessionProvider = Provider<
    Future<void> Function({
  required TimerState state,
  required int? rating,
  InterruptionReason? interruptionReason,
  String? note,
})>((ref) {
  return ({
    required TimerState state,
    required int? rating,
    InterruptionReason? interruptionReason,
    String? note,
  }) async {
    final draft = ref.read(sessionDraftProvider);
    final session = SessionEntity(
      id: _uuid.v4(),
      taskId: draft.taskId,
      taskTitle: draft.taskTitle.trim().isEmpty
          ? draft.category.name
          : draft.taskTitle.trim(),
      category: draft.category,
      difficulty: draft.difficulty,
      mood: draft.mood,
      technique: state.plan.technique,
      plannedFocusMinutes: state.plan.focusMinutes,
      plannedBreakMinutes: state.plan.breakMinutes,
      plannedCycles: state.plan.cycles,
      actualFocusSeconds: state.focusSeconds,
      outcome: state.completedFully
          ? SessionOutcome.completed
          : SessionOutcome.aborted,
      rating: rating,
      startedAt: state.startedAt,
      endedAt: DateTime.now(),
      contextKey: draft.context.key,
      wasRecommended: state.plan.wasRecommended,
      wasManualOverride: state.plan.wasManualOverride,
      // Причина прерывания осмысленна только для оборванной сессии:
      // на завершённой она означала бы «прервал доведённое до конца».
      interruptionReason:
          state.completedFully ? null : interruptionReason,
      sessionNote: (note ?? '').trim().isEmpty ? null : note!.trim(),
    );

    await ref.read(sessionRepositoryProvider).addSession(session);
    await ref.read(recommendationEngineProvider).recordOutcome(session);

    final entryId = draft.moodEntryId;
    if (entryId != null) {
      await ref.read(moodRepositoryProvider).linkSession(
            entryId: entryId,
            sessionId: session.id,
          );
    }
  };
});
