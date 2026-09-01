import '../entities/day_plan_entity.dart';

/// План на день и чеклисты внутри задач. Отдельный репозиторий, а не
/// довесок к задачам: у плана своя единица жизни — день, — и смешивать её
/// с вечным списком задач значило бы путать «что я делаю вообще» и «что я
/// собирался сделать сегодня».
abstract class PlannerRepository {
  Stream<List<DayPlanEntryEntity>> watchPlanForDay(DateTime day);

  Future<List<DayPlanEntryEntity>> planForDay(DateTime day);

  /// Добавляет задачу в план дня. Повторное добавление той же задачи
  /// ничего не меняет — пара (день, задача) уникальна.
  Future<void> addToPlan({required DateTime day, required String taskId});

  Future<void> removeFromPlan(String entryId);

  Future<void> setPlanEntryDone(String entryId, bool done);

  /// Переставляет пункты плана в порядке переданных id.
  Future<void> reorderPlan(List<String> entryIdsInOrder);

  Stream<List<SubtaskEntity>> watchSubtasks(String taskId);

  Future<List<SubtaskEntity>> subtasksOf(String taskId);

  Future<void> addSubtask({required String taskId, required String title});

  Future<void> setSubtaskDone(String subtaskId, bool done);

  Future<void> deleteSubtask(String subtaskId);
}
