import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';

/// Экспорт всей базы в один JSON-файл. Для офлайн-приложения без облака это
/// единственная страховка от потери данных — и единственный способ
/// перенести историю на другое устройство.
class ExportService {
  ExportService(this._db);

  final AppDatabase _db;

  /// Версия формата. Импорт по ней понимает, как читать файл, не гадая по
  /// содержимому.
  static const int formatVersion = 1;

  static const String formatName = 'texfi_fokus_backup';

  Future<Map<String, dynamic>> buildSnapshot() async {
    final habits = await _db.select(_db.habits).get();
    final completions = await _db.select(_db.habitCompletions).get();
    final freezes = await _db.select(_db.habitFreezes).get();
    final tasks = await _db.select(_db.tasks).get();
    final planEntries = await _db.select(_db.dayPlanEntries).get();
    final subtasks = await _db.select(_db.subtasks).get();
    final sessions = await _db.select(_db.sessions).get();
    final moods = await _db.select(_db.moodEntries).get();
    final weights = await _db.select(_db.recommendationWeights).get();

    return {
      'format': 'texfi_fokus_backup',
      'version': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habits.map((r) => r.toJson()).toList(),
      'habitCompletions': completions.map((r) => r.toJson()).toList(),
      'habitFreezes': freezes.map((r) => r.toJson()).toList(),
      'tasks': tasks.map((r) => r.toJson()).toList(),
      'dayPlanEntries': planEntries.map((r) => r.toJson()).toList(),
      'subtasks': subtasks.map((r) => r.toJson()).toList(),
      'sessions': sessions.map((r) => r.toJson()).toList(),
      'moodEntries': moods.map((r) => r.toJson()).toList(),
      'recommendationWeights': weights.map((r) => r.toJson()).toList(),
    };
  }

  /// Пишет снимок в файл и возвращает его путь.
  Future<String> exportToFile() async {
    final snapshot = await buildSnapshot();
    final json = const JsonEncoder.withIndent('  ').convert(snapshot);

    final dir = await _exportDirectory();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final file = File(p.join(dir.path, 'texfi-fokus-backup-$stamp.json'));
    await file.writeAsString(json);
    return file.path;
  }

  /// На десктопе кладём выгрузку в «Документы», на мобильных — в доступную
  /// приложению папку документов.
  Future<Directory> _exportDirectory() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      try {
        final documents = await getApplicationDocumentsDirectory();
        return documents;
      } catch (_) {
        // На некоторых сборках Linux XDG-папок может не быть.
      }
    }
    return getApplicationDocumentsDirectory();
  }

  /// Читает выгрузку и заливает её в базу.
  ///
  /// [merge] — не трогать существующие строки с теми же id (перенос на
  /// новое устройство поверх пары пробных записей); иначе база очищается
  /// целиком и заменяется содержимым файла. Второй режим разрушителен, и
  /// спрашивать о нём обязан вызывающий, а не эта функция.
  Future<ImportResult> importFromFile(File file, {required bool merge}) async {
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('root is not an object');
    }
    return importSnapshot(decoded, merge: merge);
  }

  Future<ImportResult> importSnapshot(
    Map<String, dynamic> snapshot, {
    required bool merge,
  }) async {
    // Проверяем формат до единой записи в базу: испорченный файл не должен
    // успеть снести чужую историю на полпути.
    if (snapshot['format'] != formatName) {
      throw const FormatException('not a TexFi f0kus backup');
    }
    final version = snapshot['version'];
    if (version is! int || version > formatVersion) {
      throw FormatException('unsupported backup version: $version');
    }

    List<Map<String, dynamic>> rowsOf(String key) {
      final value = snapshot[key];
      if (value == null) return const [];
      if (value is! List) throw FormatException('$key is not a list');
      return [
        for (final row in value)
          if (row is Map<String, dynamic>)
            row
          else
            throw FormatException('$key contains a non-object row'),
      ];
    }

    final habits = rowsOf('habits');
    final completions = rowsOf('habitCompletions');
    final freezes = rowsOf('habitFreezes');
    final tasks = rowsOf('tasks');
    final planEntries = rowsOf('dayPlanEntries');
    final subtasks = rowsOf('subtasks');
    final sessions = rowsOf('sessions');
    final moods = rowsOf('moodEntries');
    final weights = rowsOf('recommendationWeights');

    final result = ImportResult(
      habits: habits.length,
      sessions: sessions.length,
      tasks: tasks.length,
    );

    // Всё одной транзакцией: наполовину импортированная база хуже, чем
    // не импортированная вовсе.
    await _db.transaction(() async {
      if (!merge) {
        await _db.delete(_db.habitCompletions).go();
        await _db.delete(_db.habitFreezes).go();
        await _db.delete(_db.habits).go();
        await _db.delete(_db.dayPlanEntries).go();
        await _db.delete(_db.subtasks).go();
        await _db.delete(_db.sessions).go();
        await _db.delete(_db.moodEntries).go();
        await _db.delete(_db.recommendationWeights).go();
        await _db.delete(_db.tasks).go();
      }

      final mode = merge ? InsertMode.insertOrIgnore : InsertMode.insertOrReplace;

      // Порядок важен: сначала то, на что ссылаются.
      await _insertAll(_db.habits, habits, mode, Habit.fromJson);
      await _insertAll(
        _db.habitCompletions,
        completions,
        mode,
        HabitCompletion.fromJson,
      );
      await _insertAll(_db.habitFreezes, freezes, mode, HabitFreeze.fromJson);
      await _insertAll(_db.tasks, tasks, mode, Task.fromJson);
      await _insertAll(
        _db.dayPlanEntries,
        planEntries,
        mode,
        DayPlanEntry.fromJson,
      );
      await _insertAll(_db.subtasks, subtasks, mode, Subtask.fromJson);
      await _insertAll(_db.sessions, sessions, mode, Session.fromJson);
      await _insertAll(_db.moodEntries, moods, mode, MoodEntry.fromJson);
      await _insertAll(
        _db.recommendationWeights,
        weights,
        mode,
        RecommendationWeight.fromJson,
      );
    });

    return result;
  }

  /// Разбор идёт через сгенерированный `fromJson` таблицы: писать разбор
  /// колонок руками значило бы продублировать всю схему второй раз и
  /// разойтись с ней на первой же миграции.
  Future<void> _insertAll<T extends Table, D extends Insertable<D>>(
    TableInfo<T, D> table,
    List<Map<String, dynamic>> rows,
    InsertMode mode,
    D Function(Map<String, dynamic> json) parse,
  ) async {
    for (final row in rows) {
      await _db.into(table).insert(parse(row), mode: mode);
    }
  }
}

/// Сколько чего приехало — экран показывает это в подтверждении.
class ImportResult {
  const ImportResult({
    required this.habits,
    required this.sessions,
    required this.tasks,
  });

  final int habits;
  final int sessions;
  final int tasks;
}
