import 'dart:math';

/// Параметры бета-распределения для одной пары (ключ контекста × техника).
///
/// alpha — «сколько раз сработало», beta — «сколько раз не сработало», обе
/// начинаются с 1 (равномерное априорное распределение). Thompson sampling
/// берёт из этого распределения случайную выборку, поэтому техника с малой
/// статистикой иногда выигрывает — так движок продолжает исследовать.
class RecommendationWeightEntity {
  const RecommendationWeightEntity({
    required this.contextKey,
    required this.techniqueKey,
    required this.alpha,
    required this.beta,
    required this.updatedAt,
  });

  const RecommendationWeightEntity.prior({
    required this.contextKey,
    required this.techniqueKey,
    required this.updatedAt,
  })  : alpha = 1.0,
        beta = 1.0;

  /// Период полураспада наблюдений в днях. За [halfLifeDays] дней вес
  /// накопленной статистики падает вдвое.
  ///
  /// 45 дней — компромисс, который видно на практике: результат месячной
  /// давности ещё заметно влияет на выбор, а полугодовой почти не влияет
  /// (0.5^4 ≈ 6%). Человек за полгода меняет и работу, и режим сна; движок,
  /// который цементирует вывод, сделанный тогда, ощущается сломанным.
  static const double defaultHalfLifeDays = 45;

  final String contextKey;
  final String techniqueKey;
  final double alpha;
  final double beta;
  final DateTime updatedAt;

  /// Сколько наблюдений стоит за этой парой (без учёта априорных единиц).
  double get observations => alpha + beta - 2;

  /// Средняя оценка вероятности успеха.
  double get mean => alpha / (alpha + beta);

  /// Состояние на момент [now] с учётом давности последнего обновления.
  ///
  /// Затухает именно календарное время, а не число обновлений: иначе
  /// пользователь, не заходивший месяц, вернулся бы ровно к той же картине,
  /// что и оставил, а активный за ту же неделю — к сильно размытой.
  ///
  /// Априорные единицы не затухают: Beta(1,1) — это «ничего не знаю», а не
  /// наблюдение, и уводить его в ноль было бы бессмысленно.
  RecommendationWeightEntity decayedTo(
    DateTime now, {
    double halfLifeDays = defaultHalfLifeDays,
  }) {
    if (halfLifeDays <= 0) return this;
    final elapsedDays =
        now.difference(updatedAt).inSeconds / Duration.secondsPerDay;
    if (elapsedDays <= 0) return this;

    final factor = pow(0.5, elapsedDays / halfLifeDays).toDouble();
    return RecommendationWeightEntity(
      contextKey: contextKey,
      techniqueKey: techniqueKey,
      alpha: 1 + (alpha - 1) * factor,
      beta: 1 + (beta - 1) * factor,
      updatedAt: now,
    );
  }

  /// Обновление после сессии. Успех двигает alpha, неуспех — beta.
  ///
  /// Перед добавлением нового наблюдения старое затухает по [decayedTo], так
  /// что свежая сессия всегда весит больше давних. Побочный эффект приятный:
  /// alpha и beta не растут бесконечно, а стабилизируются около предела,
  /// заданного темпом сессий и периодом полураспада.
  RecommendationWeightEntity updated({
    required bool success,
    required DateTime at,
    double weight = 1.0,
    double halfLifeDays = defaultHalfLifeDays,
  }) {
    final aged = decayedTo(at, halfLifeDays: halfLifeDays);
    return RecommendationWeightEntity(
      contextKey: contextKey,
      techniqueKey: techniqueKey,
      alpha: success ? aged.alpha + weight : aged.alpha,
      beta: success ? aged.beta : aged.beta + weight,
      updatedAt: at,
    );
  }
}
