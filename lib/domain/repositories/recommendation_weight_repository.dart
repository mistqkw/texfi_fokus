import '../entities/recommendation_weight_entity.dart';

abstract class RecommendationWeightRepository {
  /// Веса по одному ключу контекста, по одной записи на технику.
  Future<List<RecommendationWeightEntity>> weightsForContext(String contextKey);

  /// Веса сразу по нескольким ключам — движок запрашивает всю иерархию
  /// (точный ключ, огрублённый, только настроение) одним походом в БД.
  Future<Map<String, List<RecommendationWeightEntity>>> weightsForContexts(
    List<String> contextKeys,
  );

  Future<void> upsertWeight(RecommendationWeightEntity weight);

  Future<List<RecommendationWeightEntity>> allWeights();

  /// Полный сброс обучения — на случай, если пользователь захочет начать
  /// с чистого листа.
  Future<void> clear();
}
