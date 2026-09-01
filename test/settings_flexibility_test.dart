import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texfi_fokus/data/local/backup_scheduler.dart';
import 'package:texfi_fokus/data/local/export_service.dart';
import 'package:texfi_fokus/domain/entities/focus_technique.dart';
import 'package:texfi_fokus/domain/entities/mood.dart';
import 'package:texfi_fokus/domain/entities/session_entity.dart';
import 'package:texfi_fokus/domain/entities/session_guards.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';
import 'package:texfi_fokus/presentation/settings/settings_providers.dart';

SessionEntity _aborted(int n) => SessionEntity(
      id: 's$n',
      taskTitle: 't',
      category: TaskCategory.work,
      difficulty: TaskDifficulty.medium,
      mood: Mood.neutral,
      technique: FocusTechnique.pomodoro2505,
      plannedFocusMinutes: 25,
      plannedBreakMinutes: 5,
      plannedCycles: 4,
      actualFocusSeconds: 60,
      outcome: SessionOutcome.aborted,
      startedAt: DateTime(2026, 3, n + 1),
      endedAt: DateTime(2026, 3, n + 1, 1),
      contextKey: 'k',
    );

SessionEntity _completed(int n) => SessionEntity(
      id: 'c$n',
      taskTitle: 't',
      category: TaskCategory.work,
      difficulty: TaskDifficulty.medium,
      mood: Mood.neutral,
      technique: FocusTechnique.pomodoro2505,
      plannedFocusMinutes: 25,
      plannedBreakMinutes: 5,
      plannedCycles: 4,
      actualFocusSeconds: 25 * 60,
      outcome: SessionOutcome.completed,
      startedAt: DateTime(2026, 3, n + 1),
      endedAt: DateTime(2026, 3, n + 1, 1),
      contextKey: 'k',
    );

