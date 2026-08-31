import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';

/// Экспорт всей базы в один JSON-файл. Для офлайн-приложения без облака это
/// единственная страховка от потери данных — и единственный способ
/// перенести историю на другое устройство.
class ExportService {
  ExportService(this._db);

  final AppDatabase _db;

  /// Версия формата. Импорт (когда появится) сможет по ней понять, как
  /// читать файл, не гадая по содержимому.
  static const int formatVersion = 1;

  Future<Map<String, dynamic>> buildSnapshot() async {
    final habits = await _db.select(_db.habits).get();
    final completions = await _db.select(_db.habitCompletions).get();
    final tasks = await _db.select(_db.tasks).get();
    final sessions = await _db.select(_db.sessions).get();
    final moods = await _db.select(_db.moodEntries).get();
    final weights = await _db.select(_db.recommendationWeights).get();

    return {
      'format': 'texfi_fokus_backup',
      'version': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habits.map((r) => r.toJson()).toList(),
      'habitCompletions': completions.map((r) => r.toJson()).toList(),
      'tasks': tasks.map((r) => r.toJson()).toList(),
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
}
