import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Brightness;
import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/core/theme/app_accent.dart';
import 'package:texfi_fokus/core/theme/app_palettes.dart';
import 'package:texfi_fokus/core/theme/app_theme.dart';
import 'package:texfi_fokus/data/local/database.dart';
import 'package:texfi_fokus/data/local/export_service.dart';

Future<void> _seed(AppDatabase db, {String habitId = 'h1'}) async {
  await db.into(db.habits).insert(
        HabitsCompanion.insert(
          id: habitId,
          name: 'Зарядка',
          punishment: 'Без сериала',
          createdAt: Value(DateTime(2026, 1, 1)),
        ),
      );
  await db.into(db.tasks).insert(
        TasksCompanion.insert(
          id: 'task-$habitId',
          title: 'Диплом',
          createdAt: Value(DateTime(2026, 1, 1)),
        ),
      );
  await db.into(db.sessions).insert(
        SessionsCompanion.insert(
          id: 'session-$habitId',
          taskTitle: 'Диплом',
          category: 1,
          difficulty: 2,
          mood: 2,
          technique: 'pomodoro2505',
          plannedFocusMinutes: 25,
          plannedBreakMinutes: 5,
          plannedCycles: 4,
          actualFocusSeconds: 1500,
          outcome: 0,
          startedAt: DateTime(2026, 1, 2, 10),
          endedAt: DateTime(2026, 1, 2, 11),
          contextKey: 'good|work|hard|morning|5',
          sessionNote: const Value('🔥 пошло'),
        ),
      );
}

void main() {
  group('backup round-trip', () {
    late AppDatabase source;
    late AppDatabase target;

    setUp(() {
      source = AppDatabase.forTesting(NativeDatabase.memory());
      target = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await source.close();
      await target.close();
    });

    test('a snapshot restores onto an empty database', () async {
      await _seed(source);
      final snapshot = await ExportService(source).buildSnapshot();

      final result =
          await ExportService(target).importSnapshot(snapshot, merge: false);

      expect(result.habits, 1);
      expect(result.tasks, 1);
      expect(result.sessions, 1);

      final session = await target.select(target.sessions).getSingle();
      expect(session.taskTitle, 'Диплом');
      // Заметка и время переживают путь через JSON — именно на них
      // сериализация обычно и ломается.
      expect(session.sessionNote, '🔥 пошло');
      expect(session.startedAt, DateTime(2026, 1, 2, 10));
    });

    test('replace wipes what was there before', () async {
      await _seed(source);
      await _seed(target, habitId: 'other');

      final snapshot = await ExportService(source).buildSnapshot();
      await ExportService(target).importSnapshot(snapshot, merge: false);

      final habits = await target.select(target.habits).get();
      expect(habits.map((h) => h.id), ['h1']);
    });

    test('merge keeps local rows and adds the missing ones', () async {
      await _seed(source);
      await _seed(target, habitId: 'other');

      final snapshot = await ExportService(source).buildSnapshot();
      await ExportService(target).importSnapshot(snapshot, merge: true);

      final habits = await target.select(target.habits).get();
      expect(habits.map((h) => h.id).toSet(), {'h1', 'other'});
    });

    test('merge does not overwrite a row that already exists', () async {
      await _seed(source);
      await _seed(target);
      await (target.update(target.habits)..where((t) => t.id.equals('h1')))
          .write(const HabitsCompanion(name: Value('Переименованная')));

      final snapshot = await ExportService(source).buildSnapshot();
      await ExportService(target).importSnapshot(snapshot, merge: true);

      final habit = await target.select(target.habits).getSingle();
      expect(habit.name, 'Переименованная');
    });

    test('a foreign file is refused before anything is written', () async {
      await _seed(target, habitId: 'local');
      final service = ExportService(target);

      await expectLater(
        service.importSnapshot(const {'format': 'something_else'}, merge: false),
        throwsA(isA<FormatException>()),
      );
      await expectLater(
        service.importSnapshot(
          const {'format': 'texfi_fokus_backup', 'version': 99},
          merge: false,
        ),
        throwsA(isA<FormatException>()),
      );

      // Главное: отказ не должен стоить пользователю его собственных данных.
      expect(await target.select(target.habits).get(), hasLength(1));
    });

    test('a malformed row aborts the whole import', () async {
      await _seed(target, habitId: 'local');
      await expectLater(
        ExportService(target).importSnapshot(
          const {
            'format': 'texfi_fokus_backup',
            'version': 1,
            'habits': ['not an object'],
          },
          merge: false,
        ),
        throwsA(isA<FormatException>()),
      );
      expect(await target.select(target.habits).get(), hasLength(1));
    });
  });

  group('accent presets', () {
    test('the default preset leaves the palette untouched', () {
      expect(
        AppTheme.colorsFor(Brightness.dark, accent: AppAccent.blue),
        AppPalettes.dark,
      );
    });

    test('another preset changes the accent and nothing structural', () {
      final base = AppPalettes.dark;
      final themed =
          AppTheme.colorsFor(Brightness.dark, accent: AppAccent.mint);

      expect(themed.accent, AppAccent.mint.color);
      expect(themed.accentShadow, AppAccent.mint.shadow);
      // Фон, поверхности и семантические цвета — не акцент, и меняться им
      // незачем: иначе пресет превратился бы во вторую тему.
      expect(themed.background, base.background);
      expect(themed.surface, base.surface);
      expect(themed.divider, base.divider);
      expect(themed.success, base.success);
      expect(themed.warning, base.warning);
      expect(themed.danger, base.danger);
    });

    test('an unknown stored key falls back to the brand blue', () {
      expect(AppAccent.fromKey('chartreuse'), AppAccent.blue);
      expect(AppAccent.fromKey(null), AppAccent.blue);
    });

    test('every preset key is unique and stable', () {
      final keys = AppAccent.values.map((a) => a.key).toList();
      expect(keys.toSet(), hasLength(keys.length));
      for (final accent in AppAccent.values) {
        expect(AppAccent.fromKey(accent.key), accent);
      }
    });
  });
}
