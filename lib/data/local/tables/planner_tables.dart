import 'package:drift/drift.dart';

/// Задача, поставленная в план на конкретный день.
///
/// Отдельная таблица, а не флаг на `Tasks`: план — это событие дня, и
/// вчерашний план должен остаться вчерашним, даже если сама задача жива и
/// переехала на завтра.
class DayPlanEntries extends Table {
  TextColumn get id => text()();

  /// День плана, нормализованный к локальной полуночи.
  DateTimeColumn get day => dateTime()();

  /// Ссылается на `Tasks.id`. Всегда заполнена: в план попадают только
  /// сохранённые задачи — иначе из плана нельзя было бы стартовать сессию
  /// с той же категорией и сложностью.
  TextColumn get taskId => text()();

  /// Порядок в плане — «примерный порядок» из спецификации.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Пользователь отметил пункт плана выполненным.
  BoolColumn get done => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['UNIQUE (day, task_id)'];
}

/// Пункт чеклиста внутри задачи. Показывается на экране активного таймера.
class Subtasks extends Table {
  TextColumn get id => text()();

  /// Ссылается на `Tasks.id`.
  TextColumn get taskId => text()();

  TextColumn get title => text().withLength(min: 1, max: 120)();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  BoolColumn get done => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
