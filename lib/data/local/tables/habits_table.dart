import 'package:drift/drift.dart';

/// Привычка: дневная цель и назначенное себе «наказание» за пропуск.
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();

  /// Текст, который пользователь вписал сам. Приложение его только хранит
  /// и показывает в напоминании — никакой автоматизации.
  TextColumn get punishment => text().withLength(min: 1, max: 300)();

  /// Битовая маска дней недели, бит 0 — понедельник. 0x7F — каждый день.
  IntColumn get weekdayMask => integer().withDefault(const Constant(0x7F))();

  /// Минуты от полуночи для персонального напоминания; null — выключено.
  IntColumn get reminderMinutes => integer().nullable()();

  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Отметка «привычка выполнена в этот день». Одна строка на пару
/// (привычка, день) — уникальность держит индекс ниже.
class HabitCompletions extends Table {
  TextColumn get id => text()();

  /// Ссылается на `Habits.id` (без декларативного FK — как в texfi-money,
  /// целостность держат репозитории).
  TextColumn get habitId => text()();

  /// День, нормализованный к локальной полуночи.
  DateTimeColumn get day => dateTime()();

  DateTimeColumn get completedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['UNIQUE (habit_id, day)'];
}
