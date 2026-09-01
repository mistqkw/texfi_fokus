import 'mood.dart';
import 'session_entity.dart';
import 'task_category.dart';

/// Сколько времени в фокусе пришлось на конкретный день. Основа и для
/// heatmap-а, и для столбчатого графика.
class DailyFocus {
  const DailyFocus({
    required this.day,
    required this.focusSeconds,
    required this.sessionCount,
  });

  final DateTime day;
  final int focusSeconds;
  final int sessionCount;

  int get focusMinutes => (focusSeconds / 60).round();
}

/// Как настроение на старте связано с результатом сессии.
class MoodOutcomeStat {
  const MoodOutcomeStat({
    required this.mood,
    required this.total,
    required this.completed,
    required this.focusSeconds,
  });

  final Mood mood;
  final int total;
  final int completed;
  final int focusSeconds;

  /// Доля доведённых до конца сессий 0..1.
  double get completionRate => total == 0 ? 0 : completed / total;
}

/// Разбивка времени в фокусе по категориям задач.
class CategoryFocusStat {
  const CategoryFocusStat({
    required this.category,
    required this.focusSeconds,
    required this.sessionCount,
  });

  final TaskCategory category;
  final int focusSeconds;
  final int sessionCount;

  int get focusMinutes => (focusSeconds / 60).round();
}

/// Успешность одной привычки за период.
class HabitSuccessStat {
  const HabitSuccessStat({
    required this.habitId,
    required this.habitName,
    required this.scheduledDays,
    required this.completedDays,
  });

  final String habitId;
  final String habitName;
  final int scheduledDays;
  final int completedDays;

  double get rate => scheduledDays == 0 ? 0 : completedDays / scheduledDays;
}

/// Сводка по фокус-сессиям за период — шапка экрана статистики.
class FocusSummary {
  const FocusSummary({
    required this.totalFocusSeconds,
    required this.sessionCount,
    required this.completedCount,
  });

  static const FocusSummary empty =
      FocusSummary(totalFocusSeconds: 0, sessionCount: 0, completedCount: 0);

  final int totalFocusSeconds;
  final int sessionCount;
  final int completedCount;

  int get totalFocusMinutes => (totalFocusSeconds / 60).round();

  double get completionRate =>
      sessionCount == 0 ? 0 : completedCount / sessionCount;
}

/// Сколько раз за период «наказание» по привычке реально сработало.
///
/// Сработало — значит день был запланирован, не закрыт и не заморожен.
/// Сегодняшний день сюда не входит: он ещё не проигран.
class HabitPunishmentStat {
  const HabitPunishmentStat({
    required this.habitId,
    required this.habitName,
    required this.punishment,
    required this.missedDays,
    required this.scheduledDays,
    required this.frozenDays,
  });

  final String habitId;
  final String habitName;
  final String punishment;

  /// Дни, когда наказание сработало.
  final int missedDays;

  /// Сколько дней вообще было запланировано — без него «пропущено 3»
  /// не отличить от катастрофы и от мелочи.
  final int scheduledDays;

  /// Сколько раз пропуск был осознанным, через заморозку.
  final int frozenDays;

  double get missRate => scheduledDays == 0 ? 0 : missedDays / scheduledDays;
}

/// Разбивка прерванных сессий по названным причинам.
class InterruptionReasonStat {
  const InterruptionReasonStat({
    required this.reason,
    required this.count,
  });

  /// null — причину не назвали.
  final InterruptionReason? reason;
  final int count;
}
