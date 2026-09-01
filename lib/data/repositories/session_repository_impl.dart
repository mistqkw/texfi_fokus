import 'package:drift/drift.dart';

import '../../domain/entities/focus_technique.dart';
import '../../domain/entities/mood.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/repositories/session_repository.dart';
import '../local/database.dart';
import 'habit_repository_impl.dart' show dayOf;

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._db);

  final AppDatabase _db;

  SessionEntity _toEntity(Session row) {
    return SessionEntity(
      id: row.id,
      taskId: row.taskId,
      taskTitle: row.taskTitle,
      category: TaskCategory.fromIndex(row.category),
      difficulty: TaskDifficulty.fromIndex(row.difficulty),
      mood: Mood.fromIndex(row.mood),
      technique: FocusTechnique.fromKey(row.technique),
      plannedFocusMinutes: row.plannedFocusMinutes,
      plannedBreakMinutes: row.plannedBreakMinutes,
      plannedCycles: row.plannedCycles,
      actualFocusSeconds: row.actualFocusSeconds,
      outcome: SessionOutcome.fromIndex(row.outcome),
      rating: row.rating,
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      contextKey: row.contextKey,
      wasRecommended: row.wasRecommended,
      wasManualOverride: row.wasManualOverride,
      interruptionReason:
          InterruptionReason.fromKey(row.interruptionReason),
      sessionNote: row.sessionNote,
    );
  }

  @override
  Future<void> addSession(SessionEntity session) async {
    await _db.into(_db.sessions).insert(
          SessionsCompanion(
            id: Value(session.id),
            taskId: Value(session.taskId),
            taskTitle: Value(session.taskTitle),
            category: Value(session.category.index),
            difficulty: Value(session.difficulty.index),
            mood: Value(session.mood.index),
            technique: Value(session.technique.key),
            plannedFocusMinutes: Value(session.plannedFocusMinutes),
            plannedBreakMinutes: Value(session.plannedBreakMinutes),
            plannedCycles: Value(session.plannedCycles),
            actualFocusSeconds: Value(session.actualFocusSeconds),
            outcome: Value(session.outcome.index),
            rating: Value(session.rating),
            startedAt: Value(session.startedAt),
            endedAt: Value(session.endedAt),
            contextKey: Value(session.contextKey),
            wasRecommended: Value(session.wasRecommended),
            wasManualOverride: Value(session.wasManualOverride),
            interruptionReason: Value(session.interruptionReason?.key),
            sessionNote: Value(session.sessionNote),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Stream<List<SessionEntity>> watchRecentSessions({int limit = 20}) {
    final query = _db.select(_db.sessions)
      ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc)])
      ..limit(limit);
    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  /// Диапазон всегда берём по целым дням: `to` включается целиком, иначе
  /// «за неделю» молча теряло бы сегодняшние сессии после полуночи запроса.
  SimpleSelectStatement<$SessionsTable, Session> _inRange(
    DateTime from,
    DateTime to,
  ) {
    final start = dayOf(from);
    final end = dayOf(to).add(const Duration(days: 1));
    return _db.select(_db.sessions)
      ..where((t) =>
          t.startedAt.isBiggerOrEqualValue(start) &
          t.startedAt.isSmallerThanValue(end))
      ..orderBy([(t) => OrderingTerm(expression: t.startedAt)]);
  }

  @override
  Future<List<SessionEntity>> sessionsInRange(DateTime from, DateTime to) async {
    final rows = await _inRange(from, to).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<int> totalSessionCount() async {
    final count = _db.sessions.id.count();
    final row = await (_db.selectOnly(_db.sessions)..addColumns([count]))
        .getSingle();
    return row.read(count) ?? 0;
  }

  @override
  Stream<int> watchFocusSecondsForDay(DateTime day) =>
      watchFocusSecondsInRange(day, day);

  @override
  Stream<int> watchFocusSecondsInRange(DateTime from, DateTime to) {
    return _inRange(from, to).watch().map(
          (rows) => rows.fold<int>(0, (sum, r) => sum + r.actualFocusSeconds),
        );
  }

  @override
  Stream<FocusSummary> watchSummary(DateTime from, DateTime to) {
    return _inRange(from, to).watch().map((rows) {
      if (rows.isEmpty) return FocusSummary.empty;
      return FocusSummary(
        totalFocusSeconds:
            rows.fold<int>(0, (sum, r) => sum + r.actualFocusSeconds),
        sessionCount: rows.length,
        completedCount: rows
            .where((r) =>
                SessionOutcome.fromIndex(r.outcome) == SessionOutcome.completed)
            .length,
      );
    });
  }

  @override
  Stream<List<DailyFocus>> watchDailyFocus(DateTime from, DateTime to) {
    return _inRange(from, to).watch().map((rows) {
      final seconds = <DateTime, int>{};
      final counts = <DateTime, int>{};
      for (final row in rows) {
        final day = dayOf(row.startedAt);
        seconds[day] = (seconds[day] ?? 0) + row.actualFocusSeconds;
        counts[day] = (counts[day] ?? 0) + 1;
      }
      // Дни без сессий тоже попадают в результат нулями: heatmap рисует
      // сплошную сетку, а пропуски в ней означали бы сдвиг календаря.
      final result = <DailyFocus>[];
      for (var d = dayOf(from); !d.isAfter(dayOf(to)); d = d.add(const Duration(days: 1))) {
        result.add(DailyFocus(
          day: d,
          focusSeconds: seconds[d] ?? 0,
          sessionCount: counts[d] ?? 0,
        ));
      }
      return result;
    });
  }

  @override
  Stream<List<MoodOutcomeStat>> watchMoodStats(DateTime from, DateTime to) {
    return _inRange(from, to).watch().map((rows) {
      return [
        for (final mood in Mood.values)
          () {
            final forMood = rows.where((r) => r.mood == mood.index);
            return MoodOutcomeStat(
              mood: mood,
              total: forMood.length,
              completed: forMood
                  .where((r) =>
                      SessionOutcome.fromIndex(r.outcome) ==
                      SessionOutcome.completed)
                  .length,
              focusSeconds:
                  forMood.fold<int>(0, (sum, r) => sum + r.actualFocusSeconds),
            );
          }(),
      ];
    });
  }

  @override
  Stream<List<CategoryFocusStat>> watchCategoryStats(
    DateTime from,
    DateTime to,
  ) {
    return _inRange(from, to).watch().map((rows) {
      final stats = <CategoryFocusStat>[];
      for (final category in TaskCategory.values) {
        final forCategory = rows.where((r) => r.category == category.index);
        if (forCategory.isEmpty) continue;
        stats.add(CategoryFocusStat(
          category: category,
          focusSeconds:
              forCategory.fold<int>(0, (sum, r) => sum + r.actualFocusSeconds),
          sessionCount: forCategory.length,
        ));
      }
      stats.sort((a, b) => b.focusSeconds.compareTo(a.focusSeconds));
      return stats;
    });
  }

  @override
  Stream<List<InterruptionReasonStat>> watchInterruptionStats(
    DateTime from,
    DateTime to,
  ) {
    return _inRange(from, to).watch().map((rows) {
      final aborted = rows.where(
        (r) => SessionOutcome.fromIndex(r.outcome) == SessionOutcome.aborted,
      );
      final counts = <InterruptionReason?, int>{};
      for (final row in aborted) {
        final reason = InterruptionReason.fromKey(row.interruptionReason);
        counts[reason] = (counts[reason] ?? 0) + 1;
      }

      // Порядок фиксированный, по перечислению: иначе блок статистики
      // перетасовывался бы при каждом обновлении данных.
      final stats = [
        for (final reason in InterruptionReason.values)
          if ((counts[reason] ?? 0) > 0)
            InterruptionReasonStat(reason: reason, count: counts[reason]!),
      ];
      // «Не сказал» — в конце: это отсутствие ответа, а не ответ.
      final unnamed = counts[null] ?? 0;
      if (unnamed > 0) {
        stats.add(InterruptionReasonStat(reason: null, count: unnamed));
      }
      return stats;
    });
  }
}
