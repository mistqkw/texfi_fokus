import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/domain/entities/focus_technique.dart';
import 'package:texfi_fokus/domain/entities/mood.dart';
import 'package:texfi_fokus/domain/entities/recommendation.dart';
import 'package:texfi_fokus/domain/entities/session_entity.dart';
import 'package:texfi_fokus/domain/entities/session_guards.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';

SessionEntity _session({
  required SessionOutcome outcome,
  DateTime? endedAt,
}) {
  final end = endedAt ?? DateTime(2026, 3, 1, 12);
  return SessionEntity(
    id: 's-${end.microsecondsSinceEpoch}-${outcome.name}',
    taskTitle: 'task',
    category: TaskCategory.work,
    difficulty: TaskDifficulty.medium,
    mood: Mood.neutral,
    technique: FocusTechnique.pomodoro2505,
    plannedFocusMinutes: 25,
    plannedBreakMinutes: 5,
    plannedCycles: 4,
    actualFocusSeconds: 600,
    outcome: outcome,
    startedAt: end.subtract(const Duration(minutes: 30)),
    endedAt: end,
    contextKey: 'neutral|work|medium|afternoon|1',
  );
}

Recommendation _recommendation(FocusTechnique technique) =>
    Recommendation.ofTechnique(
      technique,
      reason: RecommendationReason.learned,
      confidence: 0.8,
      sampleSize: 12,
    );

void main() {
  group('short break warning', () {
    final now = DateTime(2026, 3, 1, 12, 30);

    test('a session started right after the previous one is flagged', () {
      expect(
        SessionGuards.needsShortBreakWarning(
          lastEndedAt: now.subtract(const Duration(minutes: 2)),
          now: now,
        ),
        isTrue,
      );
    });

    test('exactly the threshold is already enough of a break', () {
      // Граница включительно в пользу пользователя: ровно пять минут — это
      // выполненное условие, а не «почти».
      expect(
        SessionGuards.needsShortBreakWarning(
          lastEndedAt: now.subtract(const Duration(minutes: 5)),
          now: now,
        ),
        isFalse,
      );
    });

    test('the threshold is configurable in both directions', () {
      final lastEnded = now.subtract(const Duration(minutes: 7));
      expect(
        SessionGuards.needsShortBreakWarning(
          lastEndedAt: lastEnded,
          now: now,
          minGapMinutes: 10,
        ),
        isTrue,
      );
      expect(
        SessionGuards.needsShortBreakWarning(
          lastEndedAt: lastEnded,
          now: now,
          minGapMinutes: 3,
        ),
        isFalse,
      );
    });

    test('zero minutes turns the warning off entirely', () {
      expect(
        SessionGuards.needsShortBreakWarning(
          lastEndedAt: now.subtract(const Duration(seconds: 1)),
          now: now,
          minGapMinutes: 0,
        ),
        isFalse,
      );
    });

    test('no previous session and clock jumps back are not warnings', () {
      expect(
        SessionGuards.needsShortBreakWarning(lastEndedAt: null, now: now),
        isFalse,
      );
      expect(
        SessionGuards.needsShortBreakWarning(
          lastEndedAt: now.add(const Duration(hours: 1)),
          now: now,
        ),
        isFalse,
      );
    });
  });

  group('burnout streak', () {
    test('three aborted sessions in a row trip it', () {
      final sessions = [
        for (var i = 0; i < 3; i++) _session(outcome: SessionOutcome.aborted),
      ];
      expect(SessionGuards.isBurnoutStreak(sessions), isTrue);
    });

    test('two are not a pattern yet', () {
      final sessions = [
        _session(outcome: SessionOutcome.aborted),
        _session(outcome: SessionOutcome.aborted),
      ];
      expect(SessionGuards.isBurnoutStreak(sessions), isFalse);
    });

    test('a finished session anywhere in the window breaks the streak', () {
      final sessions = [
        _session(outcome: SessionOutcome.aborted),
        _session(outcome: SessionOutcome.completed),
        _session(outcome: SessionOutcome.aborted),
      ];
      expect(SessionGuards.isBurnoutStreak(sessions), isFalse);
    });

    test('only the newest sessions count, older failures do not', () {
      final sessions = [
        _session(outcome: SessionOutcome.completed),
        _session(outcome: SessionOutcome.aborted),
        _session(outcome: SessionOutcome.aborted),
        _session(outcome: SessionOutcome.aborted),
      ];
      expect(SessionGuards.isBurnoutStreak(sessions), isFalse);
    });

    test('an empty history is not a burnout', () {
      expect(SessionGuards.isBurnoutStreak(const []), isFalse);
    });
  });

  group('night soft cap', () {
    test('late hours clamp a long session down to a pomodoro', () {
      final capped = SessionGuards.capForNight(
        _recommendation(FocusTechnique.deepWork90),
        hour: 23,
      );
      expect(capped.technique, FocusTechnique.pomodoro2505);
      expect(capped.focusMinutes, 25);
      expect(capped.breakMinutes, 5);
      expect(capped.cappedForNight, isTrue);
      // Объяснение движка кап не стирает — иначе экран потерял бы «почему».
      expect(capped.reason, RecommendationReason.learned);
      expect(capped.sampleSize, 12);
    });

    test('the small hours count as night too', () {
      final capped = SessionGuards.capForNight(
        _recommendation(FocusTechnique.pomodoro5010),
        hour: 2,
      );
      expect(capped.technique, FocusTechnique.pomodoro2505);
      expect(capped.cappedForNight, isTrue);
    });

    test('an already short session is left alone', () {
      // Кап только укорачивает. Дотягивать спринт вверх до помидора было бы
      // ровно обратным тому, ради чего он существует.
      final capped = SessionGuards.capForNight(
        _recommendation(FocusTechnique.sprint15),
        hour: 1,
      );
      expect(capped.technique, FocusTechnique.sprint15);
      expect(capped.cappedForNight, isFalse);
    });

    test('daytime never caps', () {
      for (final hour in [6, 12, 18, 22]) {
        final capped = SessionGuards.capForNight(
          _recommendation(FocusTechnique.deepWork90),
          hour: hour,
        );
        expect(capped.technique, FocusTechnique.deepWork90, reason: '$hour h');
        expect(capped.cappedForNight, isFalse, reason: '$hour h');
      }
    });

    test('the cap hour is configurable', () {
      final capped = SessionGuards.capForNight(
        _recommendation(FocusTechnique.deepWork90),
        hour: 21,
        capHour: 21,
      );
      expect(capped.cappedForNight, isTrue);

      final untouched = SessionGuards.capForNight(
        _recommendation(FocusTechnique.deepWork90),
        hour: 23,
        capHour: 24,
      );
      expect(untouched.cappedForNight, isFalse);
    });
  });
}
