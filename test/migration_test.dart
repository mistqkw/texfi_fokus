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

/// Схема версии 7 в той части, которая нас здесь интересует: игровой слой уже
/// стоит, партия уже начата, а колонки `abandoned_count` ещё нет.
///
/// Пишется вручную по той же причине, что и [_schemaV1]: тест обязан ловить
/// ровно тот случай, когда новая колонка появилась только в `onCreate`, и у
/// человека с начатой партией её не окажется.
File _seedV7(Directory dir) {
  final file = File(p.join(dir.path, 'v7.sqlite'));
  final db = sqlite3.open(file.path);
  for (final statement in _schemaV1) {
    db.execute(statement);
  }
  // Колонки, добавленные миграциями v2-v6 к уже существующим таблицам.
  db.execute('ALTER TABLE sessions ADD COLUMN was_manual_override '
      'INTEGER NOT NULL DEFAULT 0');
  db.execute('ALTER TABLE sessions ADD COLUMN interruption_reason INTEGER');
  db.execute('ALTER TABLE sessions ADD COLUMN session_note TEXT');
  db.execute('ALTER TABLE sessions ADD COLUMN photo_path TEXT');
  db.execute('ALTER TABLE habits ADD COLUMN frequency_type '
      'INTEGER NOT NULL DEFAULT 0');
  db.execute('ALTER TABLE habits ADD COLUMN times_per_week '
      'INTEGER NOT NULL DEFAULT 3');
  db.execute('ALTER TABLE habits ADD COLUMN reward TEXT');
  db.execute('ALTER TABLE habits ADD COLUMN reward_streak_days '
      'INTEGER NOT NULL DEFAULT 7');
  db.execute('ALTER TABLE habits ADD COLUMN freeze_interval_days '
      'INTEGER NOT NULL DEFAULT 7');
  db.execute('''
    CREATE TABLE habit_freezes (
      id TEXT NOT NULL,
      habit_id TEXT NOT NULL,
      day INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      PRIMARY KEY (id)
    )''');
  db.execute('''
    CREATE TABLE day_plan_entries (
      id TEXT NOT NULL,
      day INTEGER NOT NULL,
      title TEXT NOT NULL,
      sort_order INTEGER NOT NULL DEFAULT 0,
      done INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      PRIMARY KEY (id)
    )''');
  db.execute('''
    CREATE TABLE subtasks (
      id TEXT NOT NULL,
      entry_id TEXT NOT NULL,
      title TEXT NOT NULL,
      sort_order INTEGER NOT NULL DEFAULT 0,
      done INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (id)
    )''');
  db.execute('''
    CREATE TABLE player_progress (
      id INTEGER NOT NULL DEFAULT 0,
      total_xp INTEGER NOT NULL DEFAULT 0,
      drifter_kills INTEGER NOT NULL DEFAULT 0,
      boss_kills INTEGER NOT NULL DEFAULT 0,
      updated_at INTEGER NOT NULL,
      PRIMARY KEY (id)
    )''');
  db.execute('''
    CREATE TABLE map_nodes (
      id TEXT NOT NULL,
      world INTEGER NOT NULL,
      position INTEGER NOT NULL,
      kind INTEGER NOT NULL,
      status INTEGER NOT NULL,
      species INTEGER NOT NULL DEFAULT 0,
      max_hp INTEGER NOT NULL,
      current_hp INTEGER NOT NULL,
      player_hp INTEGER NOT NULL DEFAULT 0,
      golden INTEGER NOT NULL DEFAULT 0,
      last_fought_at INTEGER,
      PRIMARY KEY (id)
    )''');
  db.execute('''
    CREATE TABLE game_settings (
      id INTEGER NOT NULL DEFAULT 0,
      enabled INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (id)
    )''');

  // Партия в разгаре: седьмой уровень, первый мир пройден, на втором стоит
  // недобитый дрифер. Ровно то, что человек потерял бы, если бы миграция
  // оказалась пересозданием таблицы.
  db.execute(
    'INSERT INTO player_progress (id, total_xp, drifter_kills, boss_kills, '
    'updated_at) VALUES (0, 1080, 7, 1, ?)',
    [_stamp(DateTime(2026, 2, 20))],
  );
  db.execute('INSERT INTO game_settings (id, enabled) VALUES (0, 1)');
  db.execute(
    'INSERT INTO map_nodes (id, world, position, kind, status, species, '
    'max_hp, current_hp, player_hp, golden) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    ['w1n1', 1, 1, 0, 2, 2, 31, 0, 0, 0],
  );
  db.execute(
    'INSERT INTO map_nodes (id, world, position, kind, status, species, '
    'max_hp, current_hp, player_hp, golden) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    ['w2n1', 2, 1, 0, 1, 3, 31, 12, 0, 1],
  );
  db.execute('PRAGMA user_version = 7');
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

    // v6: у сессии, записанной задолго до фото, поле просто пустое. Это
    // «фото не прикладывали», а не потеря данных, и обязательным оно не
    // стало ни на одну старую строку.
    expect(session.photoPath, isNull);

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

    // v5: игровой слой приезжает тремя новыми таблицами и ничем больше.
    // Пустые — игра по умолчанию выключена, и человек, обновившийся с v1,
    // не должен обнаружить у себя вдруг начатую партию.
    expect(await db.select(db.playerProgress).get(), isEmpty);
    expect(await db.select(db.mapNodes).get(), isEmpty);
    expect(await db.select(db.gameSettings).get(), isEmpty);

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
            photoPath: const Value('/photos/desk.jpg'),
          ),
        );

    final stored = await db.select(db.sessions).getSingle();
    expect(stored.sessionNote, '🔥 пошло');
    expect(stored.photoPath, '/photos/desk.jpg');

    await db.into(db.habitFreezes).insert(
          HabitFreezesCompanion.insert(
            id: 'f1',
            habitId: 'h1',
            day: DateTime(2026, 2, 1),
          ),
        );
    expect(await db.select(db.habitFreezes).get(), hasLength(1));
  });

  test('the game layer is additive: old tables keep their shape', () async {
    final file = _seedV1(dir);
    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    // Колонки существующих таблиц не должны ни исчезнуть, ни поменять тип:
    // игровой слой читает сессии и привычки, но не переписывает их схему.
    Future<List<String>> columnsOf(String table) async {
      final rows =
          await db.customSelect('PRAGMA table_info($table)').get();
      return rows.map((r) => r.data['name'] as String).toList();
    }

    final sessionColumns = await columnsOf('sessions');
    expect(sessionColumns, contains('actual_focus_seconds'));
    expect(sessionColumns, contains('context_key'));
    expect(sessionColumns, isNot(contains('xp')));
    // Фото приезжает одной добавленной колонкой и ничем больше: таблица не
    // пересоздавалась, история сессий на месте.
    expect(sessionColumns, contains('photo_path'));

    final weightColumns = await columnsOf('recommendation_weights');
    expect(weightColumns, isNot(contains('xp')));
    expect(weightColumns, isNot(contains('world')));

    // А новые таблицы — на месте и с нужными колонками.
    expect(await columnsOf('map_nodes'), containsAll(<String>[
      'world',
      'position',
      'kind',
      'status',
      'current_hp',
      'player_hp',
    ]));
    expect(await columnsOf('player_progress'), containsAll(<String>[
      'total_xp',
      'drifter_kills',
      'boss_kills',
    ]));
  });

  test('an upgrade from v7 keeps a game in progress and adds the counter',
      () async {
    final file = _seedV7(dir);
    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    // Прогресс на месте до последней цифры. Уровень и пройденные узлы — это
    // недели работы человека, и восстановлению они не подлежат.
    final progress = await db.select(db.playerProgress).getSingle();
    expect(progress.totalXp, 1080);
    expect(progress.drifterKills, 7);
    expect(progress.bossKills, 1);

    final nodes = await db.select(db.mapNodes).get();
    expect(nodes, hasLength(2));

    final cleared = nodes.firstWhere((n) => n.id == 'w1n1');
    expect(cleared.status, 2);
    expect(cleared.currentHp, 0);

    // Недобитый дрифер второго мира сохранил и HP, и редкую окраску.
    final wounded = nodes.firstWhere((n) => n.id == 'w2n1');
    expect(wounded.currentHp, 12);
    expect(wounded.golden, isTrue);
    expect(wounded.species, 3);

    // Новая колонка появилась и у старых строк честно начинается с нуля:
    // сколько раз человек уходил с этого узла до обновления, взять неоткуда,
    // а выдуманное число приложение потом назвало бы вслух.
    expect(cleared.abandonedCount, 0);
    expect(wounded.abandonedCount, 0);

    // И игровой режим остался включённым: миграция не трогает выбор.
    final settings = await db.select(db.gameSettings).getSingle();
    expect(settings.enabled, isTrue);

    final version =
        await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);
  });
}
