import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/providers/data_providers.dart';
import '../../domain/entities/day_plan_entity.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_entity.dart';
import '../home/home_providers.dart';

const _uuid = Uuid();

/// План на сегодня. Пустой список — нормальное состояние: планировать день
/// никто не обязан.
final todayPlanProvider = StreamProvider<List<DayPlanEntryEntity>>((ref) {
  return ref
      .watch(plannerRepositoryProvider)
      .watchPlanForDay(ref.watch(todayProvider));
});

/// Чеклист задачи. Family по id: экран таймера знает только его.
final subtasksProvider =
    StreamProvider.family<List<SubtaskEntity>, String>((ref, taskId) {
  return ref.watch(plannerRepositoryProvider).watchSubtasks(taskId);
});

/// Добавляет в план существующую задачу либо заводит новую по названию.
///
/// Заводить задачу прямо здесь важнее, чем кажется: план дня составляют
/// утром, когда в списке задач ещё нет ничего сегодняшнего, и отправлять
/// человека сначала «создать задачу» значило бы не дать спланировать день.
final addToPlanProvider = Provider<
    Future<void> Function({
  TaskEntity? task,
  String? title,
  TaskCategory category,
  TaskDifficulty difficulty,
})>((ref) {
  return ({
    TaskEntity? task,
    String? title,
    TaskCategory category = TaskCategory.other,
    TaskDifficulty difficulty = TaskDifficulty.medium,
  }) async {
    final planner = ref.read(plannerRepositoryProvider);
    final today = ref.read(todayProvider);

    if (task != null) {
      await planner.addToPlan(day: today, taskId: task.id);
      return;
    }

    final trimmed = (title ?? '').trim();
    if (trimmed.isEmpty) return;

    final id = _uuid.v4();
    await ref.read(taskRepositoryProvider).createTask(
          TaskEntity(
            id: id,
            title: trimmed,
            category: category,
            difficulty: difficulty,
            createdAt: DateTime.now(),
            lastUsedAt: DateTime.now(),
          ),
        );
    await planner.addToPlan(day: today, taskId: id);
  };
});
