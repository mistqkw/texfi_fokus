import 'dart:math';

import 'package:collection/collection.dart';

import '../../domain/entities/focus_technique.dart';
import '../../domain/entities/mood.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/recommendation_engine.dart';
import '../../domain/entities/recommendation_weight_entity.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/repositories/recommendation_weight_repository.dart';
import '../../domain/repositories/session_repository.dart';

/// Адаптивный движок: контекстный бандит на бета-распределениях
/// (Thompson sampling) с небольшой примесью epsilon-greedy.
///
/// Почему именно так, а не таблица правил: правила пришлось бы угадывать за
/// пользователя, а люди отличаются сильно — кому-то на плохом настроении
/// помогает короткий спринт, а кто-то как раз в этом состоянии лучше входит
/// в длинную сессию. Бандит просто смотрит, что у ЭТОГО пользователя
/// заканчивалось успехом, и постепенно смещается туда.
///
/// Ключевая проблема — разреженность. Полный контекст
/// (настроение × категория × сложность × время суток × день недели) даёт
/// сотни комбинаций, и по каждой отдельно статистика копилась бы годами.
/// Поэтому статистика собирается по иерархии ключей — от точного до совсем
/// широкого — с убывающим весом. Узкий уровень перевешивает, как только на
/// нём набираются наблюдения.
///
/// Второе свойство, ради которого движок вообще стоит держать: наблюдения
/// затухают по календарному времени (см.
/// [RecommendationWeightEntity.decayedTo]). Вывод, сделанный полгода назад,
/// не должен спорить с тем, как человек работает сейчас.
class BanditRecommendationEngine implements RecommendationEngine {
  BanditRecommendationEngine({
    required this.weights,
    required this.sessions,
    Random? random,
    DateTime Function()? clock,
  })  : _random = random ?? Random(),
        _clock = clock ?? DateTime.now;

  final RecommendationWeightRepository weights;
  final SessionRepository sessions;
  final Random _random;
  final DateTime Function() _clock;

  /// Пока сессий меньше этого числа, бандит молчит и работают дефолты:
  /// на трёх наблюдениях он бы уверенно выучил случайный шум.
  static const int coldStartThreshold = 10;

  /// Доля запусков, отданных чистому исследованию. Небольшая: пользователь
  /// приходит работать, а не тестировать гипотезы за нас.
  static const double epsilon = 0.12;

  /// Вклад каждого уровня иерархии ключей — порядок совпадает с
  /// [RecommendationContext.keyHierarchy]:
  /// точный контекст, настроение × категория × сложность,
  /// настроение × категория, настроение × сложность,
  /// настроение × время суток, только настроение.
  ///
  /// Веса убывают не линейно: между точным ключом и «настроение + работа»
  /// разрыв небольшой (второй почти так же информативен и набирается
  /// гораздо быстрее), а вот чисто фоновые уровни намеренно слабые — они
  /// нужны только чтобы не остаться совсем без данных.
  static const List<double> _levelWeights = [1.0, 0.7, 0.5, 0.4, 0.3, 0.2];

  /// До какого уровня иерархии совпадение ещё считается «похожим
  /// контекстом», а не общим фоном. Индексы 1–3 — это ключи, в которых
  /// сохранилась сама работа (категория и/или сложность).
  static const int _similarScopeLastLevel = 3;

  @override
  Future<Recommendation> recommend(RecommendationContext context) async {
    final total = await sessions.totalSessionCount();
    if (total < coldStartThreshold) {
      return _coldStart(context, total);
    }

    final now = _clock();
    final byKey = await weights.weightsForContexts(context.keyHierarchy);
    final posteriors = _aggregate(context, byKey, now);

    // Epsilon-greedy поверх Thompson sampling: изредка берём случайную
    // технику целиком, чтобы не застрять в локальном оптимуме, если ранние
    // сессии случайно оказались удачными для одного варианта.
    if (_random.nextDouble() < epsilon) {
      final technique =
          FocusTechnique.values[_random.nextInt(FocusTechnique.values.length)];
      final posterior = posteriors[technique]!;
      return Recommendation.ofTechnique(
        technique,
        reason: RecommendationReason.exploration,
        confidence: posterior.mean,
        sampleSize: posterior.observations.round(),
        evidence: posterior.evidence(total),
      );
    }

    FocusTechnique? best;
    var bestSample = -1.0;
    for (final technique in FocusTechnique.values) {
      final posterior = posteriors[technique]!;
      final sample = _sampleBeta(posterior.alpha, posterior.beta);
      if (sample > bestSample) {
        bestSample = sample;
        best = technique;
      }
    }

    final technique = best ?? FocusTechnique.pomodoro2505;
    final posterior = posteriors[technique]!;

    // Если у победителя почти нет собственных наблюдений, честнее назвать
    // это исследованием, чем «выученным» выбором.
    final reason = posterior.observations < 2
        ? RecommendationReason.exploration
        : RecommendationReason.learned;

    return Recommendation.ofTechnique(
      technique,
      reason: reason,
      confidence: posterior.mean,
      sampleSize: posterior.observations.round(),
      evidence: posterior.evidence(total),
    );
  }