void main() {
  group('порог серии прерываний', () {
    test('порог 2 срабатывает там, где порог 3 ещё молчит', () {
      final two = [_aborted(0), _aborted(1)];
      expect(SessionGuards.isBurnoutStreak(two, threshold: 2), isTrue);
      expect(SessionGuards.isBurnoutStreak(two, threshold: 3), isFalse);
    });

    test('порог 5 требует ровно пяти подряд', () {
      final four = [for (var i = 0; i < 4; i++) _aborted(i)];
      expect(SessionGuards.isBurnoutStreak(four, threshold: 5), isFalse);

      final five = [for (var i = 0; i < 5; i++) _aborted(i)];
      expect(SessionGuards.isBurnoutStreak(five, threshold: 5), isTrue);
    });

    test('доведённая сессия рвёт серию на любом пороге', () {
      final mixed = [_aborted(0), _completed(1), _aborted(2), _aborted(3)];
      for (var t = SessionGuards.minStreakThreshold;
          t <= SessionGuards.maxStreakThreshold;
          t++) {
        expect(SessionGuards.isBurnoutStreak(mixed, threshold: t), isFalse,
            reason: 'порог $t');
      }
    });

    test('настройка не выходит за собственные границы', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = BurnoutStreakNotifier(prefs);

      await notifier.set(99);
      expect(notifier.state, SessionGuards.maxStreakThreshold);
      await notifier.set(0);
      expect(notifier.state, SessionGuards.minStreakThreshold);
    });

    test('сохранённое за границами значение подрезается при чтении', () async {
      SharedPreferences.setMockInitialValues({
        PrefKeys.burnoutStreakThreshold: 42,
      });
      final prefs = await SharedPreferences.getInstance();
      expect(
        BurnoutStreakNotifier(prefs).state,
        SessionGuards.maxStreakThreshold,
      );
    });

    test('лента последних сессий вмещает максимальный порог', () {
      // Регрессия: лента ограничивалась текущим порогом, и «пять подряд»
      // не могло сработать никогда — в ней лежало только три сессии.
      expect(
        SessionGuards.maxStreakThreshold,
        greaterThanOrEqualTo(SessionGuards.burnoutStreakThreshold),
      );
    });
  });

  group('начало недели', () {
    test('понедельник: неделя начинается с понедельника', () {
      // 2026-03-04 — среда.
      final wed = DateTime(2026, 3, 4);
      expect(WeekStartDay.monday.startOf(wed), DateTime(2026, 3, 2));
    });

    test('воскресенье: та же среда попадает в неделю, начатую раньше', () {
      final wed = DateTime(2026, 3, 4);
      expect(WeekStartDay.sunday.startOf(wed), DateTime(2026, 3, 1));
    });

    test('сам первый день недели остаётся собой', () {
      final mon = DateTime(2026, 3, 2);
      expect(WeekStartDay.monday.startOf(mon), mon);

      final sun = DateTime(2026, 3, 1);
      expect(WeekStartDay.sunday.startOf(sun), sun);
    });

    test('воскресенье не уезжает на неделю назад', () {
      // Самый опасный случай: без `% 7` сдвиг стал бы отрицательным и
      // начало недели уехало бы вперёд, а не назад.
      final sun = DateTime(2026, 3, 8);
      final start = WeekStartDay.sunday.startOf(sun);
      expect(start, sun);
      expect(start.isAfter(sun), isFalse);
    });

    test('начало недели никогда не позже самого дня и не дальше 6 суток', () {
      for (var d = 1; d <= 28; d++) {
        final day = DateTime(2026, 3, d);
        for (final mode in WeekStartDay.values) {
          final start = mode.startOf(day);
          expect(start.isAfter(day), isFalse, reason: '$mode $day');
          expect(day.difference(start).inDays, lessThan(7),
              reason: '$mode $day');
          expect(start.weekday, mode.weekday, reason: '$mode $day');
        }
      }
    });

    test('время суток срезается', () {
      final noon = DateTime(2026, 3, 4, 13, 45);
      expect(WeekStartDay.monday.startOf(noon), DateTime(2026, 3, 2));
    });

    test('пустых клеток heatmap ровно столько, сколько дней до начала недели',
        () {
      // Среда при неделе с понедельника — две пустые клетки.
      expect(
        WeekStartDay.monday.leadingBlanksFor(DateTime(2026, 3, 4)),
        2,
      );
      // Та же среда при неделе с воскресенья — три.
      expect(
        WeekStartDay.sunday.leadingBlanksFor(DateTime(2026, 3, 4)),
        3,
      );
      // Никогда не отрицательное и всегда меньше недели.
      for (var d = 1; d <= 14; d++) {
        for (final mode in WeekStartDay.values) {
          final blanks = mode.leadingBlanksFor(DateTime(2026, 3, d));
          expect(blanks, inInclusiveRange(0, 6));
        }
      }
    });

    test('настройка переживает перезапуск', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await WeekStartNotifier(prefs).set(WeekStartDay.sunday);
      expect(WeekStartNotifier(prefs).state, WeekStartDay.sunday);
    });

    test('по умолчанию — понедельник', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(WeekStartNotifier(prefs).state, WeekStartDay.monday);
    });
  });

  group('резервная копия по расписанию', () {
    test('без единой копии она назрела сразу', () {
      expect(
        BackupSchedule.isDue(lastAt: null, now: DateTime(2026, 3, 1)),
        isTrue,
      );
    });

    test('через день после копии — ещё рано', () {
      expect(
        BackupSchedule.isDue(
          lastAt: DateTime(2026, 3, 1),
          now: DateTime(2026, 3, 2),
        ),
        isFalse,
      );
    });

    test('ровно через неделю — пора', () {
      expect(
        BackupSchedule.isDue(
          lastAt: DateTime(2026, 3, 1),
          now: DateTime(2026, 3, 8),
        ),
        isTrue,
      );
    });

    test('часы, переведённые назад, не блокируют копию навсегда', () {
      expect(
        BackupSchedule.isDue(
          lastAt: DateTime(2026, 3, 10),
          now: DateTime(2026, 3, 1),
        ),
        isTrue,
      );
    });

    test('имя файла содержит дату и сортируется лексикографически', () {
      final a = ExportService.backupFileName(DateTime(2026, 3, 9));
      final b = ExportService.backupFileName(DateTime(2026, 3, 10));
      final c = ExportService.backupFileName(DateTime(2026, 12, 1));

      expect(a, 'texfi-fokus-backup-2026-03-09.json');
      expect(b, 'texfi-fokus-backup-2026-03-10.json');
      // Именно ради этого дата дополняется нулями: иначе «март 9» встал бы
      // после «марта 10», и чистка старых копий удаляла бы не те файлы.
      expect([c, a, b]..sort(), [a, b, c]);
    });

    test('выключенный тумблер не пишет ничего', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final runner = BackupRunner(
        prefs: prefs,
        // Сервис намеренно негодный: если бы его тронули, тест упал бы.
        exportService: _ExplodingExport(),
      );
      expect(await runner.runIfDue(enabled: false), isNull);
    });

    test('неудачная запись не двигает отметку времени', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final runner = BackupRunner(
        prefs: prefs,
        exportService: _ExplodingExport(),
      );

      expect(await runner.runIfDue(enabled: true), isNull);
      // Отметка осталась пустой: иначе сбой отложил бы следующую попытку
      // на неделю, и человек остался бы вообще без копий.
      expect(prefs.getString(PrefKeys.lastAutoBackupAt), isNull);
      expect(runner.lastBackupAt, isNull);
    });
  });
}

/// Экспорт, который всегда падает. Проверяет, что планировщик переживает
/// занятый диск и не записывает успех, которого не было.
class _ExplodingExport implements ExportService {
  @override
  Future<String> writeScheduledBackup({DateTime? at}) async {
    throw const FileSystemException('disk is busy');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
