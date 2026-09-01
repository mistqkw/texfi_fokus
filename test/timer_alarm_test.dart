import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/domain/entities/focus_technique.dart';
import 'package:texfi_fokus/domain/entities/timer_alarm.dart';
import 'package:texfi_fokus/presentation/timer/timer_providers.dart';

/// Что здесь проверяется и почему именно так.
///
/// Уведомление о конце сессии раньше держалось на живом Dart-таймере: пока
/// приложение открыто — приходило, стоило свернуть или выгрузить его из
/// памяти — исчезало вместе с процессом. Теперь весь график считается
/// заранее и отдаётся системе, а значит, его правильность — это чистая
/// арифметика, которую можно и нужно проверять без устройства.
///
/// Само срабатывание уведомления, вибрацию в беззвучном режиме и точность в
/// Doze тестами не поймать — там нужна реальная трубка. Зато можно
/// гарантировать, что системе уходит ровно тот график, который соответствует
/// состоянию таймера, и что он снимается там, где должен.
void main() {
  List<TimerAlarm> plan({
    TimerPhase phase = TimerPhase.focus,
    int cycleIndex = 0,
    int totalCycles = 1,
    Duration remaining = const Duration(minutes: 25),
    Duration focus = const Duration(minutes: 25),
    Duration rest = const Duration(minutes: 5),
    bool autoStartNext = true,
    bool running = true,
  }) {
    return TimerAlarmPlanner.upcoming(
      phase: phase,
      cycleIndex: cycleIndex,
      totalCycles: totalCycles,
      remaining: remaining,
      focusDuration: focus,
      breakDuration: rest,
      autoStartNext: autoStartNext,
      running: running,
    );
  }

  group('TimerAlarmPlanner', () {
    test('одноцикловая сессия даёт один финальный будильник', () {
      final alarms = plan();

      expect(alarms, hasLength(1));
      expect(alarms.single.after, const Duration(minutes: 25));
      expect(alarms.single.endingPhase, TimerPhase.focus);
      expect(alarms.single.cycleNumber, 1);
      expect(alarms.single.isFinal, isTrue);
    });

    test('многоцикловая сессия расписана до конца, с чередованием фаз', () {
      final alarms = plan(totalCycles: 3);

      // 25 фокуса, 5 перерыва, 25, 5, 25 — и на этом сессия кончается.
      expect(
        alarms.map((a) => a.after.inMinutes).toList(),
        [25, 30, 55, 60, 85],
      );
      expect(
        alarms.map((a) => a.endingPhase).toList(),
        [
          TimerPhase.focus,
          TimerPhase.rest,
          TimerPhase.focus,
          TimerPhase.rest,
          TimerPhase.focus,
        ],
      );
      expect(alarms.map((a) => a.cycleNumber).toList(), [1, 1, 2, 2, 3]);

      // Финальный ровно один, и он последний: иначе пользователь получил бы
      // «сессия завершена» посреди сессии.
      expect(alarms.where((a) => a.isFinal), hasLength(1));
      expect(alarms.last.isFinal, isTrue);
    });

    test('без автостарта дальше текущей фазы не заглядываем', () {
      final alarms = plan(totalCycles: 3, autoStartNext: false);

      // Когда пользователь нажмёт «дальше» — неизвестно, и всё, что стояло бы
      // за этой точкой, было бы выдумкой.
      expect(alarms, hasLength(1));
      expect(alarms.single.after, const Duration(minutes: 25));
      expect(alarms.single.isFinal, isFalse);
    });

    test('пауза снимает график целиком', () {
      expect(plan(totalCycles: 3, running: false), isEmpty);
    });

    test('вышедшее время не порождает будильников', () {
      expect(plan(remaining: Duration.zero), isEmpty);
      expect(plan(remaining: const Duration(seconds: -30)), isEmpty);
    });

    test('подкрутка диском сдвигает весь хвост графика', () {
      final before = plan(totalCycles: 2);
      final after = plan(totalCycles: 2, remaining: const Duration(minutes: 40));

      expect(before.map((a) => a.after.inMinutes).toList(), [25, 30, 55]);
      // +15 минут к текущей фазе — на те же 15 уезжает всё, что за ней.
      expect(after.map((a) => a.after.inMinutes).toList(), [40, 45, 70]);
    });

    test('счёт идёт от текущей фазы, а не от начала сессии', () {
      final alarms = plan(
        phase: TimerPhase.rest,
        cycleIndex: 0,
        totalCycles: 2,
        remaining: const Duration(minutes: 2),
      );

      // Осталось 2 минуты перерыва, потом полный цикл фокуса — и конец.
      expect(alarms.map((a) => a.after.inMinutes).toList(), [2, 27]);
      expect(alarms.first.endingPhase, TimerPhase.rest);
      expect(alarms.last.isFinal, isTrue);
      expect(alarms.last.cycleNumber, 2);
    });

    test('длинная сессия обрезается по лимиту очереди', () {
      final alarms = plan(totalCycles: 40);

      expect(alarms, hasLength(TimerAlarmPlanner.maxAlarms));
      // Обрезанный хвост не должен притвориться концом сессии.
      expect(alarms.any((a) => a.isFinal), isFalse);
    });

    test('нулевой перерыв не сворачивает расчёт в бесконечный цикл', () {
      final alarms = plan(totalCycles: 5, rest: Duration.zero);

      // Фазы не могут смениться в одну и ту же секунду — расчёт
      // останавливается, а не крутится вечно.
      expect(alarms, hasLength(1));
      expect(alarms.single.after, const Duration(minutes: 25));
    });

    test('нулевое число циклов не даёт графика', () {
      expect(plan(totalCycles: 0), isEmpty);
    });
  });

  group('TimerState.alarms', () {
    TimerState stateFor(TimerPlan p) => TimerState(
          plan: p,
          phase: TimerPhase.focus,
          cycleIndex: 0,
          remaining: Duration(minutes: p.focusMinutes),
          phaseTotal: Duration(minutes: p.focusMinutes),
          running: true,
          finished: false,
          focusSeconds: 0,
          startedAt: DateTime(2026),
        );

    const plan2 = TimerPlan(
      technique: FocusTechnique.pomodoro2505,
      focusMinutes: 25,
      breakMinutes: 5,
      cycles: 2,
    );

    test('идущая сессия отдаёт полный график', () {
      expect(
        stateFor(plan2).alarms.map((a) => a.after.inMinutes).toList(),
        [25, 30, 55],
      );
    });

    test('завершённая сессия — пустой график', () {
      final finished = stateFor(plan2).copyWith(finished: true, running: false);
      expect(finished.alarms, isEmpty);
    });

    test('пауза — пустой график', () {
      expect(stateFor(plan2).copyWith(running: false).alarms, isEmpty);
    });
  });

  group('scheduleEpoch', () {
    const plan1 = TimerPlan(
      technique: FocusTechnique.pomodoro2505,
      focusMinutes: 25,
      breakMinutes: 5,
      cycles: 1,
    );

    TimerState base() => TimerState(
          plan: plan1,
          phase: TimerPhase.focus,
          cycleIndex: 0,
          remaining: const Duration(minutes: 25),
          phaseTotal: const Duration(minutes: 25),
          running: true,
          finished: false,
          focusSeconds: 0,
          startedAt: DateTime(2026),
        );

    test('тик секунды график не трогает', () {
      final state = base();
      // Именно это отличает тик от всего остального: пересобирать системные
      // уведомления шестьдесят раз в минуту нельзя.
      final ticked = state.copyWith(
        remaining: const Duration(minutes: 24, seconds: 59),
        focusSeconds: 1,
      );

      expect(ticked.scheduleEpoch, state.scheduleEpoch);
    });

    test('изменение конца фазы поднимает epoch', () {
      final state = base();
      expect(state.copyWith(running: false, bumpSchedule: true).scheduleEpoch,
          state.scheduleEpoch + 1);
    });
  });
}
