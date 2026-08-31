import 'focus_technique.dart';
import 'mood.dart';
import 'task_category.dart';

/// Время суток, огрублённое до четырёх корзин. Минуты и даже часы в чистом
/// виде дали бы слишком разреженную статистику: по каждому сочетанию просто
/// не набралось бы сессий.
enum TimeOfDayBucket {
  morning,
  afternoon,
  evening,
  night;

  static TimeOfDayBucket fromHour(int hour) {
    if (hour >= 5 && hour < 12) return TimeOfDayBucket.morning;
    if (hour >= 12 && hour < 17) return TimeOfDayBucket.afternoon;
    if (hour >= 17 && hour < 23) return TimeOfDayBucket.evening;
    return TimeOfDayBucket.night;
  }
}

/// Контекст, в котором пользователь запускает сессию. Из него собирается
/// ключ, по которому движок хранит статистику успешности каждой техники.
class RecommendationContext {
  const RecommendationContext({
    required this.mood,
    required this.category,
    required this.difficulty,
    required this.timeOfDay,
    required this.weekday,
  });

  /// Собирает контекст из текущего времени.
  factory RecommendationContext.now({
    required Mood mood,
    required TaskCategory category,
    required TaskDifficulty difficulty,
    DateTime? at,
  }) {
    final moment = at ?? DateTime.now();
    return RecommendationContext(
      mood: mood,
      category: category,
      difficulty: difficulty,
      timeOfDay: TimeOfDayBucket.fromHour(moment.hour),
      weekday: moment.weekday,
    );
  }

  final Mood mood;
  final TaskCategory category;
  final TaskDifficulty difficulty;
  final TimeOfDayBucket timeOfDay;

  /// 1 — понедельник … 7 — воскресенье (как в [DateTime.weekday]).
  final int weekday;

  /// Полный ключ контекста. Используется для точных совпадений.
  String get key =>
      '${mood.name}|${category.name}|${difficulty.name}|${timeOfDay.name}|$weekday';

  /// Огрублённый ключ: только настроение и категория задачи. Нужен потому,
  /// что полный ключ слишком узкий — пока по нему нет данных, движок
  /// подмешивает статистику с этого уровня.
  String get coarseKey => '${mood.name}|${category.name}';

  /// Самый широкий ключ — только настроение. Последний уровень отката,
  /// прежде чем остаться совсем без данных.
  String get moodKey => mood.name;

  /// Ключи от самого узкого к самому широкому — движок идёт по ним,
  /// набирая статистику с убывающим весом.
  List<String> get keyHierarchy => [key, coarseKey, moodKey];
}

/// Причина, по которой предложена именно эта техника. UI показывает по ней
/// человеческое объяснение.
enum RecommendationReason {
  /// Данных о пользователе ещё мало — сработали дефолты под настроение.
  coldStart,

  /// Выбор сделан по накопленной личной статистике.
  learned,

  /// Техника выбрана ради исследования: движок проверяет вариант, о котором
  /// знает мало.
  exploration,
}

/// Готовое предложение: техника плюс конкретные параметры таймера.
class Recommendation {
  const Recommendation({
    required this.technique,
    required this.focusMinutes,
    required this.breakMinutes,
    required this.cycles,
    required this.reason,
    required this.confidence,
    required this.sampleSize,
  });

  /// Предложение «как в техник по умолчанию», без правок длительностей.
  factory Recommendation.ofTechnique(
    FocusTechnique technique, {
    required RecommendationReason reason,
    double confidence = 0.5,
    int sampleSize = 0,
  }) {
    return Recommendation(
      technique: technique,
      focusMinutes: technique.focusMinutes,
      breakMinutes: technique.breakMinutes,
      cycles: technique.cycles,
      reason: reason,
      confidence: confidence,
      sampleSize: sampleSize,
    );
  }

  final FocusTechnique technique;
  final int focusMinutes;
  final int breakMinutes;
  final int cycles;
  final RecommendationReason reason;

  /// Оценка вероятности успеха 0..1 по накопленной статистике.
  final double confidence;

  /// Сколько сессий стоит за этой оценкой — UI показывает её осторожнее,
  /// когда сессий мало.
  final int sampleSize;

  Recommendation copyWith({
    int? focusMinutes,
    int? breakMinutes,
    int? cycles,
  }) {
    return Recommendation(
      technique: technique,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      cycles: cycles ?? this.cycles,
      reason: reason,
      confidence: confidence,
      sampleSize: sampleSize,
    );
  }
}
