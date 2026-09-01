import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/haptics/haptics.dart';
import '../../core/notifications/notification_service.dart';
import '../../data/providers/data_providers.dart';
import '../../domain/entities/custom_preset.dart';
import '../../domain/entities/focus_technique.dart';
import '../../domain/entities/phase_clock.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/timer_alarm.dart';
import '../mood_checkin/mood_checkin_providers.dart';
import '../settings/settings_providers.dart';

// `TimerPhase` переехала в домен: от неё зависит расчёт будильников, а он
// должен собираться и тестироваться без Flutter. Реэкспорт оставлен, чтобы
// экраны продолжали брать её отсюда — импорт фазы из «провайдеров таймера»
// читается лучше, чем из сущностей.
export '../../domain/entities/timer_alarm.dart' show TimerAlarm, TimerPhase;

const _uuid = Uuid();

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
    this.preset,
  });

  factory TimerPlan.fromRecommendation(Recommendation recommendation) {
    return TimerPlan(
      technique: recommendation.technique,
      focusMinutes: recommendation.focusMinutes,
      breakMinutes: recommendation.breakMinutes,
      cycles: recommendation.cycles,
      preset: recommendation.preset,
    );
  }

  final FocusTechnique technique;

  /// Пользовательский пресет, если сессия идёт по нему. Долетает до
  /// [SessionEntity.customTechniqueKey], а оттуда — до таблицы весов.
  final CustomPreset? preset;

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
    // Смена техники руками обнуляет пресет: иначе сессия ушла бы в
    // статистику пресета, по которому её уже не проводят.
    bool clearPreset = false,
    CustomPreset? preset,
  }) {
    return TimerPlan(
      preset: clearPreset ? null : (preset ?? this.preset),
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
    required this.clock,
    this.completedFully = false,
    this.scheduleEpoch = 0,
  });

  final TimerPlan plan;
  final TimerPhase phase;

  /// Источник правды по времени текущей фазы.
  ///
  /// [remaining] и [focusSeconds] — снимки, пересчитанные из этих часов и
  /// удобные для отрисовки; сама арифметика живёт здесь и опирается на
  /// стенные часы, а не на количество пришедших тиков.
  final PhaseClock clock;

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

  /// Счётчик событий, меняющих график будильников.
  ///
  /// Обычный тик секунды его не трогает: пересобирать системные уведомления
  /// раз в секунду — верный способ и батарею посадить, и упереться в лимиты
  /// планировщика. Растёт только там, где расчётный конец фазы действительно
  /// сдвинулся: пауза, снятие с паузы, пропуск, подкрутка диском, смена фазы,
  /// завершение.
  final int scheduleEpoch;

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
    PhaseClock? clock,
    bool bumpSchedule = false,
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
      clock: clock ?? this.clock,
      scheduleEpoch: bumpSchedule ? scheduleEpoch + 1 : scheduleEpoch,
    );
  }

  /// График будильников для текущего состояния — то, что нужно отдать
  /// системе прямо сейчас. Пустой список означает «снять всё».
  List<TimerAlarm> get alarms {
    if (finished) return const [];
    return TimerAlarmPlanner.upcoming(
      phase: phase,
      cycleIndex: cycleIndex,
      totalCycles: plan.cycles,
      remaining: remaining,
      focusDuration: Duration(minutes: plan.focusMinutes),
      breakDuration: Duration(minutes: plan.breakMinutes),
      autoStartNext: plan.autoStartNext,
      running: running,
    );
  }
}

