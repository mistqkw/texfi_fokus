import 'package:drift/drift.dart';

/// Проведённая фокус-сессия. Основной материал для статистики и для
/// обучения движка рекомендаций.
class Sessions extends Table {
  TextColumn get id => text()();

  /// Ссылается на `Tasks.id`; null — задачу ввели разово и не сохранили.
  TextColumn get taskId => text().nullable()();

  /// Название задачи копируется в сессию: удаление задачи не должно стирать
  /// историю.
  TextColumn get taskTitle => text()();

  /// Индекс `TaskCategory`.
  IntColumn get category => integer()();

  /// Индекс `TaskDifficulty`.
  IntColumn get difficulty => integer()();

  /// Индекс `Mood`.
  IntColumn get mood => integer()();

  /// Строковый ключ `FocusTechnique`.
  TextColumn get technique => text()();

  IntColumn get plannedFocusMinutes => integer()();
  IntColumn get plannedBreakMinutes => integer()();
  IntColumn get plannedCycles => integer()();

  /// Фактическое время в фокусе, без перерывов.
  IntColumn get actualFocusSeconds => integer()();

  /// Индекс `SessionOutcome`.
  IntColumn get outcome => integer()();

  /// Субъективная оценка 1–5; null — пользователь пропустил вопрос.
  IntColumn get rating => integer().nullable()();

  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();

  /// Полный ключ контекста на момент старта.
  TextColumn get contextKey => text()();

  BoolColumn get wasRecommended =>
      boolean().withDefault(const Constant(true))();

  /// Пользователь открыл «настроить вручную» и выбрал технику, отличную от
  /// предложенной. Это не то же самое, что [wasRecommended]: там про «сессия
  /// шла не по совету», здесь — про явное несогласие с советом.
  BoolColumn get wasManualOverride =>
      boolean().withDefault(const Constant(false))();

  /// Ключ `InterruptionReason`; null — сессия не прервана либо причину
  /// не назвали.
  TextColumn get interruptionReason => text().nullable()();

  /// Короткая заметка «как прошло». null — пропустили.
  TextColumn get sessionNote => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
