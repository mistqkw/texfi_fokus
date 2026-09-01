import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/data/recommendation/bandit_recommendation_engine.dart';
import 'package:texfi_fokus/domain/entities/focus_technique.dart';
import 'package:texfi_fokus/domain/entities/mood.dart';
import 'package:texfi_fokus/domain/entities/recommendation.dart';
import 'package:texfi_fokus/domain/entities/recommendation_weight_entity.dart';
import 'package:texfi_fokus/domain/entities/session_entity.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';
import 'package:texfi_fokus/domain/repositories/recommendation_weight_repository.dart';
import 'package:texfi_fokus/domain/repositories/session_repository.dart';

/// Веса в обычной Map — тест проверяет алгоритм, а не drift.
class _FakeWeights implements RecommendationWeightRepository {
  final Map<String, RecommendationWeightEntity> _rows = {};

  String _id(String contextKey, String techniqueKey) =>
      '$contextKey##$techniqueKey';

  @override
  Future<List<RecommendationWeightEntity>> weightsForContext(String key) async {
    return _rows.values.where((w) => w.contextKey == key).toList();
  }

  @override
  Future<Map<String, List<RecommendationWeightEntity>>> weightsForContexts(
    List<String> keys,
  ) async {
    return {
      for (final key in keys)
        key: _rows.values.where((w) => w.contextKey == key).toList(),
    };
  }

  @override
  Future<void> upsertWeight(RecommendationWeightEntity weight) async {
    _rows[_id(weight.contextKey, weight.techniqueKey)] = weight;
  }

  @override
  Future<List<RecommendationWeightEntity>> allWeights() async =>
      _rows.values.toList();

  @override
  Future<void> clear() async => _rows.clear();
}

/// Из всего репозитория сессий движку нужен только счётчик.
class _FakeSessions implements SessionRepository {
  _FakeSessions(this.count);

  int count;

  @override
  Future<int> totalSessionCount() async => count;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not used in tests');
}

const _context = RecommendationContext(
  mood: Mood.good,
  category: TaskCategory.work,
  difficulty: TaskDifficulty.hard,
  timeOfDay: TimeOfDayBucket.morning,
  weekday: 3,
);

SessionEntity _session({
  required FocusTechnique technique,
  required bool success,
  DateTime? at,
}) {
  final moment = at ?? DateTime(2026, 1, 10, 9);
  return SessionEntity(
    id: 's-${moment.microsecondsSinceEpoch}-${technique.key}-$success',
    taskTitle: 'task',
    category: _context.category,
    difficulty: _context.difficulty,
    mood: _context.mood,
    technique: technique,
    plannedFocusMinutes: technique.focusMinutes,
    plannedBreakMinutes: technique.breakMinutes,
    plannedCycles: technique.cycles,
    actualFocusSeconds: technique.focusMinutes * 60,
    outcome: success ? SessionOutcome.completed : SessionOutcome.aborted,
    startedAt: moment,
    endedAt: moment.add(const Duration(minutes: 30)),
    contextKey: _context.key,
  );
}

/// Прогоняет N рекомендаций и возвращает, сколько раз выпала каждая техника.
Future<Map<FocusTechnique, int>> _sample(
  BanditRecommendationEngine engine,
  int runs,
) async {
  final counts = <FocusTechnique, int>{};
  for (var i = 0; i < runs; i++) {
    final rec = await engine.recommend(_context);
    counts[rec.technique] = (counts[rec.technique] ?? 0) + 1;
  }
  return counts;
}

