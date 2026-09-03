import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/core/photos/session_photo_store.dart';
import 'package:texfi_fokus/data/local/database.dart';
import 'package:texfi_fokus/data/repositories/session_repository_impl.dart';
import 'package:texfi_fokus/domain/entities/custom_preset.dart';
import 'package:texfi_fokus/domain/entities/focus_technique.dart';
import 'package:texfi_fokus/domain/entities/mood.dart';
import 'package:texfi_fokus/domain/entities/recommendation.dart';
import 'package:texfi_fokus/domain/entities/session_entity.dart';
import 'package:texfi_fokus/domain/entities/session_guards.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';
import 'package:texfi_fokus/domain/entities/technique_arm.dart';

/// Регрессии, найденные сквозным аудитом.
///
/// Собраны в один файл нарочно: у них общее происхождение, и оно важнее темы
/// каждой. Все четыре — это места, где фича, добавленная одним проходом,
/// не доехала до кода, добавленного другим, и ни одна из них не выглядела
/// сломанной на экране. Такие ошибки ловятся только тестом, который знает,
/// что именно разъехалось.
void main() {
  group('ночной кап считает по самому предложению, а не по «ближайшей» технике',
      () {
    Recommendation ofPreset({
      required int focusMinutes,
      required int breakMinutes,
      required int cycles,
    }) {
      final preset = CustomPreset(
        id: 'p1',
        name: 'Свой ритм',
        focusMinutes: focusMinutes,
        breakMinutes: breakMinutes,
        cycles: cycles,
      );
      return Recommendation.ofArm(
        TechniqueArm.custom(preset),
        reason: RecommendationReason.exploration,
      );
    }

    test('длинный пресет с коротким фокусом больше не проходит мимо капа', () {
      // Ровно тот случай, который проезжал: фокус 20 минут — короче
      // помидорных 25, поэтому первое условие молчит; а сумма спрашивалась у
      // `technique`, то есть у ближайшей встроенной (115 минут), а не у
      // настоящих 195.
      final rec = ofPreset(focusMinutes: 20, breakMinutes: 5, cycles: 8);
      expect(rec.totalMinutes, 195);
      expect(rec.technique.totalMinutes, lessThan(rec.totalMinutes));

      final capped = SessionGuards.capForNight(rec, hour: 3);
      expect(capped.cappedForNight, isTrue);
      expect(capped.technique, SessionGuards.nightCapTechnique);
      expect(capped.preset, isNull);
    });

    test('короткий пресет ночью остаётся как есть', () {
      // Кап только укорачивает. Подтягивать короткую сессию вверх до
      // помидора было бы ровно обратным тому, ради чего он написан.
      final rec = ofPreset(focusMinutes: 15, breakMinutes: 5, cycles: 2);
      expect(rec.totalMinutes, lessThan(SessionGuards.nightCapTechnique.totalMinutes));

      final capped = SessionGuards.capForNight(rec, hour: 2);
      expect(capped.cappedForNight, isFalse);
      expect(capped.preset, isNotNull);
      expect(capped.focusMinutes, 15);
    });

    test('днём не капается ничего, каким бы длинным ни было предложение', () {
      final rec = ofPreset(focusMinutes: 20, breakMinutes: 5, cycles: 8);
      expect(SessionGuards.capForNight(rec, hour: 14).cappedForNight, isFalse);
    });

    test('встроенные техники ведут себя ровно как раньше', () {
      for (final technique in FocusTechnique.values) {
        final rec = Recommendation.ofTechnique(
          technique,
          reason: RecommendationReason.exploration,
        );
        // Для встроенной руки собственная сумма и сумма техники совпадают —
        // именно поэтому баг и не был виден.
        expect(rec.totalMinutes, technique.totalMinutes);

        final capped = SessionGuards.capForNight(rec, hour: 23);
        final expected = technique.focusMinutes >
                SessionGuards.nightCapTechnique.focusMinutes ||
            technique.totalMinutes >
                SessionGuards.nightCapTechnique.totalMinutes;
        expect(capped.cappedForNight, expected, reason: technique.name);
      }
    });
  });

  group('уборка осиротевших снимков', () {
    late Directory documents;
    late FileSessionPhotoStore store;

    setUp(() async {
      documents = await Directory.systemTemp.createTemp('texfi_photos');
      store = FileSessionPhotoStore(documentsDirectory: () async => documents);
    });

    tearDown(() async {
      if (documents.existsSync()) await documents.delete(recursive: true);
    });

    Future<String> attach(String name) async {
      final source = File('${documents.path}/$name')..writeAsStringSync('jpg');
      return store.save(source.path);
    }

    test('удаляет только то, на что никто не ссылается', () async {
      final kept = await attach('kept.jpg');
      final orphan = await attach('orphan.jpg');

      final removed = await store.deleteUnreferenced({kept});

      expect(removed, 1);
      expect(File(kept).existsSync(), isTrue);
      expect(File(orphan).existsSync(), isFalse);
    });

    test('пустой список ссылок вычищает папку целиком', () async {
      await attach('a.jpg');
      await attach('b.jpg');
      expect(await store.deleteUnreferenced(const {}), 2);
    });

    test('без единого лишнего файла не трогает ничего', () async {
      final kept = await attach('kept.jpg');
      expect(await store.deleteUnreferenced({kept}), 0);
      expect(File(kept).existsSync(), isTrue);
    });

    test('отсутствующая папка — не ошибка', () async {
      // Фото ни разу не прикладывали: убирать нечего, и заводить папку ради
      // уборки незачем.
      expect(await store.deleteUnreferenced(const {}), 0);
    });
  });

  group('база знает, на какие снимки ссылаются сессии', () {
    late AppDatabase db;
    late SessionRepositoryImpl sessions;

    setUp(() {
      db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
      sessions = SessionRepositoryImpl(db);
    });

    tearDown(() => db.close());

    SessionEntity session(String id, {String? photoPath}) => SessionEntity(
          id: id,
          taskTitle: 'Диплом',
          category: TaskCategory.study,
          difficulty: TaskDifficulty.medium,
          mood: Mood.good,
          technique: FocusTechnique.values.first,
          plannedFocusMinutes: 25,
          plannedBreakMinutes: 5,
          plannedCycles: 2,
          actualFocusSeconds: 1500,
          outcome: SessionOutcome.completed,
          startedAt: DateTime(2026, 3, 1, 10),
          endedAt: DateTime(2026, 3, 1, 11),
          contextKey: 'good|study|medium|morning|7',
          photoPath: photoPath,
        );

    test('возвращает пути со снимками и пропускает сессии без них', () async {
      await sessions.addSession(session('s1', photoPath: '/photos/a.jpg'));
      await sessions.addSession(session('s2'));
      await sessions.addSession(session('s3', photoPath: '/photos/b.jpg'));

      expect(
        await sessions.referencedPhotoPaths(),
        {'/photos/a.jpg', '/photos/b.jpg'},
      );
    });

    test('пустая история не удерживает ни одного файла', () async {
      expect(await sessions.referencedPhotoPaths(), isEmpty);
    });
  });
}
