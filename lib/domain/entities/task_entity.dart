import 'task_category.dart';

/// Задача, под которую запускается фокус-сессия. Может быть введена прямо
/// на mood check-in и переиспользована в следующий раз.
class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.createdAt,
    this.lastUsedAt,
    this.archived = false,
  });

  final String id;
  final String title;
  final TaskCategory category;
  final TaskDifficulty difficulty;
  final DateTime createdAt;

  /// Когда задача последний раз выбиралась — по этому полю список
  /// сортируется, чтобы частое было сверху.
  final DateTime? lastUsedAt;

  final bool archived;

  TaskEntity copyWith({
    String? title,
    TaskCategory? category,
    TaskDifficulty? difficulty,
    DateTime? lastUsedAt,
    bool? archived,
  }) {
    return TaskEntity(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      archived: archived ?? this.archived,
    );
  }
}
