import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:texfi_fokus/data/local/database.dart';

/// Схема версии 1 — ровно та, что стоит у людей, поставивших v1.0.1.
///
/// DDL написан вручную и здесь и остаётся: смысл теста в том, чтобы поймать
/// момент, когда новая колонка появится только в `onCreate`, а базы, уже
/// заполненные данными, останутся без неё. Сгенерированная схема для такой
/// проверки не годится — она всегда «правильная».
const List<String> _schemaV1 = [
  '''
  CREATE TABLE habits (
    id TEXT NOT NULL,
    name TEXT NOT NULL,
    punishment TEXT NOT NULL,
    weekday_mask INTEGER NOT NULL DEFAULT 127,
    reminder_minutes INTEGER,
    archived INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    PRIMARY KEY (id)
  )''',
  '''
  CREATE TABLE habit_completions (
    id TEXT NOT NULL,
    habit_id TEXT NOT NULL,
    day INTEGER NOT NULL,
    completed_at INTEGER NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (habit_id, day)
  )''',
  '''
  CREATE TABLE tasks (
    id TEXT NOT NULL,
    title TEXT NOT NULL,
    category INTEGER NOT NULL DEFAULT 5,
    difficulty INTEGER NOT NULL DEFAULT 1,
    created_at INTEGER NOT NULL,
    last_used_at INTEGER,
    archived INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (id)
  )''',
  '''
  CREATE TABLE sessions (
    id TEXT NOT NULL,
    task_id TEXT,
    task_title TEXT NOT NULL,
    category INTEGER NOT NULL,
    difficulty INTEGER NOT NULL,
    mood INTEGER NOT NULL,
    technique TEXT NOT NULL,
    planned_focus_minutes INTEGER NOT NULL,
    planned_break_minutes INTEGER NOT NULL,
    planned_cycles INTEGER NOT NULL,
    actual_focus_seconds INTEGER NOT NULL,
    outcome INTEGER NOT NULL,
    rating INTEGER,
    started_at INTEGER NOT NULL,
    ended_at INTEGER NOT NULL,
    context_key TEXT NOT NULL,
    was_recommended INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (id)
  )''',
  '''
  CREATE TABLE mood_entries (
    id TEXT NOT NULL,
    mood INTEGER NOT NULL,
    recorded_at INTEGER NOT NULL,
    session_id TEXT,
    PRIMARY KEY (id)
  )''',
  '''
  CREATE TABLE recommendation_weights (
    context_key TEXT NOT NULL,
    technique_key TEXT NOT NULL,
    alpha REAL NOT NULL DEFAULT 1.0,
    beta REAL NOT NULL DEFAULT 1.0,
    updated_at INTEGER NOT NULL,
    PRIMARY KEY (context_key, technique_key)
  )''',
];

int _stamp(DateTime moment) => moment.millisecondsSinceEpoch ~/ 1000;

/// Готовит файл базы в схеме v1 с данными «прежнего пользователя».
File _seedV1(Directory dir) {
  final file = File(p.join(dir.path, 'v1.sqlite'));
  final db = sqlite3.open(file.path);
  for (final statement in _schemaV1) {
    db.execute(statement);
  }

  db.execute(
    'INSERT INTO habits (id, name, punishment, weekday_mask, archived, '
    'sort_order, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
    ['h1', 'Зарядка', 'Без сериала вечером', 127, 0, 0, _stamp(DateTime(2026, 1, 1))],
  );
  db.execute(
    'INSERT INTO habit_completions (id, habit_id, day, completed_at) '
    'VALUES (?, ?, ?, ?)',
    ['c1', 'h1', _stamp(DateTime(2026, 1, 2)), _stamp(DateTime(2026, 1, 2, 8))],
  );
  db.execute(
    'INSERT INTO sessions (id, task_title, category, difficulty, mood, '
    'technique, planned_focus_minutes, planned_break_minutes, planned_cycles, '
    'actual_focus_seconds, outcome, started_at, ended_at, context_key, '
    'was_recommended) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      's1',
      'Диплом',
      1,
      2,
      2,
      'pomodoro2505',
      25,
      5,
      4,
      1500,
      0,
      _stamp(DateTime(2026, 1, 2, 10)),
      _stamp(DateTime(2026, 1, 2, 11)),
      'good|work|hard|morning|5',
      1,
    ],
  );
  db.execute('PRAGMA user_version = 1');
  db.dispose();
  return file;
}

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('texfi_fokus_migration');
  });

  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  test('an upgrade from v1 keeps the data and adds the new columns', () async {
    final file = _seedV1(dir);
    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    // Триггерим открытие и, вместе с ним, миграцию.
    final sessions = await db.select(db.sessions).get();

    expect(sessions, hasLength(1));
    final session = sessions.single;
    expect(session.taskTitle, 'Диплом');
    expect(session.wasRecommended, isTrue);

    // Новые колонки существуют и заполнены нейтральными значениями, а не
    // мусором и не NOT NULL-ошибкой на старой строке.
    expect(session.wasManualOverride, isFalse);
    expect(session.interruptionReason, isNull);
    expect(session.sessionNote, isNull);

    // Соседние таблицы миграцию тоже переживают.
    expect(await db.select(db.habitCompletions).get(), hasLength(1));

    // v3: у старой привычки появляются новые поля с разумными значениями —
    // никакой «частоты 0 раз в неделю» и никакого потерянного наказания.
    final habit = await db.select(db.habits).getSingle();
    expect(habit.name, 'Зарядка');
    expect(habit.punishment, 'Без сериала вечером');
    expect(habit.frequencyType, 0);
    expect(habit.weekdayMask, 127);
    expect(habit.timesPerWeek, 3);
    expect(habit.reward, isNull);
    expect(habit.freezeIntervalDays, 7);

    // Новые таблицы созданы и пусты — заморозки, план дня, чеклисты.
    expect(await db.select(db.habitFreezes).get(), isEmpty);
    expect(await db.select(db.dayPlanEntries).get(), isEmpty);
    expect(await db.select(db.subtasks).get(), isEmpty);

    final version = await db
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.data.values.single, db.schemaVersion);
  });

  test('a fresh database is created straight at the current version', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.sessions).insert(
          SessionsCompanion.insert(
            id: 'fresh',
            taskTitle: 'Задача',
            category: 1,
            difficulty: 1,
            mood: 1,
            technique: 'sprint15',
            plannedFocusMinutes: 15,
            plannedBreakMinutes: 5,
            plannedCycles: 2,
            actualFocusSeconds: 900,
            outcome: 0,
            startedAt: DateTime(2026, 2, 1, 9),
            endedAt: DateTime(2026, 2, 1, 10),
            contextKey: 'good|work|hard|morning|5',
            sessionNote: const Value('🔥 пошло'),
          ),
        );

    final stored = await db.select(db.sessions).getSingle();
    expect(stored.sessionNote, '🔥 пошло');

    await db.into(db.habitFreezes).insert(
          HabitFreezesCompanion.insert(
            id: 'f1',
            habitId: 'h1',
            day: DateTime(2026, 2, 1),
          ),
        );
    expect(await db.select(db.habitFreezes).get(), hasLength(1));
  });
}
