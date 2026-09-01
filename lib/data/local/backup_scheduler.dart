import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/settings/settings_providers.dart';
import '../providers/data_providers.dart';
import 'export_service.dart';

/// Решает, пора ли снимать автоматическую резервную копию.
///
/// Расписание без фонового планировщика: проверка делается на старте
/// приложения. Для офлайн-приложения этого достаточно — человек, который не
/// открывал приложение две недели, и данных за эти две недели не создал, а
/// системный планировщик ради одного файла в неделю тянул бы за собой
/// разрешения и платформенный код на каждой из платформ.
///
/// Логика «пора или нет» вынесена в чистую функцию: проверять её надо без
/// диска, часов и Riverpod.
abstract final class BackupSchedule {
  /// [lastAt] null — копий ещё не было, и первую снимаем сразу: иначе
  /// человек, включивший тумблер, неделю жил бы вообще без копии, думая,
  /// что она есть.
  static bool isDue({
    required DateTime? lastAt,
    required DateTime now,
    Duration interval = ExportService.backupInterval,
  }) {
    if (lastAt == null) return true;
    final elapsed = now.difference(lastAt);
    // Часы, переведённые назад, дают отрицательный интервал. Считаем такую
    // отметку недостоверной и снимаем копию: лишний файл дешевле пропущенного.
    if (elapsed.isNegative) return true;
    return elapsed >= interval;
  }
}

/// Снимает копию, если она назрела. Возвращает путь к файлу либо null, если
/// делать ничего не потребовалось.
///
/// Ошибки проглатываются намеренно: неудачная запись копии не должна ни
/// ронять запуск, ни выдавать пользователю диалог о том, чего он не просил.
class BackupRunner {
  BackupRunner({
    required this.prefs,
    required this.exportService,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SharedPreferences prefs;
  final ExportService exportService;
  final DateTime Function() _clock;

  DateTime? get lastBackupAt {
    final raw = prefs.getString(PrefKeys.lastAutoBackupAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<String?> runIfDue({required bool enabled}) async {
    if (!enabled) return null;
    final now = _clock();
    if (!BackupSchedule.isDue(lastAt: lastBackupAt, now: now)) return null;

    try {
      final path = await exportService.writeScheduledBackup(at: now);
      await prefs.setString(
        PrefKeys.lastAutoBackupAt,
        now.toIso8601String(),
      );
      return path;
    } on Object {
      // Диск занят, папка недоступна, места нет — попробуем на следующем
      // запуске. Отметку времени при этом НЕ двигаем, иначе неудачная
      // попытка отложила бы следующую на неделю.
      return null;
    }
  }
}

final backupRunnerProvider = Provider<BackupRunner>((ref) {
  return BackupRunner(
    prefs: ref.watch(sharedPreferencesProvider),
    exportService: ref.watch(exportServiceProvider),
  );
});

/// Дата последней автоматической копии — настройки показывают её под
/// тумблером, чтобы «раз в неделю» не осталось обещанием на словах.
final lastAutoBackupProvider = StateProvider<DateTime?>((ref) {
  return ref.watch(backupRunnerProvider).lastBackupAt;
});
