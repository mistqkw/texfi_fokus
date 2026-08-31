import 'focus_technique.dart';
import 'mood.dart';
import 'task_category.dart';

/// Чем закончилась фокус-сессия.
enum SessionOutcome {
  /// Все запланированные циклы фокуса пройдены.
  completed,

  /// Пользователь остановил сессию досрочно.
  aborted;

  static SessionOutcome fromIndex(int index) =>
      index >= 0 && index < SessionOutcome.values.length
          ? SessionOutcome.values[index]
          : SessionOutcome.aborted;
}

/// Запись о проведённой фокус-сессии — основной материал, на котором учится
/// движок рекомендаций.
class SessionEntity {
  const SessionEntity({
    required this.id,
    required this.taskTitle,
    required this.category,
    required this.difficulty,
    required this.mood,
    required this.technique,
    required this.plannedFocusMinutes,
    required this.plannedBreakMinutes,
    required this.plannedCycles,
    required this.actualFocusSeconds,
    required this.outcome,
    required this.startedAt,
    required this.endedAt,
    required this.contextKey,
    this.taskId,
    this.rating,
    this.wasRecommended = true,
  });

  final String id;
  final String? taskId;
  final String taskTitle;
  final TaskCategory category;
  final TaskDifficulty difficulty;
  final Mood mood;
  final FocusTechnique technique;

  final int plannedFocusMinutes;
  final int plannedBreakMinutes;
  final int plannedCycles;

  /// Фактически проведённое в фокусе время. Перерывы сюда не входят.
  final int actualFocusSeconds;

  final SessionOutcome outcome;

  /// Субъективная оценка продуктивности 1–5. null — пользователь пропустил
  /// вопрос; тогда сигналом для обучения остаётся только [outcome].
  final int? rating;

  final DateTime startedAt;
  final DateTime endedAt;

  /// Полный ключ контекста на момент старта — сохраняем, чтобы обучение
  /// не зависело от того, когда именно запись обрабатывают.
  final String contextKey;

  /// Приняли предложенную технику или настроили таймер вручную.
  final bool wasRecommended;

  int get actualFocusMinutes => (actualFocusSeconds / 60).round();

  /// Считается ли сессия успехом для обучения бандита: доведена до конца
  /// либо оценена на 3+ из 5. Прерванная и оценённая на 1–2 — неуспех.
  bool get isSuccess {
    if (rating != null) return rating! >= 3;
    return outcome == SessionOutcome.completed;
  }
}
