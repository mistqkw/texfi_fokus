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
/// Поэтому статистика собирается по иерархии ключей — точный, огрублённый
/// (настроение × категория) и совсем широкий (только настроение) — с
/// убывающим весом. Узкий уровень перевешивает, как только на нём
/// набираются наблюдения.
class BanditRecommendationEngine implements RecommendationEngine {
  BanditRecommendationEngine({
    required this.weights,
    required this.sessions,
    Random? random,
  }) : _random = random ?? Random();

  final RecommendationWeightRepository weights;
  final SessionRepository sessions;
  final Random _random;

  /// Пока сессий меньше этого числа, бандит молчит и работают дефолты:
  /// на трёх наблюдениях он бы уверенно выучил случайный шум.
  static const int coldStartThreshold = 10;

  /// Доля запусков, отданных чистому исследованию. Небольшая: пользователь
  /// приходит работать, а не тестировать гипотезы за нас.
  static const double epsilon = 0.12;

  /// Вклад каждого уровня иерархии ключей: точный контекст, настроение +
  /// категория, только настроение.
  static const List<double> _levelWeights = [1.0, 0.5, 0.25];

  @override
  Future<Recommendation> recommend(RecommendationContext context) async {
    final total = await sessions.totalSessionCount();
    if (total < coldStartThreshold) {
      return _coldStart(context);
    }

    final byKey = await weights.weightsForContexts(context.keyHierarchy);
    final posteriors = _aggregate(context, byKey);

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
    );
  }

  @override
  Future<void> recordOutcome(SessionEntity session) async {
    final success = session.isSuccess;
    final now = DateTime.now();
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
  /// Если формат почему-то нарушен (миграция, ручная правка БД), молча
  /// используем то, что есть, — терять сессию хуже, чем обучить грубее.
  List<String> _hierarchyOf(String contextKey) {
    final parts = contextKey.split('|');
    if (parts.length < 2) return [contextKey];
    return [
      contextKey,
      '${parts[0]}|${parts[1]}',
      parts[0],
    ];
  }

  /// Складывает наблюдения со всех уровней иерархии в одно бета-распределение
  /// на технику. Априорное Beta(1,1) добавляется один раз.
  Map<FocusTechnique, _Posterior> _aggregate(
    RecommendationContext context,
    Map<String, List<RecommendationWeightEntity>> byKey,
  ) {
    final result = <FocusTechnique, _Posterior>{};
    final keys = context.keyHierarchy;

    for (final technique in FocusTechnique.values) {
      var alpha = 1.0;
      var beta = 1.0;
      var observations = 0.0;

      for (var level = 0; level < keys.length; level++) {
        final weight = _levelWeights[level];
        final entry = byKey[keys[level]]
            ?.where((w) => w.techniqueKey == technique.key)
            .firstOrNull;
        if (entry == null) continue;
        // Вычитаем априорные единицы, чтобы не прибавлять их трижды.
        alpha += (entry.alpha - 1) * weight;
        beta += (entry.beta - 1) * weight;
        if (level == 0) observations += entry.observations;
      }

      result[technique] = _Posterior(
        alpha: alpha < 1 ? 1 : alpha,
        beta: beta < 1 ? 1 : beta,
        observations: observations,
      );
    }
    return result;
  }

  /// Разумные дефолты на время холодного старта. Ровно то, что описано в
  /// спецификации: на плохом настроении — мягкий короткий спринт, на
  /// full f0kus — длинная сессия.
  Recommendation _coldStart(RecommendationContext context) {
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
  });

  final double alpha;
  final double beta;

  /// Наблюдения только с точного уровня контекста — именно они показывают,
  /// насколько выбор персонализирован, а не унаследован от общей статистики.
  final double observations;

  double get mean => alpha / (alpha + beta);
}
