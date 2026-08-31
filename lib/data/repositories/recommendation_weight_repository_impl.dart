import 'package:drift/drift.dart';

import '../../domain/entities/recommendation_weight_entity.dart';
import '../../domain/repositories/recommendation_weight_repository.dart';
import '../local/database.dart';

class RecommendationWeightRepositoryImpl
    implements RecommendationWeightRepository {
  RecommendationWeightRepositoryImpl(this._db);

  final AppDatabase _db;

  RecommendationWeightEntity _toEntity(RecommendationWeight row) {
    return RecommendationWeightEntity(
      contextKey: row.contextKey,
      techniqueKey: row.techniqueKey,
      alpha: row.alpha,
      beta: row.beta,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<List<RecommendationWeightEntity>> weightsForContext(
    String contextKey,
  ) async {
    final rows = await (_db.select(_db.recommendationWeights)
          ..where((t) => t.contextKey.equals(contextKey)))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<Map<String, List<RecommendationWeightEntity>>> weightsForContexts(
    List<String> contextKeys,
  ) async {
    if (contextKeys.isEmpty) return const {};
    final rows = await (_db.select(_db.recommendationWeights)
          ..where((t) => t.contextKey.isIn(contextKeys)))
        .get();
    final grouped = <String, List<RecommendationWeightEntity>>{
      for (final key in contextKeys) key: <RecommendationWeightEntity>[],
    };
    for (final row in rows) {
      grouped[row.contextKey]?.add(_toEntity(row));
    }
    return grouped;
  }

  @override
  Future<void> upsertWeight(RecommendationWeightEntity weight) async {
    await _db.into(_db.recommendationWeights).insert(
          RecommendationWeightsCompanion(
            contextKey: Value(weight.contextKey),
            techniqueKey: Value(weight.techniqueKey),
            alpha: Value(weight.alpha),
            beta: Value(weight.beta),
            updatedAt: Value(weight.updatedAt),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<List<RecommendationWeightEntity>> allWeights() async {
    final rows = await _db.select(_db.recommendationWeights).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.recommendationWeights).go();
  }
}
