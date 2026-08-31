import '../entities/session_entity.dart';
import '../entities/statistics.dart';

abstract class SessionRepository {
  Future<void> addSession(SessionEntity session);

  Stream<List<SessionEntity>> watchRecentSessions({int limit = 20});

  Future<List<SessionEntity>> sessionsInRange(DateTime from, DateTime to);

  /// Общее число записанных сессий. По нему движок рекомендаций решает,
  /// вышел ли пользователь из холодного старта.
  Future<int> totalSessionCount();

  /// Секунды в фокусе за день — карточка сводки на Home.
  Stream<int> watchFocusSecondsForDay(DateTime day);

  /// Секунды в фокусе за произвольный период.
  Stream<int> watchFocusSecondsInRange(DateTime from, DateTime to);

  Stream<FocusSummary> watchSummary(DateTime from, DateTime to);

  Stream<List<DailyFocus>> watchDailyFocus(DateTime from, DateTime to);

  Stream<List<MoodOutcomeStat>> watchMoodStats(DateTime from, DateTime to);

  Stream<List<CategoryFocusStat>> watchCategoryStats(DateTime from, DateTime to);
}
