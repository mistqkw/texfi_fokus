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

/// Понедельник недели, в которую попадает [moment]. Неделя начинается с
/// понедельника везде в приложении — и в статистике, и в норме «N раз в
/// неделю», иначе одна и та же привычка считалась бы по-разному.
DateTime weekStartOf(DateTime moment) {
  final day = dayOf(moment);
  return day.subtract(Duration(days: day.weekday - 1));
}

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
      frequency: HabitFrequencyType.fromIndex(row.frequencyType),
      weekdayMask: row.weekdayMask,
      timesPerWeek: row.timesPerWeek,
      reward: row.reward,
      rewardStreakDays: row.rewardStreakDays,
      freezeIntervalDays: row.freezeIntervalDays,
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
      frequencyType: Value(habit.frequency.index),
      weekdayMask: Value(habit.weekdayMask),
      timesPerWeek: Value(habit.timesPerWeek),
      reward: Value(habit.reward),
      rewardStreakDays: Value(habit.rewardStreakDays),
      freezeIntervalDays: Value(habit.freezeIntervalDays),
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
          readsFrom: {_db.habits, _db.habitCompletions, _db.habitFreezes},
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
    final freezes = await freezesInRange(from, target);

    // habitId -> набор дней, когда привычка закрыта / заморожена.
    final doneByHabit = <String, Set<DateTime>>{};
    for (final c in completions) {
      doneByHabit.putIfAbsent(c.habitId, () => <DateTime>{}).add(dayOf(c.day));
    }
    final frozenByHabit = <String, Set<DateTime>>{};
    for (final f in freezes) {
      frozenByHabit.putIfAbsent(f.habitId, () => <DateTime>{}).add(dayOf(f.day));
    }

    final weekStart = weekStartOf(target);

    return [
      for (final habit in scheduled)
        () {
          final done = doneByHabit[habit.id] ?? const <DateTime>{};
          final frozen = frozenByHabit[habit.id] ?? const <DateTime>{};
          final lastFreeze = _lastFreezeBefore(frozen, target);
          final nextFreeze = _nextFreezeDay(habit, lastFreeze);

          return HabitWithStatus(
            habit: habit,
            doneToday: done.contains(target),
            frozenToday: frozen.contains(target),
            freezeAvailable: habit.freezeEnabled &&
                (nextFreeze == null || !nextFreeze.isAfter(target)),
            nextFreezeOn:
                nextFreeze != null && nextFreeze.isAfter(target)
                    ? nextFreeze
                    : null,
            doneThisWeek: done
                .where((d) => !d.isBefore(weekStart) && !d.isAfter(target))
                .length,
            streak: _streakFor(
              habit: habit,
              done: done,
              frozen: frozen,
              today: target,
            ),
          );
        }(),
    ];
  }

  /// Самая свежая заморозка не позже [until].
  DateTime? _lastFreezeBefore(Set<DateTime> frozen, DateTime until) {
    DateTime? latest;
    for (final day in frozen) {
      if (day.isAfter(until)) continue;
      if (latest == null || day.isAfter(latest)) latest = day;
    }
    return latest;
  }

  /// Когда заморозка снова станет доступна. null — доступна уже сейчас.
  DateTime? _nextFreezeDay(HabitEntity habit, DateTime? lastFreeze) {
    if (!habit.freezeEnabled || lastFreeze == null) return null;
    return lastFreeze.add(Duration(days: habit.freezeIntervalDays));
  }

  /// Считает серию, шагая назад от сегодняшнего дня.
  ///
  /// Сегодняшний день особый: пока он не закончился, невыполненная привычка
  /// ещё не провал — серия просто отсчитывается со вчера, а не обнуляется.
  ///
  /// Замороженный день нейтрален: он не рвёт серию, но и не наращивает её.
  /// Иначе заморозка стала бы способом накрутить стрик, ничего не делая.
  int _streakFor({
    required HabitEntity habit,
    required Set<DateTime> done,
    required Set<DateTime> frozen,
    required DateTime today,
  }) {
    if (habit.frequency == HabitFrequencyType.timesPerWeek) {
      return _weeklyStreakFor(
        habit: habit,
        done: done,
        frozen: frozen,
        today: today,
      );
    }

    var streak = 0;
    var cursor = today;

    if (habit.isScheduledOn(cursor) &&
        !done.contains(cursor) &&
        !frozen.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final earliest = dayOf(habit.createdAt);
    for (var i = 0; i < _streakLookbackDays; i++) {
      if (cursor.isBefore(earliest)) break;
      if (habit.isScheduledOn(cursor)) {
        if (done.contains(cursor)) {
          streak++;
        } else if (!frozen.contains(cursor)) {
          break;
        }
      }
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Серия для «N раз в неделю» — это недели, а не дни: у привычки без
  /// привязки к дням «вчера» ничего не значит, значение имеет только
  /// закрытая недельная норма.
  ///
  /// Текущая неделя считается, только если норма в ней уже закрыта: неделя
  /// ещё идёт, и обнулять серию посреди среды не за что.
  int _weeklyStreakFor({
    required HabitEntity habit,
    required Set<DateTime> done,
    required Set<DateTime> frozen,
    required DateTime today,
  }) {
    final target = habit.timesPerWeek;
    if (target <= 0) return 0;

    final createdWeek = weekStartOf(habit.createdAt);
    var week = weekStartOf(today);
    var streak = 0;

    for (var i = 0; i < _streakLookbackDays ~/ 7; i++) {
      if (week.isBefore(createdWeek)) break;
      final weekEnd = week.add(const Duration(days: 6));
      final counted = done
              .where((d) => !d.isBefore(week) && !d.isAfter(weekEnd))
              .length +
          // Заморозка закрывает одну «клетку» недельной нормы: смысл у неё
          // тот же, что у пропущенного дня в дневной привычке.
          frozen.where((d) => !d.isBefore(week) && !d.isAfter(weekEnd)).length;

      if (counted >= target) {
        streak++;
      } else if (week == weekStartOf(today)) {
        // Незакрытая текущая неделя серию не рвёт — она ещё не кончилась.
      } else {
        break;
      }
      week = week.subtract(const Duration(days: 7));
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
      await (_db.delete(_db.habitFreezes)..where((t) => t.habitId.equals(id)))
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
    final freezes = await freezesInRange(from, today);
    final byDay = <DateTime, Set<String>>{};
    for (final c in completions) {
      byDay.putIfAbsent(dayOf(c.day), () => <String>{}).add(c.habitId);
    }
    final frozenByDay = <DateTime, Set<String>>{};
    for (final f in freezes) {
      frozenByDay.putIfAbsent(dayOf(f.day), () => <String>{}).add(f.habitId);
    }

    /// Сколько раз привычка закрыта (или заморожена) на неделе, в которую
    /// попадает [date], не заглядывая в будущее относительно самого [date].
    int countedInWeek(HabitEntity habit, DateTime date) {
      final start = weekStartOf(date);
      var count = 0;
      for (var d = start; !d.isAfter(date); d = d.add(const Duration(days: 1))) {
        if ((byDay[d] ?? const <String>{}).contains(habit.id) ||
            (frozenByDay[d] ?? const <String>{}).contains(habit.id)) {
          count++;
        }
      }
      return count;
    }

    bool allDoneOn(DateTime date) {
      final due = habits
          .where((h) => h.isScheduledOn(date) && !dayOf(h.createdAt).isAfter(date))
          .toList(growable: false);
      // День без запланированных привычек серию не рвёт, но и не наращивает.
      if (due.isEmpty) return true;
      final done = byDay[date] ?? const <String>{};
      final frozen = frozenByDay[date] ?? const <String>{};
      return due.every((h) {
        if (done.contains(h.id) || frozen.contains(h.id)) return true;
        // «N раз в неделю» не требует конкретного дня: если норма недели уже
        // закрыта, сегодняшний пропуск ничего не нарушает.
        return h.frequency == HabitFrequencyType.timesPerWeek &&
            countedInWeek(h, date) >= h.timesPerWeek;
      });
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

  @override
  Future<List<HabitFreezeEntity>> freezesInRange(
    DateTime from,
    DateTime to,
  ) async {
    final start = dayOf(from);
    final end = dayOf(to);
    final query = _db.select(_db.habitFreezes)
      ..where((t) =>
          t.day.isBiggerOrEqualValue(start) & t.day.isSmallerOrEqualValue(end));
    final rows = await query.get();
    return [
      for (final row in rows)
        HabitFreezeEntity(
          id: row.id,
          habitId: row.habitId,
          day: row.day,
          createdAt: row.createdAt,
        ),
    ];
  }

  @override
  Future<bool> setFreeze({
    required String habitId,
    required DateTime day,
    required bool frozen,
  }) async {
    final target = dayOf(day);

    if (!frozen) {
      // Снять свою же заморозку можно всегда: лимит защищает от накрутки
      // стрика, а не от передумавшего пользователя.
      final removed = await (_db.delete(_db.habitFreezes)
            ..where((t) => t.habitId.equals(habitId) & t.day.equals(target)))
          .go();
      return removed > 0;
    }

    final habit = await getHabitById(habitId);
    if (habit == null || !habit.freezeEnabled) return false;

    // Лимит по частоте: заморозка не чаще, чем раз в freezeIntervalDays.
    // Считаем от последней заморозки, а не от начала недели — иначе
    // воскресенье и понедельник давали бы две подряд.
    final windowStart =
        target.subtract(Duration(days: habit.freezeIntervalDays - 1));
    final recent = await freezesInRange(windowStart, target);
    final used = recent.where((f) => f.habitId == habitId);
    if (used.isNotEmpty) return false;

    await _db.into(_db.habitFreezes).insert(
          HabitFreezesCompanion(
            id: Value('$habitId@${target.toIso8601String()}'),
            habitId: Value(habitId),
            day: Value(target),
            createdAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrReplace,
        );
    return true;
  }

  @override
  Future<List<HabitPunishmentStat>> punishmentStats(
    DateTime from,
    DateTime to,
  ) async {
    final start = dayOf(from);
    // Сегодняшний день не считаем провалом: он ещё идёт, и наказание по нему
    // ещё не сработало.
    final today = dayOf(DateTime.now());
    final end = dayOf(to).isBefore(today)
        ? dayOf(to)
        : today.subtract(const Duration(days: 1));
    final habits = await getHabits();
    if (habits.isEmpty || end.isBefore(start)) return const [];

    final completions = await completionsInRange(start, end);
    final freezes = await freezesInRange(start, end);

    final doneByHabit = <String, Set<DateTime>>{};
    for (final c in completions) {
      doneByHabit.putIfAbsent(c.habitId, () => <DateTime>{}).add(dayOf(c.day));
    }
    final frozenByHabit = <String, Set<DateTime>>{};
    for (final f in freezes) {
      frozenByHabit.putIfAbsent(f.habitId, () => <DateTime>{}).add(dayOf(f.day));
    }

    final stats = <HabitPunishmentStat>[];
    for (final habit in habits) {
      final done = doneByHabit[habit.id] ?? const <DateTime>{};
      final frozen = frozenByHabit[habit.id] ?? const <DateTime>{};
      final createdDay = dayOf(habit.createdAt);

      var scheduled = 0;
      var missed = 0;
      var frozenDays = 0;

      if (habit.frequency == HabitFrequencyType.timesPerWeek) {
        // Для недельной нормы «день не выполнен» бессмысленно: провалом
        // считается незакрытая неделя, и каждая недобранная клетка нормы —
        // одно срабатывание наказания.
        for (var week = weekStartOf(start);
            !week.isAfter(end);
            week = week.add(const Duration(days: 7))) {
          final weekEnd = week.add(const Duration(days: 6));
          // Неполную последнюю неделю не судим: она ещё может закрыться.
          if (weekEnd.isAfter(end)) break;
          if (weekEnd.isBefore(createdDay)) continue;

          scheduled += habit.timesPerWeek;
          final closed = done
                  .where((d) => !d.isBefore(week) && !d.isAfter(weekEnd))
                  .length +
              frozen
                  .where((d) => !d.isBefore(week) && !d.isAfter(weekEnd))
                  .length;
          frozenDays += frozen
              .where((d) => !d.isBefore(week) && !d.isAfter(weekEnd))
              .length;
          missed += (habit.timesPerWeek - closed).clamp(0, habit.timesPerWeek);
        }
      } else {
        for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
          if (d.isBefore(createdDay)) continue;
          if (!habit.isScheduledOn(d)) continue;
          scheduled++;
          if (frozen.contains(d)) {
            frozenDays++;
            continue;
          }
          if (!done.contains(d)) missed++;
        }
      }

      if (scheduled == 0) continue;
      stats.add(HabitPunishmentStat(
        habitId: habit.id,
        habitName: habit.name,
        punishment: habit.punishment,
        missedDays: missed,
        scheduledDays: scheduled,
        frozenDays: frozenDays,
      ));
    }

    // Самые «дорогие» привычки сверху: список читают, чтобы увидеть, где
    // договорённость с собой не работает.
    stats.sort((a, b) => b.missedDays.compareTo(a.missedDays));
    return stats;
  }
}
