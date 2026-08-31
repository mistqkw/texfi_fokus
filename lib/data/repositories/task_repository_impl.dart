import 'package:drift/drift.dart';

import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../local/database.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._db);

  final AppDatabase _db;

  TaskEntity _toEntity(Task row) {
    return TaskEntity(
      id: row.id,
      title: row.title,
      category: TaskCategory.fromIndex(row.category),
      difficulty: TaskDifficulty.fromIndex(row.difficulty),
      createdAt: row.createdAt,
      lastUsedAt: row.lastUsedAt,
      archived: row.archived,
    );
  }

  TasksCompanion _toCompanion(TaskEntity task) {
    return TasksCompanion(
      id: Value(task.id),
      title: Value(task.title),
      category: Value(task.category.index),
      difficulty: Value(task.difficulty.index),
      createdAt: Value(task.createdAt),
      lastUsedAt: Value(task.lastUsedAt),
      archived: Value(task.archived),
    );
  }

  /// Недавно использованные — сверху; задачи, которыми ещё не пользовались,
  /// сортируются по дате создания.
  SimpleSelectStatement<$TasksTable, Task> _ordered() {
    return _db.select(_db.tasks)
      ..where((t) => t.archived.equals(false))
      ..orderBy([
        (t) => OrderingTerm(
              expression: t.lastUsedAt,
              mode: OrderingMode.desc,
            ),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
  }

  @override
  Stream<List<TaskEntity>> watchTasks() =>
      _ordered().watch().map((rows) => rows.map(_toEntity).toList());

  @override
  Future<List<TaskEntity>> getTasks() async =>
      (await _ordered().get()).map(_toEntity).toList();

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final row = await (_db.select(_db.tasks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    await _db.into(_db.tasks).insert(_toCompanion(task));
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(task.id)))
        .write(_toCompanion(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> touchTask(String id, {DateTime? at}) async {
    await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(lastUsedAt: Value(at ?? DateTime.now())),
    );
  }
}
