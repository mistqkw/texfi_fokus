import '../entities/task_entity.dart';

abstract class TaskRepository {
  /// Задачи в порядке «недавно использованные сверху».
  Stream<List<TaskEntity>> watchTasks();

  Future<List<TaskEntity>> getTasks();

  Future<TaskEntity?> getTaskById(String id);

  Future<void> createTask(TaskEntity task);

  Future<void> updateTask(TaskEntity task);

  Future<void> deleteTask(String id);

  /// Помечает задачу как только что использованную — двигает её наверх.
  Future<void> touchTask(String id, {DateTime? at});
}