void main() {
  group('RecommendationContext', () {
    test('key hierarchy goes from the exact context to the broadest', () {
      expect(_context.keyHierarchy, [
        'good|work|hard|morning|3',
        'good|work|hard',
        'good|work',
        'good|d:hard',
        'good|t:morning',
        'good',
      ]);
    });

    test('coarse tiers never collide across dimensions', () {
      // Ключи сложности и времени суток лежат в своих пространствах имён —
      // иначе `good|hard` от `good|work` отличалось бы только словарём.
      final keys = _context.keyHierarchy.toSet();
      expect(keys.length, _context.keyHierarchy.length);
      expect(_context.difficultyKey.contains('d:'), isTrue);
      expect(_context.timeKey.contains('t:'), isTrue);
    });

    test('a stored context key round-trips back into a context', () {
      final parsed = RecommendationContext.tryParse(_context.key);
      expect(parsed, isNotNull);
      expect(parsed!.keyHierarchy, _context.keyHierarchy);
    });

    test('a malformed context key parses to null instead of throwing', () {
      expect(RecommendationContext.tryParse('garbage'), isNull);
      expect(RecommendationContext.tryParse('good|work'), isNull);
    });
  });

  group('RecommendationWeightEntity decay', () {
    final base = RecommendationWeightEntity(
      contextKey: 'good|work',
      techniqueKey: FocusTechnique.sprint15.key,
      alpha: 11, // 10 наблюдений успеха поверх априорной единицы
      beta: 1,
      updatedAt: DateTime(2026, 1, 1),
    );

    test('observations halve over one half-life', () {
      final halfLife = Duration(
        days: RecommendationWeightEntity.defaultHalfLifeDays.toInt(),
      );
      final aged = base.decayedTo(DateTime(2026, 1, 1).add(halfLife));
      expect(aged.observations, closeTo(5, 0.01));
      // Априорная единица не затухает: Beta(1,1) — это незнание, а не
      // наблюдение.
      expect(aged.alpha, closeTo(6, 0.01));
      expect(aged.beta, closeTo(1, 0.01));
    });

    test('fresh weights are untouched and the past is not resurrected', () {
      expect(base.decayedTo(DateTime(2026, 1, 1)).alpha, base.alpha);
      // Часы назад по времени не должны раздувать статистику.
      expect(base.decayedTo(DateTime(2025, 1, 1)).alpha, base.alpha);
    });

    test('an update decays the old evidence before adding the new one', () {
      final updated = base.updated(
        success: false,
        at: DateTime(2026, 1, 1).add(const Duration(days: 45)),
      );
      expect(updated.alpha, closeTo(6, 0.01));
      expect(updated.beta, closeTo(2, 0.01));
    });

    test('repeated updates keep the counts bounded', () {
      // Без затухания alpha росла бы линейно и через год сделала бы движок
      // невосприимчивым к переменам. Проверяем, что этого не происходит.
      var weight = RecommendationWeightEntity.prior(
        contextKey: 'good',
        techniqueKey: FocusTechnique.sprint15.key,
        updatedAt: DateTime(2026, 1, 1),
      );
      var day = DateTime(2026, 1, 1);
      for (var i = 0; i < 365; i++) {
        day = day.add(const Duration(days: 1));
        weight = weight.updated(success: true, at: day);
      }
      expect(weight.observations, lessThan(80));
      expect(weight.observations, greaterThan(30));
    });
  });

  group('BanditRecommendationEngine', () {
    test('cold start uses the spec defaults and says how far it is', () async {
      final engine = BanditRecommendationEngine(
        weights: _FakeWeights(),
        sessions: _FakeSessions(4),
        random: Random(1),
      );

      final rec = await engine.recommend(_context);
      expect(rec.reason, RecommendationReason.coldStart);
      expect(rec.technique, FocusTechnique.pomodoro5010); // good + hard
      expect(rec.evidence.sessionsUntilPersonalized, 6);
      expect(rec.evidence.hasData, isFalse);
    });

    test('one outcome is recorded on every tier of the hierarchy', () async {
      final weights = _FakeWeights();
      final engine = BanditRecommendationEngine(
        weights: weights,
        sessions: _FakeSessions(20),
        random: Random(1),
      );

      await engine.recordOutcome(
        _session(technique: FocusTechnique.sprint15, success: true),
      );

      final all = await weights.allWeights();
      expect(
        all.map((w) => w.contextKey).toSet(),
        _context.keyHierarchy.toSet(),
      );
      // Вклад убывает от точного ключа к широкому.
      final exact = all.firstWhere((w) => w.contextKey == _context.key);
      final broad = all.firstWhere((w) => w.contextKey == _context.moodKey);
      expect(exact.alpha, greaterThan(broad.alpha));
    });

    test('a session recorded with a broken context key is not lost', () async {
      final weights = _FakeWeights();
      final engine = BanditRecommendationEngine(
        weights: weights,
        sessions: _FakeSessions(20),
        random: Random(1),
      );

      final session = _session(
        technique: FocusTechnique.sprint15,
        success: true,
      );
      await engine.recordOutcome(
        SessionEntity(
          id: session.id,
          taskTitle: session.taskTitle,
          category: session.category,
          difficulty: session.difficulty,
          mood: session.mood,
          technique: session.technique,
          plannedFocusMinutes: session.plannedFocusMinutes,
          plannedBreakMinutes: session.plannedBreakMinutes,
          plannedCycles: session.plannedCycles,
          actualFocusSeconds: session.actualFocusSeconds,
          outcome: session.outcome,
          startedAt: session.startedAt,
          endedAt: session.endedAt,
          contextKey: 'good|work',
        ),
      );

      expect(await weights.allWeights(), isNotEmpty);
    });

    test('it converges on what actually worked for this user', () async {
      final weights = _FakeWeights();
      final engine = BanditRecommendationEngine(
        weights: weights,
        sessions: _FakeSessions(40),
        random: Random(7),
      );

      var day = DateTime(2026, 1, 1);
      for (var i = 0; i < 12; i++) {
        day = day.add(const Duration(days: 1));
        await engine.recordOutcome(
          _session(technique: FocusTechnique.sprint15, success: true, at: day),
        );
        await engine.recordOutcome(
          _session(
            technique: FocusTechnique.deepWork90,
            success: false,
            at: day,
          ),
        );
      }

      final counts = await _sample(engine, 200);
      expect(counts[FocusTechnique.sprint15] ?? 0, greaterThan(120));
      expect(counts[FocusTechnique.deepWork90] ?? 0, lessThan(40));
    });

    test('recent evidence outweighs an old opposite pattern', () async {
      final weights = _FakeWeights();
      var now = DateTime(2026, 1, 1);
      final engine = BanditRecommendationEngine(
        weights: weights,
        sessions: _FakeSessions(60),
        random: Random(11),
        clock: () => now,
      );

      // Полгода назад человеку заходил deep work.
      for (var i = 0; i < 15; i++) {
        await engine.recordOutcome(
          _session(
            technique: FocusTechnique.deepWork90,
            success: true,
            at: now,
          ),
        );
        await engine.recordOutcome(
          _session(technique: FocusTechnique.sprint15, success: false, at: now),
        );
        now = now.add(const Duration(days: 1));
      }

      // Прошло полгода, и всё изменилось: теперь работает короткий спринт.
      now = now.add(const Duration(days: 180));
      for (var i = 0; i < 10; i++) {
        await engine.recordOutcome(
          _session(technique: FocusTechnique.sprint15, success: true, at: now),
        );
        await engine.recordOutcome(
          _session(
            technique: FocusTechnique.deepWork90,
            success: false,
            at: now,
          ),
        );
        now = now.add(const Duration(days: 1));
      }

      final counts = await _sample(engine, 200);
      expect(
        counts[FocusTechnique.sprint15] ?? 0,
        greaterThan(counts[FocusTechnique.deepWork90] ?? 0),
        reason: 'the engine must follow the current pattern, not last year’s',
      );
      expect(counts[FocusTechnique.deepWork90] ?? 0, lessThan(40));
    });

    test('evidence reports the narrowest tier that has data', () async {
      final weights = _FakeWeights();
      final now = DateTime(2026, 1, 1);
      final engine = BanditRecommendationEngine(
        weights: weights,
        sessions: _FakeSessions(30),
        random: Random(3),
        clock: () => now,
      );

      for (var i = 0; i < 6; i++) {
        await engine.recordOutcome(
          _session(technique: FocusTechnique.sprint15, success: true, at: now),
        );
      }

      // На точном ключе данные есть — значит, и объяснение должно быть
      // точным, а не «в похожем настроении».
      Recommendation? learned;
      for (var i = 0; i < 60 && learned == null; i++) {
        final rec = await engine.recommend(_context);
        if (rec.technique == FocusTechnique.sprint15 &&
            rec.reason == RecommendationReason.learned) {
          learned = rec;
        }
      }

      expect(learned, isNotNull);
      expect(learned!.evidence.scope, EvidenceScope.exact);
      expect(learned.evidence.matchedSessions, 6);
      expect(learned.evidence.successRate, closeTo(1.0, 0.001));
      expect(learned.evidence.totalSessions, 30);
      expect(learned.evidence.hasData, isTrue);
    });

    test('a broader tier backs the pick when the exact one is empty', () async {
      final weights = _FakeWeights();
      final now = DateTime(2026, 1, 1);
      final engine = BanditRecommendationEngine(
        weights: weights,
        sessions: _FakeSessions(30),
        random: Random(5),
        clock: () => now,
      );

      // Учим на том же настроении, но в другой категории и в другое время.
      const other = RecommendationContext(
        mood: Mood.good,
        category: TaskCategory.study,
        difficulty: TaskDifficulty.easy,
        timeOfDay: TimeOfDayBucket.night,
        weekday: 6,
      );
      for (var i = 0; i < 6; i++) {
        await engine.recordOutcome(
          SessionEntity(
            id: 'other-$i',
            taskTitle: 'task',
            category: other.category,
            difficulty: other.difficulty,
            mood: other.mood,
            technique: FocusTechnique.sprint15,
            plannedFocusMinutes: 15,
            plannedBreakMinutes: 5,
            plannedCycles: 2,
            actualFocusSeconds: 900,
            outcome: SessionOutcome.completed,
            startedAt: now,
            endedAt: now,
            contextKey: other.key,
          ),
        );
      }

      Recommendation? rec;
      for (var i = 0; i < 60 && rec == null; i++) {
        final candidate = await engine.recommend(_context);
        if (candidate.technique == FocusTechnique.sprint15 &&
            candidate.evidence.hasData) {
          rec = candidate;
        }
      }

      expect(rec, isNotNull);
      expect(rec!.evidence.scope, EvidenceScope.broad);
      // Наблюдения приводятся обратно к числу сессий, несмотря на то что
      // на широком уровне они хранятся с весом 0.2.
      expect(rec.evidence.matchedSessions, 6);
    });
  });
}
