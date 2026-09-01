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

/// Почему сессия оборвалась. Список намеренно короткий: длинный опросник
/// после неудачной сессии — это ещё одна причина её не открывать.
enum InterruptionReason {
  /// Отвлёкся на что-то постороннее.
  distracted,

  /// Задача оказалась не той, что нужно было делать.
  wrongTask,

  /// Устал, кончились силы.
  tired,

  /// Пользователь явно отказался объяснять. Это тоже ответ, и он честнее,
  /// чем случайно выбранный из списка.
  noComment;

  String get key => name;

  static InterruptionReason? fromKey(String? key) {
    if (key == null) return null;
    for (final reason in InterruptionReason.values) {
      if (reason.name == key) return reason;
    }
    return null;
  }
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
    this.wasManualOverride = false,
    this.interruptionReason,
    this.sessionNote,
    this.photoPath,
    this.customTechniqueKey,
  });

  final String id;
  final String? taskId;
  final String taskTitle;
  final TaskCategory category;
  final TaskDifficulty difficulty;
  final Mood mood;

  /// Встроенная техника. Для сессии, запущенной по пользовательскому пресету,
  /// здесь лежит ближайшая встроенная — как подложка для мест, умеющих
  /// работать только с перечислением. Источником правды для обучения и
  /// хранения служит [techniqueKey], а не это поле.
  final FocusTechnique technique;

  /// Ключ пользовательского пресета (`custom:<id>`), если сессия шла по нему.
  /// null — работала встроенная техника.
  final String? customTechniqueKey;

  /// То, что реально пишется в колонку `sessions.technique` и в таблицу
  /// весов. Разделение важно: без него сессия по пресету 35/7 обучала бы
  /// статистику ближайшего помидора и портила бы её чужими исходами.
  String get techniqueKey => customTechniqueKey ?? technique.key;

  /// Сессия шла по пользовательскому пресету.
  bool get isCustomTechnique => customTechniqueKey != null;

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

  /// Пользователь ушёл в ручную настройку и сменил технику на другую.
  ///
  /// Отдельный флаг, а не отрицание [wasRecommended]: подкрутить длину
  /// предложенного помидора — это согласие с техникой, а вот выбрать вместо
  /// неё другую — несогласие. Движок учитывает такой исход слабее: он
  /// говорит о недоверии к совету, а не о качестве самой техники.
  final bool wasManualOverride;

  /// Почему сессия оборвалась. null — доведена до конца либо причину
  /// не назвали.
  final InterruptionReason? interruptionReason;

  /// Короткая заметка пользователя «как прошло». null — пропустили.
  final String? sessionNote;

  /// Путь к прикреплённому фото на диске. null — фото не прикладывали.
  ///
  /// Полностью необязательное поле: ни статистика, ни движок рекомендаций
  /// его не читают, и сессия без фото ничем не отличается от прежних.
  final String? photoPath;

  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;

  int get actualFocusMinutes => (actualFocusSeconds / 60).round();

  /// Считается ли сессия успехом для обучения бандита: доведена до конца
  /// либо оценена на 3+ из 5. Прерванная и оценённая на 1–2 — неуспех.
  bool get isSuccess {
    if (rating != null) return rating! >= 3;
    return outcome == SessionOutcome.completed;
  }
}
