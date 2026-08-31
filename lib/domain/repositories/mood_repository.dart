import '../entities/mood_entry_entity.dart';

abstract class MoodRepository {
  Future<void> addEntry(MoodEntryEntity entry);

  /// Привязывает ранее записанную отметку настроения к состоявшейся сессии.
  Future<void> linkSession({
    required String entryId,
    required String sessionId,
  });

  Stream<List<MoodEntryEntity>> watchEntries({int limit = 50});

  Future<List<MoodEntryEntity>> entriesInRange(DateTime from, DateTime to);
}