  @override
  Future<void> recordOutcome(SessionEntity session) async {
    final success = session.isSuccess;
    final now = _clock();
    final keys = _hierarchyOf(session.contextKey);

    for (var level = 0; level < keys.length; level++) {
      final key = keys[level];
      final existing = await weights.weightsForContext(key);
      final current = existing
          .where((w) => w.techniqueKey == session.technique.key)
          .firstOrNull;

      final base = current ??
          RecommendationWeightEntity.prior(
            contextKey: key,
            techniqueKey: session.technique.key,
            updatedAt: now,
          );

      await weights.upsertWeight(
        base.updated(
          success: success,
          at: now,
          weight: _levelWeights[level],
        ),
      );
    }
  }

  /// Разбирает сохранённый в сессии полный ключ обратно в иерархию.
  ///
  /// Если формат почему-то нарушен (сессия записана старой версией, ручная
  /// правка БД), откатываемся на то, что удаётся вытащить: обучить грубее
  /// лучше, чем потерять сессию целиком.
  List<String> _hierarchyOf(String contextKey) {
    final parsed = RecommendationContext.tryParse(contextKey);
    if (parsed != null) return parsed.keyHierarchy;

    final parts = contextKey.split('|');
    if (parts.length < 2) return [contextKey];
    return [contextKey, '${parts[0]}|${parts[1]}', parts[0]];
  }

  /// Складывает наблюдения со всех уровней иерархии в одно бета-распределение
  /// на технику. Априорное Beta(1,1) добавляется один раз.
  Map<FocusTechnique, _Posterior> _aggregate(
    RecommendationContext context,
    Map<String, List<RecommendationWeightEntity>> byKey,
    DateTime now,
  ) {
    final result = <FocusTechnique, _Posterior>{};
    final keys = context.keyHierarchy;

    for (final technique in FocusTechnique.values) {
      var alpha = 1.0;
      var beta = 1.0;
      var observations = 0.0;

      var scope = EvidenceScope.none;
      var matched = 0.0;
      var matchedSuccess = 0.0;
      var matchedLevelWeight = 1.0;

      for (var level = 0; level < keys.length && level < _levelWeights.length;
          level++) {
        final weight = _levelWeights[level];
        final entry = byKey[keys[level]]
            ?.where((w) => w.techniqueKey == technique.key)
            .firstOrNull
            // Затухание считаем на чтении, а не только на записи: между
            // сессиями могли пройти месяцы, и старая запись не должна
            // выглядеть свежей просто потому, что её не трогали.
            ?.decayedTo(now);
        if (entry == null || entry.observations <= 0) continue;

        // Вычитаем априорные единицы, чтобы не прибавлять их трижды.
        alpha += (entry.alpha - 1) * weight;
        beta += (entry.beta - 1) * weight;
        if (level == 0) observations += entry.observations;

        // Самый узкий уровень, на котором вообще что-то нашлось, и задаёт
        // формулировку объяснения. Дальше по циклу уровни только шире,
        // поэтому первое попадание — оно же лучшее.
        if (scope == EvidenceScope.none) {
          scope = switch (level) {
            0 => EvidenceScope.exact,
            <= _similarScopeLastLevel => EvidenceScope.similar,
            _ => EvidenceScope.broad,
          };
          matched = entry.observations;
          matchedSuccess = entry.alpha - 1;
          matchedLevelWeight = weight;
        }
      }

      result[technique] = _Posterior(
        alpha: alpha < 1 ? 1 : alpha,
        beta: beta < 1 ? 1 : beta,
        observations: observations,
        scope: scope,
        matchedObservations: matched,
        matchedSuccesses: matchedSuccess,
        matchedLevelWeight: matchedLevelWeight,
      );
    }
    return result;
  }

