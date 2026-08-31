import 'package:drift/drift.dart';

import '../../domain/entities/mood.dart';
import '../../domain/entities/mood_entry_entity.dart';
import '../../domain/repositories/mood_repository.dart';
import '../local/database.dart';

class MoodRepositoryImpl implements MoodRepository {
  MoodRepositoryImpl(this._db);

  final AppDatabase _db;

  MoodEntryEntity _toEntity(MoodEntry row) {
    return MoodEntryEntity(
      id: row.id,
      mood: Mood.fromIndex(row.mood),
      recordedAt: row.recordedAt,
      sessionId: row.sessionId,
    );
  }

  @override
  Future<void> addEntry(MoodEntryEntity entry) async {
    await _db.into(_db.moodEntries).insert(
          MoodEntriesCompanion(
            id: Value(entry.id),
            mood: Value(entry.mood.index),
            recordedAt: Value(entry.recordedAt),
            sessionId: Value(entry.sessionId),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  @override
  Future<void> linkSession({
    required String entryId,
    required String sessionId,
  }) async {
    await (_db.update(_db.moodEntries)..where((t) => t.id.equals(entryId)))
        .write(MoodEntriesCompanion(sessionId: Value(sessionId)));
  }

  @override
  Stream<List<MoodEntryEntity>> watchEntries({int limit = 50}) {
    final query = _db.select(_db.moodEntries)
      ..orderBy([
        (t) => OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<List<MoodEntryEntity>> entriesInRange(
    DateTime from,
    DateTime to,
  ) async {
    final query = _db.select(_db.moodEntries)
      ..where((t) =>
          t.recordedAt.isBiggerOrEqualValue(from) &
          t.recordedAt.isSmallerOrEqualValue(to))
      ..orderBy([(t) => OrderingTerm(expression: t.recordedAt)]);
    final rows = await query.get();
    return rows.map(_toEntity).toList();
  }
}
