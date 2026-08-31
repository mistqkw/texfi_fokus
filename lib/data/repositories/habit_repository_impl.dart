import 'package:drift/drift.dart';

import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/repositories/habit_repository.dart';
import '../local/database.dart';

/// Нормализует момент времени к локальной полуночи. Все даты привычек
/// хранятся именно так, иначе отметка «сегодня», сделанная в 23:59 и в
/// 00:01, попадала бы в разные дни неочевидным образом.
DateTime dayOf(DateTime moment) =>
    DateTime(moment.year, moment.month, moment.day);

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl(this._db);

  final AppDatabase _db;

  /// Насколько глубоко в прошлое смотрим при подсчёте стрика. Год с запасом:
  /// более длинную серию всё равно незачем показывать точнее.
  static const int _streakLookbackDays = 400;

  HabitEntity _toEntity(Habit row) {
    return HabitEntity(
      id: row.id,
      name: row.name,
      punishment: row.punishment,
      weekdayMask: row.weekdayMask,
      reminderMinutes: row.reminderMinutes,
      createdAt: row.createdAt,
      archived: row.archived,
      sortOrder: row.sortOrder,
    );
  }

  HabitsCompanion _toCompanion(HabitEntity habit) {
    return HabitsCompanion(
      id: Value(habit.id),
      name: Value(habit.name),
      punishment: Value(habit.punishment),
      weekdayMask: Value(habit.weekdayMask),
      reminderMinutes: Value(habit.reminderMinutes),
      archived: Value(habit.archived),
      sortOrder: Value(habit.sortOrder),
      createdAt: Value(habit.createdAt),
    );
  }

  @override
  Stream<List<HabitEntity>> watchHabits() {
    final query = _db.select(_db.habits)
      ..where((t) => t.archived.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.createdAt),
      ]);
    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<List<HabitEntity>> getHabits() async {
    final query = _db.select(_db.habits)
      ..where((t) => t.archived.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.createdAt),
      ]);
    final rows = await query.get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<HabitEntity?> getHabitById(String id) async {
    final row = await (_db.select(_db.habits)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Stream<List<HabitWithStatus>> watchHabitsForDay(DateTime day) {
    // Состояние на день собирается из двух таблиц и требует расчёта стрика,
    // который одним SQL-запросом не выражается. Поэтому подписываемся на
    // «пустой» запрос, объявляя обе таблицы как источники: drift перезапустит
    // его при любом изменении в них, а мы пересоберём срез целиком.
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {_db.habits, _db.habitCompletions},
        )
        .watch()
        .asyncMap((_) => getHabitsForDay(day));
  }

  @override
  Future<List<HabitWithStatus>> getHabitsForDay(DateTime day) async {
    final target = dayOf(day);
    final habits = await getHabits();
    final scheduled =
        habits.where((h) => h.isScheduledOn(target)).toList(growable: false);
    if (scheduled.isEmpty) return const [];

    final from = target.subtract(const Duration(days: _streakLookbackDays));
    final completions = await completionsInRange(from, target);

    // habitId -> набор дней, когда привычка закрыта.
    final byHabit = <String, Set<DateTime>>{};
    for (final c in completions) {
      byHabit.putIfAbsent(c.habitId, () => <DateTime>{}).add(dayOf(c.day));
    }

    return [
      for (final habit in scheduled)
        HabitWithStatus(
          habit: habit,
          doneToday: byHabit[habit.id]?.contains(target) ?? false,
          streak: _streakFor(
            habit: habit,
            done: byHabit[habit.id] ?? const {},
            today: target,
          ),
        ),
    ];
  }

  /// Считает серию подряд закрытых дней, шагая назад от сегодняшнего.
  ///
  /// Сегодняшний день особый: пока он не закончился, невыполненная привычка
  /// ещё не провал — серия просто отсчитывается со вчера, а не обнуляется.
  int _streakFor({
    required HabitEntity habit,
    required Set<DateTime> done,
    required DateTime today,
  }) {
    var streak = 0;
    var cursor = today;

    if (habit.isScheduledOn(cursor) && !done.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final earliest = dayOf(habit.createdAt);
    for (var i = 0; i < _streakLookbackDays; i++) {
      if (cursor.isBefore(earliest)) break;
      if (habit.isScheduledOn(cursor)) {
        if (done.contains(cursor)) {
          streak++;
        } else {
          break;
        }
      }
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Future<void> createHabit(HabitEntity habit) async {
    await _db.into(_db.habits).insert(_toCompanion(habit));
  }

  @override
  Future<void> updateHabit(HabitEntity habit) async {
    await (_db.update(_db.habits)..where((t) => t.id.equals(habit.id)))
        .write(_toCompanion(habit));
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.habitCompletions)
            ..where((t) => t.habitId.equals(id)))
          .go();
      await (_db.delete(_db.habits)..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Future<void> setCompletion({
    required String habitId,
    required DateTime day,
    required bool done,
  }) async {
    final target = dayOf(day);
    if (!done) {
      await (_db.delete(_db.habitCompletions)
            ..where((t) => t.habitId.equals(habitId) & t.day.equals(target)))
          .go();
      return;
    }
    // Пара (привычка, день) уникальна на уровне схемы — повторная отметка
    // не должна падать, поэтому вставка идёт с ignore.
    await _db.into(_db.habitCompletions).insert(
          HabitCompletionsCompanion(
            id: Value('$habitId@${target.toIso8601String()}'),
            habitId: Value(habitId),
            day: Value(target),
            completedAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<List<HabitCompletionEntity>> completionsInRange(
    DateTime from,
    DateTime to,
  ) async {
    final start = dayOf(from);
    final end = dayOf(to);
    final query = _db.select(_db.habitCompletions)
      ..where((t) => t.day.isBiggerOrEqualValue(start) & t.day.isSmallerOrEqualValue(end));
    final rows = await query.get();
    return [
      for (final row in rows)
        HabitCompletionEntity(
          id: row.id,
          habitId: row.habitId,
          day: row.day,
          completedAt: row.completedAt,
        ),
    ];
  }

  @override
  Future<int> overallStreak({DateTime? until}) async {
    final today = dayOf(until ?? DateTime.now());
    final habits = await getHabits();
    if (habits.isEmpty) return 0;

    final from = today.subtract(const Duration(days: _streakLookbackDays));
    final completions = await completionsInRange(from, today);
    final byDay = <DateTime, Set<String>>{};
    for (final c in completions) {
      byDay.putIfAbsent(dayOf(c.day), () => <String>{}).add(c.habitId);
    }

    bool allDoneOn(DateTime date) {
      final due = habits
          .where((h) => h.isScheduledOn(date) && !dayOf(h.createdAt).isAfter(date))
          .toList(growable: false);
      // День без запланированных привычек серию не рвёт, но и не наращивает.
      if (due.isEmpty) return true;
      final done = byDay[date] ?? const <String>{};
      return due.every((h) => done.contains(h.id));
    }

    var cursor = today;
    // Незакрытый сегодняшний день серию не обнуляет — он ещё идёт.
    if (!allDoneOn(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    for (var i = 0; i < _streakLookbackDays; i++) {
      final due = habits.where(
        (h) => h.isScheduledOn(cursor) && !dayOf(h.createdAt).isAfter(cursor),
      );
      if (due.isEmpty) {
        // До создания первой привычки считать нечего.
        if (habits.every((h) => dayOf(h.createdAt).isAfter(cursor))) break;
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      if (!allDoneOn(cursor)) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Future<List<HabitSuccessStat>> successStats(
    DateTime from,
    DateTime to,
  ) async {
    final start = dayOf(from);
    final end = dayOf(to);
    final habits = await getHabits();
    if (habits.isEmpty) return const [];

    final completions = await completionsInRange(start, end);
    final byHabit = <String, Set<DateTime>>{};
    for (final c in completions) {
      byHabit.putIfAbsent(c.habitId, () => <DateTime>{}).add(dayOf(c.day));
    }

    return [
      for (final habit in habits)
        () {
          var scheduled = 0;
          var completed = 0;
          final done = byHabit[habit.id] ?? const <DateTime>{};
          final createdDay = dayOf(habit.createdAt);
          for (var d = start;
              !d.isAfter(end);
              d = d.add(const Duration(days: 1))) {
            if (d.isBefore(createdDay)) continue;
            if (!habit.isScheduledOn(d)) continue;
            scheduled++;
            if (done.contains(d)) completed++;
          }
          return HabitSuccessStat(
            habitId: habit.id,
            habitName: habit.name,
            scheduledDays: scheduled,
            completedDays: completed,
          );
        }(),
    ];
  }
}
