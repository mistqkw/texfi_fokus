/// Категория задачи. Индекс хранится в БД и входит в ключ контекста —
/// порядок менять нельзя.
enum TaskCategory {
  study,
  work,
  creative,
  chores,
  sport,
  other;

  static TaskCategory fromIndex(int index) =>
      index >= 0 && index < TaskCategory.values.length
          ? TaskCategory.values[index]
          : TaskCategory.other;
}

/// Субъективная сложность задачи, которую пользователь отмечает перед
/// сессией. Влияет на выбор техники.
enum TaskDifficulty {
  easy,
  medium,
  hard;

  static TaskDifficulty fromIndex(int index) =>
      index >= 0 && index < TaskDifficulty.values.length
          ? TaskDifficulty.values[index]
          : TaskDifficulty.medium;
}
