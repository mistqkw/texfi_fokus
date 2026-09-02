import 'package:drift/drift.dart';

/// Singleton-строка прогресса и настроек: игрок в приложении один.
///
/// Константа верхнеуровневая, а не статик внутри `Table`: drift подмешивает
/// статические члены таблицы в сгенерированный класс данных, и там она
/// разъезжается с анализатором.
const int gameSingletonId = 0;

/// Прогресс персонажа. Ровно одна строка — [gameSingletonId].
///
/// Отдельная таблица, а не колонки в настройках: опыт копится от сессий и
/// привычек и должен пережить любое переключение игрового режима.
class PlayerProgress extends Table {
  /// Singleton-строка: игрок в приложении один.
  IntColumn get id => integer().withDefault(const Constant(gameSingletonId))();

  IntColumn get totalXp => integer().withDefault(const Constant(0))();

  /// Счётчики для экрана персонажа. Считать их каждый раз по карте нельзя:
  /// побеждённые дриферы на пройденных узлах перезаписываются, а история
  /// побед должна оставаться.
  IntColumn get drifterKills => integer().withDefault(const Constant(0))();

  IntColumn get bossKills => integer().withDefault(const Constant(0))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Узлы карты: путь из миров, в конце каждого — босс.
///
/// Карта материализуется в БД, а не считается на лету, потому что у каждого
/// узла есть собственное живое состояние: недобитый дрифер помнит свои HP, а
/// босс — сколько попыток осталось у игрока.
class MapNodes extends Table {
  /// `w1n2` — мир и позиция. Строкой: так id читаем в логах и не разъедется
  /// при смене нумерации.
  TextColumn get id => text()();

  /// 1-based номер мира.
  IntColumn get world => integer()();

  /// 1-based позиция внутри мира.
  IntColumn get position => integer()();

  /// `MapNodeKind`: обычный дрифер или босс.
  IntColumn get kind => integer()();

  /// `MapNodeStatus`: locked / current / completed.
  IntColumn get status => integer()();

  /// `DrifterSpecies` — какой именно силуэт здесь стоит.
  IntColumn get species => integer().withDefault(const Constant(0))();

  IntColumn get maxHp => integer()();

  IntColumn get currentHp => integer()();

  /// Запас персонажа на текущем заходе к боссу.
  IntColumn get playerHp => integer().withDefault(const Constant(0))();

  /// Редкая окраска дрифера. Решается один раз — в тот момент, когда узел
  /// становится текущим, — и с тех пор хранится: цвет противника не должен
  /// меняться между запусками приложения.
  ///
  /// Колонка, а не вычисление на лету: детерминированная формула от id узла
  /// дала бы одну и ту же карту всем и превратила бы редкость в расписание.
  BoolColumn get golden => boolean().withDefault(const Constant(false))();

  /// Когда по узлу били в последний раз — от этого зависит, успел ли
  /// недобитый дрифер восстановиться.
  DateTimeColumn get lastFoughtAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Настройки игрового слоя. Тоже singleton-строка.
class GameSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(gameSingletonId))();

  /// Игровой режим включён. По умолчанию выключен: обычный трекер остаётся
  /// поведением по умолчанию, игра — осознанный выбор.
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
