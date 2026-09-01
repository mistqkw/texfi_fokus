import 'package:drift/drift.dart';

/// Привычка: дневная цель и назначенное себе «наказание» за пропуск.
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();

  /// Текст, который пользователь вписал сам. Приложение его только хранит
  /// и показывает в напоминании — никакой автоматизации.
  TextColumn get punishment => text().withLength(min: 1, max: 300)();

  /// Индекс `HabitFrequencyType`: 0 — по дням недели, 1 — N раз в неделю.
  IntColumn get frequencyType => integer().withDefault(const Constant(0))();

  /// Битовая маска дней недели, бит 0 — понедельник. 0x7F — каждый день.
  /// Осмысленна только при `frequencyType == 0`.
  IntColumn get weekdayMask => integer().withDefault(const Constant(0x7F))();

  /// Сколько раз в неделю нужно закрыть привычку без привязки к дням.
  /// Осмысленно только при `frequencyType == 1`.
  IntColumn get timesPerWeek => integer().withDefault(const Constant(3))();

  /// Награда, которую пользователь назначил себе сам за стрик. null —
  /// не задана; приложение её не автоматизирует, только показывает.
  TextColumn get reward => text().nullable()();

  /// За сколько дней подряд полагается [reward].
  IntColumn get rewardStreakDays => integer().withDefault(const Constant(7))();

  /// Как часто можно «заморозить» день, не теряя стрик. 0 — заморозки
  /// выключены для этой привычки.
  IntColumn get freezeIntervalDays =>
      integer().withDefault(const Constant(7))();

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

/// «Заморозка» дня: пропуск, который не рвёт стрик. Отдельная таблица, а не
/// флаг в отметке выполнения: заморозка — это не выполнение, и смешивать их
/// в одной строке значило бы врать статистике.
class HabitFreezes extends Table {
  TextColumn get id => text()();

  /// Ссылается на `Habits.id`.
  TextColumn get habitId => text()();

  /// День, нормализованный к локальной полуночи.
  DateTimeColumn get day => dateTime()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['UNIQUE (habit_id, day)'];
}
