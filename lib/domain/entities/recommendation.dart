import 'package:collection/collection.dart';

import 'custom_preset.dart';
import 'focus_technique.dart';
import 'mood.dart';
import 'task_category.dart';
import 'technique_arm.dart';

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

  /// Восстанавливает контекст из сохранённого в сессии полного ключа.
  /// Возвращает null, если формат не тот, — вызывающий сам решит, что
  /// делать с такой записью.
  static RecommendationContext? tryParse(String contextKey) {
    final parts = contextKey.split('|');
    if (parts.length < 5) return null;
    final mood = Mood.values.where((m) => m.name == parts[0]).firstOrNull;
    final category =
        TaskCategory.values.where((c) => c.name == parts[1]).firstOrNull;
    final difficulty =
        TaskDifficulty.values.where((d) => d.name == parts[2]).firstOrNull;
    final time =
        TimeOfDayBucket.values.where((t) => t.name == parts[3]).firstOrNull;
    final weekday = int.tryParse(parts[4]);
    if (mood == null ||
        category == null ||
        difficulty == null ||
        time == null ||
        weekday == null) {
      return null;
    }
    return RecommendationContext(
      mood: mood,
      category: category,
      difficulty: difficulty,
      timeOfDay: time,
      weekday: weekday,
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

  /// Настроение × категория × сложность. Средний уровень: снимает с ключа
  /// самое разреженное — время суток и день недели, — но сохраняет всё, что
  /// описывает саму работу.
  String get taskKey => '${mood.name}|${category.name}|${difficulty.name}';

  /// Огрублённый ключ: только настроение и категория задачи.
  String get coarseKey => '${mood.name}|${category.name}';

  /// Настроение × сложность. Для части людей «тяжело/легко» предсказывает
  /// нужную длину сессии лучше, чем тема задачи: с трудной задачей на плохом
  /// настроении короткий спринт спасает независимо от того, учёба это или
  /// работа. Префикс `d:` держит эти ключи в своём пространстве имён, чтобы
  /// они никогда не столкнулись с `mood|category`.
  String get difficultyKey => '${mood.name}|d:${difficulty.name}';

  /// Настроение × время суток. Ловит «совиность»: вечером человек тянет
  /// длинную сессию, утром — нет.
  String get timeKey => '${mood.name}|t:${timeOfDay.name}';

  /// Самый широкий ключ — только настроение. Последний уровень отката,
  /// прежде чем остаться совсем без данных.
  String get moodKey => mood.name;

  /// Ключи от самого узкого к самому широкому — движок идёт по ним,
  /// набирая статистику с убывающим весом.
  List<String> get keyHierarchy =>
      [key, taskKey, coarseKey, difficultyKey, timeKey, moodKey];
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

/// Насколько узко совпал контекст, на котором держится рекомендация.
/// Порядок — от самого точного совпадения к его отсутствию; UI по нему
/// выбирает формулировку и «шкалу доказательности».
enum EvidenceScope {
  /// Ровно этот контекст: то же настроение, категория, сложность, время
  /// суток и день недели.
  exact,

  /// Похожая работа: настроение + категория (+ сложность).
  similar,

  /// Только настроение или время суток — самый широкий откат.
  broad,

  /// Собственных наблюдений по этой технике нет вовсе.
  none,
}

/// Что именно стоит за рекомендацией. Отдельный объект, потому что экрану
/// нужно не «доверие 63%», а конкретика: сколько сессий, насколько похожих,
/// и сколько ещё осталось до персонализации.
class RecommendationEvidence {
  const RecommendationEvidence({
    required this.scope,
    required this.matchedSessions,
    required this.successRate,
    required this.totalSessions,
    required this.sessionsUntilPersonalized,
  });

  static const RecommendationEvidence empty = RecommendationEvidence(
    scope: EvidenceScope.none,
    matchedSessions: 0,
    successRate: 0.5,
    totalSessions: 0,
    sessionsUntilPersonalized: 0,
  );

  /// Самый узкий уровень контекста, на котором нашлись наблюдения.
  final EvidenceScope scope;

  /// Сколько сессий стоит за оценкой на этом уровне. Дробные веса уровней
  /// уже округлены — пользователю честнее целое число.
  final int matchedSessions;

  /// Доля успехов у выбранной техники на этом уровне, 0..1.
  final double successRate;

  /// Сколько сессий записано всего — общий объём истории.
  final int totalSessions;

  /// Сколько сессий осталось до выхода из холодного старта. 0 — уже вышли.
  final int sessionsUntilPersonalized;

  /// Есть ли вообще на что опираться.
  bool get hasData => matchedSessions > 0 && scope != EvidenceScope.none;
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
    this.evidence = RecommendationEvidence.empty,
    this.cappedForNight = false,
    this.preset,
  });

  /// Предложение по конкретной руке — встроенной или пользовательской.
  /// Длительности берутся из руки, поэтому пресет попадает в таймер ровно
  /// таким, каким его завёл пользователь.
  factory Recommendation.ofArm(
    TechniqueArm arm, {
    required RecommendationReason reason,
    double confidence = 0.5,
    int sampleSize = 0,
    RecommendationEvidence evidence = RecommendationEvidence.empty,
  }) {
    return Recommendation(
      technique: arm.technique,
      focusMinutes: arm.focusMinutes,
      breakMinutes: arm.breakMinutes,
      cycles: arm.cycles,
      reason: reason,
      confidence: confidence,
      sampleSize: sampleSize,
      evidence: evidence,
      preset: arm.preset,
    );
  }

  /// Предложение «как в технике по умолчанию», без правок длительностей.
  factory Recommendation.ofTechnique(
    FocusTechnique technique, {
    required RecommendationReason reason,
    double confidence = 0.5,
    int sampleSize = 0,
    RecommendationEvidence evidence = RecommendationEvidence.empty,
  }) {
    return Recommendation(
      technique: technique,
      focusMinutes: technique.focusMinutes,
      breakMinutes: technique.breakMinutes,
      cycles: technique.cycles,
      reason: reason,
      confidence: confidence,
      sampleSize: sampleSize,
      evidence: evidence,
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

  /// Подробная выкладка «почему именно это» для экрана рекомендации.
  final RecommendationEvidence evidence;

  /// Предложение укорочено ночным софт-капом. Экран обязан сказать об этом
  /// вслух: беззвучно подменённая рекомендация выглядит как сбой движка.
  final bool cappedForNight;

  /// Пользовательский пресет, если предложена именно его рука. null —
  /// встроенная техника.
  final CustomPreset? preset;

  /// Ключ руки — то, что уедет в сессию и в таблицу весов.
  String get techniqueKey => preset?.key ?? technique.key;

  Recommendation copyWith({
    FocusTechnique? technique,
    int? focusMinutes,
    int? breakMinutes,
    int? cycles,
    bool? cappedForNight,
    // Ночной кап подменяет руку на встроенную, и пресет обязан сброситься
    // вместе с ней: иначе сессия ушла бы в статистику пресета, которого в
    // ней уже нет.
    bool clearPreset = false,
  }) {
    return Recommendation(
      preset: clearPreset ? null : preset,
      technique: technique ?? this.technique,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      cycles: cycles ?? this.cycles,
      reason: reason,
      confidence: confidence,
      sampleSize: sampleSize,
      evidence: evidence,
      cappedForNight: cappedForNight ?? this.cappedForNight,
    );
  }
}
