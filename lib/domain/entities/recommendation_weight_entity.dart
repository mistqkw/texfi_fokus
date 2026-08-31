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

  final String contextKey;
  final String techniqueKey;
  final double alpha;
  final double beta;
  final DateTime updatedAt;

  /// Сколько наблюдений стоит за этой парой (без учёта априорных единиц).
  double get observations => alpha + beta - 2;

  /// Средняя оценка вероятности успеха.
  double get mean => alpha / (alpha + beta);

  /// Обновление после сессии. Успех двигает alpha, неуспех — beta.
  ///
  /// [decay] < 1 слегка «забывает» старую статистику, чтобы движок успевал
  /// за изменениями в жизни пользователя, а не цементировал вывод, сделанный
  /// полгода назад.
  RecommendationWeightEntity updated({
    required bool success,
    required DateTime at,
    double weight = 1.0,
    double decay = 0.98,
  }) {
    final decayedAlpha = 1 + (alpha - 1) * decay;
    final decayedBeta = 1 + (beta - 1) * decay;
    return RecommendationWeightEntity(
      contextKey: contextKey,
      techniqueKey: techniqueKey,
      alpha: success ? decayedAlpha + weight : decayedAlpha,
      beta: success ? decayedBeta : decayedBeta + weight,
      updatedAt: at,
    );
  }
}
