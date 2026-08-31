import 'recommendation.dart';
import 'session_entity.dart';

/// Контракт адаптивного движка рекомендаций.
///
/// Интерфейс живёт в `domain/`, чтобы алгоритм можно было заменить целиком —
/// на другой бандит, на EMA, когда-нибудь на серверную модель — не трогая
/// ни один экран. UI знает только про [recommend] и [recordOutcome].
abstract class RecommendationEngine {
  /// Что запустить прямо сейчас в данном контексте.
  Future<Recommendation> recommend(RecommendationContext context);

  /// Скормить движку результат состоявшейся сессии. Вызывается и когда
  /// сессия доведена до конца, и когда она прервана — второе не менее важно.
  Future<void> recordOutcome(SessionEntity session);
}
