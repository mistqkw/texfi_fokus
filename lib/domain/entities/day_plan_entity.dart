import 'task_entity.dart';

/// Пункт плана на день — задача плюс её место в очереди.
///
/// План необязателен и ни к чему не обязывает: его смысл в том, чтобы на
/// mood check-in не выбирать задачу с нуля, а взять из уже обдуманного
/// утром списка. Приложение не проверяет, выполнен ли план, и не ругается
/// за невыполненный.
class DayPlanEntryEntity {
  const DayPlanEntryEntity({
    required this.id,
    required this.day,
    required this.task,
    required this.sortOrder,
    this.done = false,
  });

  final String id;

  /// День, нормализованный к локальной полуночи.
  final DateTime day;

  final TaskEntity task;
  final int sortOrder;
  final bool done;
}

/// Пункт чеклиста внутри задачи.
class SubtaskEntity {
  const SubtaskEntity({
    required this.id,
    required this.taskId,
    required this.title,
    required this.sortOrder,
    this.done = false,
  });

  final String id;
  final String taskId;
  final String title;
  final int sortOrder;
  final bool done;

  /// Сколько пунктов имеет смысл держать в чеклисте одной сессии.
  ///
  /// Верхняя граница не техническая: чеклист на десять пунктов внутри
  /// 25-минутной сессии — это уже вторая задача, а не разбивка первой.
  static const int maxPerTask = 5;
}
