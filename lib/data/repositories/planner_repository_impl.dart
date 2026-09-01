import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/day_plan_entity.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/planner_repository.dart';
import '../local/database.dart';
import 'habit_repository_impl.dart' show dayOf;

const _uuid = Uuid();

class PlannerRepositoryImpl implements PlannerRepository {
  PlannerRepositoryImpl(this._db);

  final AppDatabase _db;

  TaskEntity _taskOf(Task row) => TaskEntity(
        id: row.id,
        title: row.title,
        category: TaskCategory.fromIndex(row.category),
        difficulty: TaskDifficulty.fromIndex(row.difficulty),
        createdAt: row.createdAt,
        lastUsedAt: row.lastUsedAt,
        archived: row.archived,
      );

  /// План собирается джойном с задачами: пункт без живой задачи показывать
  /// нечем, и такие строки просто выпадают из выборки.
  JoinedSelectStatement<HasResultSet, dynamic> _planQuery(DateTime day) {
    final target = dayOf(day);
    return (_db.select(_db.dayPlanEntries)
          ..where((t) => t.day.equals(target))
          ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
        .join([
      innerJoin(_db.tasks, _db.tasks.id.equalsExp(_db.dayPlanEntries.taskId)),
    ]);
  }

  List<DayPlanEntryEntity> _mapPlan(List<TypedResult> rows) {
    return [
      for (final row in rows)
        () {
          final entry = row.readTable(_db.dayPlanEntries);
          return DayPlanEntryEntity(
            id: entry.id,
            day: entry.day,
            task: _taskOf(row.readTable(_db.tasks)),
            sortOrder: entry.sortOrder,
            done: entry.done,
          );
        }(),
    ];
  }

  @override
  Stream<List<DayPlanEntryEntity>> watchPlanForDay(DateTime day) =>
      _planQuery(day).watch().map(_mapPlan);

  @override
  Future<List<DayPlanEntryEntity>> planForDay(DateTime day) async =>
      _mapPlan(await _planQuery(day).get());

  @override
  Future<void> addToPlan({
    required DateTime day,
    required String taskId,
  }) async {
    final target = dayOf(day);
    final existing = await (_db.select(_db.dayPlanEntries)
          ..where((t) => t.day.equals(target) & t.taskId.equals(taskId)))
        .getSingleOrNull();
    if (existing != null) return;

    // Новый пункт встаёт в конец: план читают сверху вниз, и вставка в
    // середину без явного жеста пользователя ломала бы его порядок.
    final current = await planForDay(target);
    await _db.into(_db.dayPlanEntries).insert(
          DayPlanEntriesCompanion(
            id: Value(_uuid.v4()),
            day: Value(target),
            taskId: Value(taskId),
            sortOrder: Value(current.length),
            createdAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<void> removeFromPlan(String entryId) async {
    await (_db.delete(_db.dayPlanEntries)..where((t) => t.id.equals(entryId)))
        .go();
  }

  @override
  Future<void> setPlanEntryDone(String entryId, bool done) async {
    await (_db.update(_db.dayPlanEntries)..where((t) => t.id.equals(entryId)))
        .write(DayPlanEntriesCompanion(done: Value(done)));
  }

  @override
  Future<void> reorderPlan(List<String> entryIdsInOrder) async {
    await _db.transaction(() async {
      for (var i = 0; i < entryIdsInOrder.length; i++) {
        await (_db.update(_db.dayPlanEntries)
              ..where((t) => t.id.equals(entryIdsInOrder[i])))
            .write(DayPlanEntriesCompanion(sortOrder: Value(i)));
      }
    });
  }

  SimpleSelectStatement<$SubtasksTable, Subtask> _subtaskQuery(String taskId) {
    return _db.select(_db.subtasks)
      ..where((t) => t.taskId.equals(taskId))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]);
  }

  List<SubtaskEntity> _mapSubtasks(List<Subtask> rows) => [
        for (final row in rows)
          SubtaskEntity(
            id: row.id,
            taskId: row.taskId,
            title: row.title,
            sortOrder: row.sortOrder,
            done: row.done,
          ),
      ];

  @override
  Stream<List<SubtaskEntity>> watchSubtasks(String taskId) =>
      _subtaskQuery(taskId).watch().map(_mapSubtasks);

  @override
  Future<List<SubtaskEntity>> subtasksOf(String taskId) async =>
      _mapSubtasks(await _subtaskQuery(taskId).get());

  @override
  Future<void> addSubtask({
    required String taskId,
    required String title,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final current = await subtasksOf(taskId);
    // Лимит держится здесь, а не только в UI: чеклист на всю страницу
    // внутри одной сессии — это уже другая задача, а не разбивка этой.
    if (current.length >= SubtaskEntity.maxPerTask) return;

    await _db.into(_db.subtasks).insert(
          SubtasksCompanion(
            id: Value(_uuid.v4()),
            taskId: Value(taskId),
            title: Value(trimmed),
            sortOrder: Value(current.length),
          ),
        );
  }

  @override
  Future<void> setSubtaskDone(String subtaskId, bool done) async {
    await (_db.update(_db.subtasks)..where((t) => t.id.equals(subtaskId)))
        .write(SubtasksCompanion(done: Value(done)));
  }

  @override
  Future<void> deleteSubtask(String subtaskId) async {
    await (_db.delete(_db.subtasks)..where((t) => t.id.equals(subtaskId))).go();
  }
}
