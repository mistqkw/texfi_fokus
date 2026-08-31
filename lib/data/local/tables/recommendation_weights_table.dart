import 'package:drift/drift.dart';

/// Обученные веса движка рекомендаций: по строке на каждую пару
/// (ключ контекста × техника).
///
/// alpha/beta — параметры бета-распределения для Thompson sampling. Обе
/// начинаются с 1.0 (равномерное априорное), успех увеличивает alpha,
/// неуспех — beta.
class RecommendationWeights extends Table {
  /// Ключ контекста: `mood|category|difficulty|timeOfDay|weekday`, либо
  /// один из огрублённых вариантов (`mood|category`, `mood`).
  TextColumn get contextKey => text()();

  /// Строковый ключ `FocusTechnique`.
  TextColumn get techniqueKey => text()();

  RealColumn get alpha => real().withDefault(const Constant(1.0))();
  RealColumn get beta => real().withDefault(const Constant(1.0))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {contextKey, techniqueKey};
}