/// Ведёт обратный отсчёт и переходы между фазами.
///
/// Время считается по стенным часам ([PhaseClock]), а не по количеству
/// пришедших тиков. Это принципиально: когда экран гаснет или приложение
/// уходит в фон, система придерживает Dart-таймеры — тики или редеют, или
/// перестают приходить вовсе. Отсчёт «по тикам» на этом отставал ровно на
/// столько, сколько телефон пролежал заблокированным, и вместе с табло врал
/// `focusSeconds`, то есть статистика и опыт.
///
/// Теперь тик — только повод перерисовать экран; сколько осталось, всегда
/// спрашивают у часов. Возврат в приложение [settle] пересчитывает состояние
/// немедленно, и отсчёт мгновенно догоняет реальность, а не доползает до неё
/// по секунде. Тот же расчёт стоит за системными будильниками
/// ([TimerAlarmPlanner]), так что экран и уведомление больше не могут
/// разъехаться: у них одна точка отсчёта.
///
/// Подкрутка диском переставляет якорь часов, а не ломает модель: остаток
/// меняется, и с этого момента отсчёт идёт от нового значения.
class TimerController extends StateNotifier<TimerState>
    with WidgetsBindingObserver {
  TimerController(
    TimerPlan plan, {
    this.onAlarm,
    DateTime Function()? clock,
    this.observeLifecycle = true,
  })  : _now = clock ?? DateTime.now,
        super(
          TimerState(
            plan: plan,
            phase: TimerPhase.focus,
            cycleIndex: 0,
            remaining: Duration(minutes: plan.focusMinutes),
            phaseTotal: Duration(minutes: plan.focusMinutes),
            running: true,
            finished: false,
            focusSeconds: 0,
            startedAt: (clock ?? DateTime.now)(),
            clock: PhaseClock.startedAt(
              (clock ?? DateTime.now)(),
              Duration(minutes: plan.focusMinutes),
            ),
          ),
        ) {
    if (observeLifecycle) {
      WidgetsBinding.instance.addObserver(this);
    }
    _start();
  }

  /// Сигнал окончания фазы — звук. Приходит извне, чтобы контроллер не знал
  /// ни про плагин аудио, ни про то, включён ли звук в настройках.
  final VoidCallback? onAlarm;

  final DateTime Function() _now;

  /// Подписываться ли на жизненный цикл приложения. Выключается в тестах,
  /// где `WidgetsBinding` может быть не поднят.
  final bool observeLifecycle;

  Timer? _ticker;

  /// Секунды фокуса, закрытые предыдущими циклами. Текущая фаза добавляется
  /// к ним из часов, а не накапливается тиками.
  int _bankedFocusSeconds = 0;

  void _start() {
    _ticker?.cancel();
    // Секунда — частота обновления картинки, не единица счёта. Если система
    // проглотит половину тиков, показанное время от этого не пострадает.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => settle());
  }

  // Параметр назван не `state`, как в базовом классе, намеренно: у
  // `StateNotifier` уже есть `state`, и одноимённый аргумент перекрыл бы его
  // внутри метода.
  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    // Вернулись на передний план — пересчитываем немедленно. Иначе первый
    // кадр после разблокировки показал бы время, застывшее на момент, когда
    // экран погас.
    if (lifecycleState == AppLifecycleState.resumed) settle();
  }

  /// Привести состояние в соответствие с текущим временем.
  ///
  /// Пока экран был заблокирован, могло пройти несколько фаз сразу, поэтому
  /// переходы делаются циклом. Звук и вибрация при этом срабатывают один
  /// раз, а не по разу на каждую пропущенную границу: человеку нужен сигнал
  /// «время вышло», а не серия сигналов задним числом.
  void settle() {
    if (state.finished) return;

    var crossedPhase = false;
    var completed = false;

    // Ограничение сверху — страховка от бесконечного цикла на вырожденном
    // плане (например, нулевой длительности фазы), а не ожидаемый режим.
    for (var guard = 0; guard < 512; guard++) {
      final now = _now();
      final clock = state.clock;

      if (!clock.running || !clock.isExpiredAt(now)) {
        _publish(now);
        break;
      }

      // Фаза истекла. Перелёт — насколько поздно мы об этом узнали.
      final overshoot = -clock.remainingAt(now);
      // Отработанное в этой фазе закрываем до перехода: дальше часы уже
      // будут принадлежать следующей фазе.
      _bankFocus(now);

      final outcome = _advancePhase(now: now, overshoot: overshoot);
      crossedPhase = true;
      if (outcome == _PhaseOutcome.finished) {
        completed = true;
        break;
      }
      if (outcome == _PhaseOutcome.paused) break;
    }

    if (!crossedPhase) return;

    // Вибрация здесь — не украшение к звуку, а самостоятельный сигнал: при
    // выключенном звуке она остаётся единственным, что человек почувствует,
    // не глядя на экран.
    if (completed) {
      Haptics.timerAlarm();
    } else {
      Haptics.cycleComplete();
    }
    onAlarm?.call();
  }

  /// Пересчитать снимки [TimerState.remaining] и [TimerState.focusSeconds]
  /// из часов. Состояние обновляется только если картинка действительно
  /// изменилась — лишние перестройки экрана раз в секунду ни к чему.
  void _publish(DateTime now) {
    final remaining = state.clock.displayRemainingAt(now);
    final focusSeconds = _focusSecondsAt(now);
    if (remaining == state.remaining && focusSeconds == state.focusSeconds) {
      return;
    }
    state = state.copyWith(remaining: remaining, focusSeconds: focusSeconds);
  }

  int _focusSecondsAt(DateTime now) {
    if (state.phase != TimerPhase.focus) return _bankedFocusSeconds;
    return _bankedFocusSeconds + state.clock.servedAt(now).inSeconds;
  }

  /// Перевести таймер в следующую фазу. Возвращает, что с ним стало: можно
  /// ли продолжать разбор пропущенного времени.
  _PhaseOutcome _advancePhase({
    required DateTime now,
    required Duration overshoot,
  }) {
    final plan = state.plan;

    if (state.phase == TimerPhase.focus) {
      final isLastCycle = state.cycleIndex >= plan.cycles - 1;
      if (isLastCycle) {
        _finish(completedFully: true, bankFocus: false);
        return _PhaseOutcome.finished;
      }

      final breakDuration = Duration(minutes: plan.breakMinutes);
      state = state.copyWith(
        phase: TimerPhase.rest,
        remaining: breakDuration,
        phaseTotal: breakDuration,
        running: plan.autoStartNext,
        focusSeconds: _bankedFocusSeconds,
        clock: state.clock.nextPhase(
          duration: breakDuration,
          running: plan.autoStartNext,
          overshoot: overshoot,
          now: now,
        ),
        bumpSchedule: true,
      );
      return plan.autoStartNext ? _PhaseOutcome.running : _PhaseOutcome.paused;
    }

    // Перерыв закончился — следующий цикл фокуса.
    final focusDuration = Duration(minutes: plan.focusMinutes);
    state = state.copyWith(
      phase: TimerPhase.focus,
      cycleIndex: state.cycleIndex + 1,
      remaining: focusDuration,
      phaseTotal: focusDuration,
      running: plan.autoStartNext,
      clock: state.clock.nextPhase(
        duration: focusDuration,
        running: plan.autoStartNext,
        overshoot: overshoot,
        now: now,
      ),
      bumpSchedule: true,
    );
    return plan.autoStartNext ? _PhaseOutcome.running : _PhaseOutcome.paused;
  }

  void pause() {
    if (state.finished || !state.running) return;
    final now = _now();
    // Пауза закрывает отработанный кусок фокуса: дальше часы стоят, и
    // добавлять к банку станет нечего.
    _bankFocus(now);
    state = state.copyWith(
      running: false,
      remaining: state.clock.displayRemainingAt(now),
      focusSeconds: _bankedFocusSeconds,
      clock: state.clock.pausedAt(now),
      bumpSchedule: true,
    );
  }

  /// Перенести отработанное текущей фазой в банк.
  ///
  /// Вызов идемпотентен, пока часы не переставили: [PhaseClock.servedAt]
  /// остановленных часов равен нулю, а живые дают ту же величину, что уже
  /// учтена. Это важно — банк трогают и пауза, и пропуск, и завершение.
  void _bankFocus(DateTime now) {
    if (state.phase != TimerPhase.focus) return;
    _bankedFocusSeconds = _focusSecondsAt(now);
  }

  void resume() {
    if (state.finished || state.running) return;
    state = state.copyWith(
      running: true,
      clock: state.clock.resumedAt(_now()),
      bumpSchedule: true,
    );
  }

  void toggle() => state.running ? pause() : resume();

  /// Пропустить текущую фазу целиком.
  void skipPhase() {
    if (state.finished) return;
    final now = _now();
    // Обнуляем остаток и запускаем часы, чтобы разбор в [settle] увидел
    // истёкшую фазу и провёл переход по общему пути.
    _bankFocus(now);
    state = state.copyWith(
      remaining: Duration.zero,
      focusSeconds: _bankedFocusSeconds,
      clock: PhaseClock(plannedRemaining: Duration.zero, runningSince: now),
    );
    settle();
  }

  /// Подкрутка диском. Оставшееся время не может уйти ниже нуля; если его
  /// увеличили сверх исходной длительности фазы, растёт и знаменатель
  /// прогресса — иначе кольцо «переполнилось» бы.
  void adjustMinutes(int delta) {
    if (state.finished) return;
    final now = _now();
    final next = state.clock.displayRemainingAt(now) + Duration(minutes: delta);
    final clamped = next.isNegative ? Duration.zero : next;
    state = state.copyWith(
      remaining: clamped,
      phaseTotal: clamped > state.phaseTotal ? clamped : state.phaseTotal,
      // Диск переставляет якорь часов: с этого момента отсчёт идёт от нового
      // остатка, и расчётный конец фазы — вместе с ним.
      clock: state.clock.withRemaining(clamped, now),
      // А значит, и запланированное уведомление должно переехать.
      bumpSchedule: true,
    );
  }

  /// Досрочная остановка пользователем.
  void stop() => _finish(completedFully: false);

  void _finish({required bool completedFully, bool bankFocus = true}) {
    _ticker?.cancel();
    _ticker = null;
    final now = _now();
    // При разборе пропущенного времени фаза уже закрыта в [settle] — второй
    // раз её отрабатывать нельзя.
    if (bankFocus) _bankFocus(now);
    state = state.copyWith(
      running: false,
      finished: true,
      completedFully: completedFully,
      remaining: Duration.zero,
      focusSeconds: _bankedFocusSeconds,
      clock: const PhaseClock.paused(Duration.zero),
      bumpSchedule: true,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    if (observeLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }
}

/// Во что перешёл таймер после границы фазы.
enum _PhaseOutcome {
  /// Следующая фаза идёт — можно разбирать пропущенное время дальше.
  running,

  /// Следующая фаза ждёт нажатия: `autoStartNext` выключен.
  paused,

  /// Сессия закончена.
  finished,
}

/// План устанавливается до перехода на экран таймера.
final timerPlanProvider = StateProvider<TimerPlan?>((ref) => null);

/// Чем конец сессии обозначит себя в системе.
///
/// Собирается из тех же настроек, что и звук внутри приложения, и уходит в
/// канал уведомления. Это принципиальный момент: выбранный пресет должен
/// попасть именно в систему — она играет его тогда, когда нашего процесса
/// уже нет, а плеер приложения в этот момент не существует.
final timerAlarmSignalProvider = Provider<TimerAlarmSignal>((ref) {
  final plan = ref.watch(timerPlanProvider);
  final soundOn =
      (plan?.soundOnEnd ?? true) && ref.watch(soundsEnabledProvider);
  return TimerAlarmSignal(
    sound: soundOn ? ref.watch(alarmSoundProvider) : null,
    vibrate: ref.watch(vibrationEnabledProvider),
  );
});

final timerControllerProvider =
    StateNotifierProvider.autoDispose<TimerController, TimerState>((ref) {
  final plan = ref.watch(timerPlanProvider);
  if (plan == null) {
    throw StateError('timerPlanProvider must be set before opening the timer');
  }
  // Звук конца сессии здесь больше не проигрывается.
  //
  // Раньше это был единственный его источник — и ровно в этом была причина
  // «в фоне звука нет»: колбэк приходит из тика Dart-таймера, а тик живёт
  // только пока изолят приложения активен на переднем плане. Стоило погасить
  // экран или свернуть приложение, как играть сигнал становилось некому:
  // система про выбранный пресет ничего не знала, в канал уведомления он не
  // попадал никогда.
  //
  // Теперь звук и вибрацию даёт сам канал уведомления (см.
  // [TimerAlarmSignal]), и он звучит одинаково во всех состояниях —
  // на переднем плане, в фоне и при выгруженном процессе. Оставить рядом
  // ещё и плеер значило бы просто слышать сигнал дважды, когда приложение
  // открыто.
  //
  // `AlarmSoundPlayer` при этом никуда не делся: он проигрывает пресет при
  // выборе в настройках, где никакого уведомления нет и быть не должно.
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
      customTechniqueKey: state.plan.preset?.key,
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
      // Фото прикладывалось до старта и просто едет с сессией в историю:
      // ни на рекомендацию, ни на игровой слой оно не влияет.
      photoPath: draft.photoPath,
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