  /// Разумные дефолты на время холодного старта. Ровно то, что описано в
  /// спецификации: на плохом настроении — мягкий короткий спринт, на
  /// full f0kus — длинная сессия.
  Recommendation _coldStart(RecommendationContext context, int totalSessions) {
    final technique = switch (context.mood) {
      Mood.bad => FocusTechnique.sprint15,
      Mood.neutral => FocusTechnique.pomodoro2505,
      Mood.good => context.difficulty == TaskDifficulty.hard
          ? FocusTechnique.pomodoro5010
          : FocusTechnique.pomodoro2505,
      Mood.fullFokus => context.difficulty == TaskDifficulty.easy
          ? FocusTechnique.pomodoro5010
          : FocusTechnique.deepWork90,
    };
    return Recommendation.ofTechnique(
      technique,
      reason: RecommendationReason.coldStart,
      confidence: 0.5,
      evidence: RecommendationEvidence(
        scope: EvidenceScope.none,
        matchedSessions: 0,
        successRate: 0.5,
        totalSessions: totalSessions,
        sessionsUntilPersonalized:
            (coldStartThreshold - totalSessions).clamp(0, coldStartThreshold),
      ),
    );
  }

  // --- Сэмплирование ---

  /// Выборка из Beta(a, b) через две гамма-выборки: X / (X + Y).
  double _sampleBeta(double a, double b) {
    final x = _sampleGamma(a);
    final y = _sampleGamma(b);
    final sum = x + y;
    if (sum <= 0) return 0.5;
    return x / sum;
  }

  /// Метод Марсальи–Цанга. Для shape < 1 используется стандартный приём с
  /// домножением на u^(1/shape); в нашем случае shape всегда >= 1
  /// (априорное Beta(1,1)), но оставляем ветку на случай других приоров.
  double _sampleGamma(double shape) {
    if (shape < 1) {
      final u = _random.nextDouble();
      return _sampleGamma(shape + 1) * pow(u, 1 / shape).toDouble();
    }
    final d = shape - 1.0 / 3.0;
    final c = 1 / sqrt(9 * d);
    while (true) {
      double x;
      double v;
      do {
        x = _gaussian();
        v = 1 + c * x;
      } while (v <= 0);
      v = v * v * v;
      final u = _random.nextDouble();
      if (u < 1 - 0.0331 * x * x * x * x) return d * v;
      if (log(u) < 0.5 * x * x + d * (1 - v + log(v))) return d * v;
    }
  }

  /// Преобразование Бокса–Мюллера: стандартное нормальное распределение.
  double _gaussian() {
    final u1 = 1 - _random.nextDouble();
    final u2 = _random.nextDouble();
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }
}

class _Posterior {
  const _Posterior({
    required this.alpha,
    required this.beta,
    required this.observations,
    required this.scope,
    required this.matchedObservations,
    required this.matchedSuccesses,
    required this.matchedLevelWeight,
  });

  final double alpha;
  final double beta;

  /// Наблюдения только с точного уровня контекста — именно они показывают,
  /// насколько выбор персонализирован, а не унаследован от общей статистики.
  final double observations;

  /// Самый узкий уровень контекста, на котором нашлись наблюдения.
  final EvidenceScope scope;

  /// Наблюдения и успехи на этом уровне — из них экран собирает
  /// «N сессий, из них M успешных».
  final double matchedObservations;
  final double matchedSuccesses;

  /// Вес уровня, на котором нашлось совпадение. Наблюдения хранятся уже
  /// домноженными на него, поэтому для показа пользователю их надо поделить
  /// обратно: три сессии на уровне с весом 0.7 — это всё-таки три сессии,
  /// а не две.
  final double matchedLevelWeight;

  double get mean => alpha / (alpha + beta);

  /// Наблюдения, приведённые обратно к «числу сессий».
  double get matchedSessionCount => matchedLevelWeight <= 0
      ? matchedObservations
      : matchedObservations / matchedLevelWeight;

  /// Доля успехов на уровне совпадения. Именно её показываем пользователю:
  /// смешанное по иерархии [mean] описывает работу бандита, но не отвечает
  /// на вопрос «а у меня-то это работало?».
  double get matchedSuccessRate => matchedObservations <= 0
      ? mean
      : (matchedSuccesses / matchedObservations).clamp(0.0, 1.0);

  RecommendationEvidence evidence(int totalSessions) {
    final count = matchedSessionCount;
    return RecommendationEvidence(
      // Порог по округлению, а не по единице: одна сессия, слегка
      // подтаявшая от времени, всё равно остаётся одной сессией.
      scope: count < 0.5 ? EvidenceScope.none : scope,
      matchedSessions: count.round(),
      successRate: matchedSuccessRate,
      totalSessions: totalSessions,
      sessionsUntilPersonalized: 0,
    );
  }
}
