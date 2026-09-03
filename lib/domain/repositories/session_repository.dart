import '../entities/session_entity.dart';
import '../entities/statistics.dart';

abstract class SessionRepository {
  Future<void> addSession(SessionEntity session);

  /// Убирает сессию из истории вместе с прикреплённым файлом фото.
  ///
  /// Удаление именно здесь, а не в интерфейсе: экран, который забыл бы
  /// стереть картинку, оставил бы на устройстве файл, на который больше никто
  /// не ссылается и который поэтому уже никогда не будет удалён.
  Future<void> deleteSession(String id);

  /// Пути ко всем снимкам, на которые ссылается хоть одна сессия.
  ///
  /// Нужен уборке осиротевших файлов: копия снимка ложится на диск раньше,
  /// чем сессия попадает в базу, и брошенный по дороге черновик оставляет
  /// файл, на который уже никто не сошлётся. Это единственный источник
  /// правды о том, что удалять нельзя.
  Future<Set<String>> referencedPhotoPaths();

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

  /// Почему сессии обрывались — разбивка по названным причинам.
  Stream<List<InterruptionReasonStat>> watchInterruptionStats(
    DateTime from,
    DateTime to,
  );
}
