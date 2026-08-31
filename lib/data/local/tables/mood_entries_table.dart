import 'package:drift/drift.dart';

/// Отметка настроения на check-in. Пишется даже тогда, когда сессию так и
/// не запустили — «открыл и передумал» тоже данные.
class MoodEntries extends Table {
  TextColumn get id => text()();

  /// Индекс `Mood`.
  IntColumn get mood => integer()();

  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  /// Ссылается на `Sessions.id`; null — сессия не состоялась.
  TextColumn get sessionId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
