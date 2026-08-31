import 'package:drift/drift.dart';

/// Задача, под которую запускается фокус-сессия.
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withLength(min: 1, max: 160)();

  /// Индекс `TaskCategory`.
  IntColumn get category => integer().withDefault(const Constant(5))();

  /// Индекс `TaskDifficulty`.
  IntColumn get difficulty => integer().withDefault(const Constant(1))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Последнее использование — по нему список сортируется.
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
