import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/domain/entities/focus_technique.dart';
import 'package:texfi_fokus/domain/entities/insight.dart';
import 'package:texfi_fokus/domain/entities/mood.dart';
import 'package:texfi_fokus/domain/entities/recommendation.dart';
import 'package:texfi_fokus/domain/entities/session_entity.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';

int _counter = 0;

SessionEntity _session({
  required DateTime at,
  required bool success,
  Mood mood = Mood.neutral,
  FocusTechnique technique = FocusTechnique.pomodoro2505,
  int focusSeconds = 1500,
}) {
  return SessionEntity(
    id: 's${_counter++}',
    taskTitle: 'task',
    category: TaskCategory.work,
    difficulty: TaskDifficulty.medium,
    mood: mood,
    technique: technique,
    plannedFocusMinutes: 25,
    plannedBreakMinutes: 5,
    plannedCycles: 4,
    actualFocusSeconds: focusSeconds,
    outcome: success ? SessionOutcome.completed : SessionOutcome.aborted,
    startedAt: at,
    endedAt: at.add(const Duration(minutes: 25)),
    contextKey: 'neutral|work|medium|morning|1',
  );
}

void main() {
  final today = DateTime(2026, 3, 15);

  test('nothing is claimed on a thin history', () {
    final sessions = [
      for (var i = 0; i < 5; i++)
        _session(at: today.subtract(Duration(days: i)), success: true),
    ];
    expect(InsightBuilder.build(sessions, today), isNull);
  });

  test('a single dominant bucket is not enough on its own', () {
    // Все сессии в одном настроении: сравнивать не с чем, и утверждать
    // «это твоё сильное состояние» было бы враньём.
    final sessions = [
      for (var i = 0; i < 10; i++)
        _session(
          at: today.subtract(Duration(days: i)),
          success: true,
          mood: Mood.good,
        ),
    ];
    final insight = InsightBuilder.build(sessions, today);
    expect(insight?.kind, isNot(InsightKind.bestMood));
  });

  test('a clear mood pattern is surfaced with its real numbers', () {
    final sessions = <SessionEntity>[
      // full f0kus: 6 из 6 доведены.
      for (var i = 0; i < 6; i++)
        _session(
          at: today.subtract(Duration(days: i)),
          success: true,
          mood: Mood.fullFokus,
        ),
      // bad: 1 из 6.
      for (var i = 0; i < 6; i++)
        _session(
          at: today.subtract(Duration(days: i + 6)),
          success: i == 0,
          mood: Mood.bad,
        ),
    ];

    final insight = InsightBuilder.build(sessions, today);
    expect(insight, isNotNull);
    expect(insight!.kind, InsightKind.bestMood);
    expect(insight.mood, Mood.fullFokus);
    expect(insight.percent, 100);
    expect(insight.sampleSize, 6);
  });

  test('a weekday pattern is measured in focus time, not completions', () {
    final sessions = <SessionEntity>[
      // Вторники: по часу.
      for (var i = 0; i < 4; i++)
        _session(
          at: DateTime(2026, 2, 3).add(Duration(days: 7 * i)),
          success: true,
          focusSeconds: 3600,
        ),
      // Прочие дни: по десять минут, столько же сессий и та же доводимость.
      for (var i = 0; i < 4; i++)
        _session(
          at: DateTime(2026, 2, 5).add(Duration(days: 7 * i)),
          success: true,
          focusSeconds: 600,
        ),
    ];

    final insight = InsightBuilder.build(sessions, today);
    expect(insight, isNotNull);
    expect(insight!.kind, InsightKind.bestWeekday);
    expect(insight.weekday, DateTime.tuesday);
    expect(insight.minutes, 60);
  });

  test('a technique pattern beats a coin-flip spread', () {
    final sessions = <SessionEntity>[
      for (var i = 0; i < 6; i++)
        _session(
          at: today.subtract(Duration(days: i)),
          success: true,
          technique: FocusTechnique.sprint15,
        ),
      for (var i = 0; i < 6; i++)
        _session(
          at: today.subtract(Duration(days: i + 6)),
          success: false,
          technique: FocusTechnique.deepWork90,
        ),
    ];

    final insight = InsightBuilder.build(sessions, today);
    expect(insight, isNotNull);
    expect(insight!.kind, InsightKind.bestTechnique);
    expect(insight.technique, FocusTechnique.sprint15);
  });

  test('the time-of-day bucket comes from the real start hour', () {
    final sessions = <SessionEntity>[
      for (var i = 0; i < 6; i++)
        _session(
          at: today.subtract(Duration(days: i)).add(const Duration(hours: 20)),
          success: true,
          technique: FocusTechnique.sprint15,
          mood: Mood.good,
        ),
      for (var i = 0; i < 6; i++)
        _session(
          at: today.subtract(Duration(days: i)).add(const Duration(hours: 7)),
          success: false,
          technique: FocusTechnique.sprint15,
          mood: Mood.good,
        ),
    ];

    final insight = InsightBuilder.build(sessions, today);
    expect(insight, isNotNull);
    expect(insight!.kind, InsightKind.bestTimeOfDay);
    expect(insight.timeOfDay, TimeOfDayBucket.evening);
    expect(insight.percent, 100);
  });

  test('the pick is stable within a day and rotates across days', () {
    // Два равносильных наблюдения: настроение и техника совпадают
    // один-в-один по объёму данных.
    final sessions = <SessionEntity>[
      for (var i = 0; i < 6; i++)
        _session(
          at: today.subtract(Duration(days: i)),
          success: true,
          mood: Mood.fullFokus,
          technique: FocusTechnique.sprint15,
        ),
      for (var i = 0; i < 6; i++)
        _session(
          at: today.subtract(Duration(days: i + 6)),
          success: false,
          mood: Mood.bad,
          technique: FocusTechnique.deepWork90,
        ),
    ];

    final first = InsightBuilder.build(sessions, today);
    final again = InsightBuilder.build(sessions, today);
    expect(first!.kind, again!.kind);

    final kinds = <InsightKind>{};
    for (var i = 0; i < 7; i++) {
      final result =
          InsightBuilder.build(sessions, today.add(Duration(days: i)));
      if (result != null) kinds.add(result.kind);
    }
    expect(kinds.length, greaterThan(1),
        reason: 'the card must not repeat the same line every single day');
  });
}
