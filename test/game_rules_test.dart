import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/domain/entities/game_rules.dart';
import 'package:texfi_fokus/domain/entities/mood.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';

/// Игровой слой — это в первую очередь арифметика: кривая опыта, HP
/// противника, кто кому и сколько наносит. Всё это невидимо для глаза и
/// ломается молча, поэтому проверяется здесь целиком, а не «поиграем и
/// посмотрим».
void main() {
  group('кривая опыта', () {
    test('первый уровень начинается с нуля', () {
      expect(GameRules.totalXpForLevel(1), 0);
      expect(GameRules.levelForXp(0), 1);
      expect(GameRules.levelForXp(-100), 1);
    });

    test('следующий уровень всегда дороже предыдущего', () {
      // Ровно это и делает прогрессию прогрессией: если шаг перестанет
      // расти, десятый уровень возьмётся так же легко, как второй.
      for (var level = 1; level < 30; level++) {
        expect(
          GameRules.xpToAdvance(level + 1),
          greaterThan(GameRules.xpToAdvance(level)),
          reason: 'шаг с уровня ${level + 1} должен быть больше шага с $level',
        );
      }
    });

    test('уровень и порог согласованы между собой', () {
      for (var level = 1; level <= 20; level++) {
        final floor = GameRules.totalXpForLevel(level);
        // Ровно на пороге — уже новый уровень.
        expect(GameRules.levelForXp(floor), level);
        // На одно очко ниже — ещё предыдущий.
        if (level > 1) expect(GameRules.levelForXp(floor - 1), level - 1);
      }
    });

    test('прогресс внутри уровня идёт от нуля к единице', () {
      expect(GameRules.levelProgress(GameRules.totalXpForLevel(3)), 0.0);

      final floor = GameRules.totalXpForLevel(3);
      final span = GameRules.xpToAdvance(3);
      expect(GameRules.levelProgress(floor + span ~/ 2), closeTo(0.5, 0.01));
    });

    test('разбивка совпадает с полоской опыта', () {
      final floor = GameRules.totalXpForLevel(4);
      final breakdown = GameRules.levelXpBreakdown(floor + 30);

      expect(breakdown.current, 30);
      expect(breakdown.needed, GameRules.xpToAdvance(4));
    });
  });

  group('опыт за действия', () {
    int xp({
      int focusSeconds = 1500,
      TaskDifficulty difficulty = TaskDifficulty.medium,
      Mood mood = Mood.neutral,
      bool completedFully = true,
    }) =>
        GameRules.xpForSession(
          focusSeconds: focusSeconds,
          difficulty: difficulty,
          mood: mood,
          completedFully: completedFully,
        );

    test('база — минута за минуту, с поправкой на сложность', () {
      expect(xp(difficulty: TaskDifficulty.easy), 25);
      expect(xp(difficulty: TaskDifficulty.medium), 31);
      expect(xp(difficulty: TaskDifficulty.hard), 37);
    });

    test('full f0kus даёт надбавку', () {
      expect(xp(mood: Mood.fullFokus), greaterThan(xp(mood: Mood.good)));
    });

    test('оборванная сессия приносит половину, а не ноль', () {
      // Обнулять её значило бы наказывать за честную остановку — а работа
      // всё равно была.
      final full = xp();
      final aborted = xp(completedFully: false);

      expect(aborted, greaterThan(0));
      expect(aborted, lessThan(full));
      expect(aborted, (full / 2).floor());
    });

    test('сессия короче минуты опыта не приносит', () {
      expect(xp(focusSeconds: 30), 0);
      expect(xp(focusSeconds: 0), 0);
    });

    test('привычка дешевле длинной сессии, но не бесплатна', () {
      expect(GameRules.habitXp, greaterThan(0));
      expect(GameRules.habitXp, lessThan(xp()));
    });
  });

  group('HP противников', () {
    test('HP дрифера — минута фокуса за очко, с поправкой на сложность', () {
      expect(
        GameRules.drifterHp(
          plannedFocusMinutes: 25,
          difficulty: TaskDifficulty.easy,
        ),
        25,
      );
      expect(
        GameRules.drifterHp(
          plannedFocusMinutes: 25,
          difficulty: TaskDifficulty.hard,
        ),
        greaterThan(25),
      );
    });

    test('босс кратно крупнее обычного дрифера и растёт от мира к миру', () {
      final drifter = GameRules.drifterHp(
        plannedFocusMinutes: 25,
        difficulty: TaskDifficulty.hard,
      );
      expect(GameRules.bossHp(1), greaterThan(drifter * 3));
      expect(GameRules.bossHp(2), greaterThan(GameRules.bossHp(1)));
      expect(GameRules.bossHp(3), greaterThan(GameRules.bossHp(2)));
    });
  });

  group('урон', () {
    int damage({
      MapNodeKind kind = MapNodeKind.drifter,
      int focusSeconds = 1500,
      Mood mood = Mood.neutral,
      bool completedFully = true,
    }) =>
        GameRules.damageFor(
          kind: kind,
          focusSeconds: focusSeconds,
          mood: mood,
          completedFully: completedFully,
        );

    test('дрифера бьёт любая честная минута', () {
      expect(damage(), 25);
      expect(damage(mood: Mood.bad), 25);
    });

    test('оборванная сессия дрифера ранит, но не добивает', () {
      final partial = damage(completedFully: false);
      expect(partial, greaterThan(0));
      expect(partial, lessThan(damage()));
    });

    test('босса пробивает только full f0kus', () {
      final full = damage(kind: MapNodeKind.boss, mood: Mood.fullFokus);
      final ordinary = damage(kind: MapNodeKind.boss, mood: Mood.good);

      // «Значительно эффективнее» из спецификации — это не 10% разницы.
      expect(full, greaterThan(ordinary * 5));
      expect(ordinary, greaterThan(0), reason: 'работа не должна пропадать');
    });

    test('сорванная f0kus-сессия против босса урона не наносит', () {
      expect(
        damage(
          kind: MapNodeKind.boss,
          mood: Mood.fullFokus,
          completedFully: false,
        ),
        0,
      );
    });

    test('сдачи даёт только босс и только за сорванный f0kus-заход', () {
      int player({
        required MapNodeKind kind,
        required Mood mood,
        required bool completedFully,
      }) =>
          GameRules.playerDamageFor(
            kind: kind,
            mood: mood,
            completedFully: completedFully,
          );

      expect(
        player(
          kind: MapNodeKind.boss,
          mood: Mood.fullFokus,
          completedFully: false,
        ),
        1,
      );
      // Дрифер сделать с тобой ничего не может.
      expect(
        player(
          kind: MapNodeKind.drifter,
          mood: Mood.fullFokus,
          completedFully: false,
        ),
        0,
      );
      // Доведённый до конца заход не наказывается никогда.
      expect(
        player(
          kind: MapNodeKind.boss,
          mood: Mood.fullFokus,
          completedFully: true,
        ),
        0,
      );
      // Слабый заход — это не поражение, а просто слабый заход.
      expect(
        player(
          kind: MapNodeKind.boss,
          mood: Mood.good,
          completedFully: false,
        ),
        0,
      );
    });
  });

  group('восстановление недобитого дрифера', () {
    final foughtAt = DateTime(2026, 3, 1, 12);

    int hp(Duration idle, {MapNodeKind kind = MapNodeKind.drifter}) =>
        GameRules.hpAfterIdle(
          kind: kind,
          currentHp: 5,
          maxHp: 25,
          lastFoughtAt: foughtAt,
          now: foughtAt.add(idle),
        );

    test('пока к нему возвращаются — рана остаётся', () {
      expect(hp(const Duration(hours: 1)), 5);
      expect(hp(const Duration(days: 1, hours: 23)), 5);
    });

    test('после долгого простоя дрифер восстанавливается целиком', () {
      expect(hp(const Duration(days: 2, hours: 1)), 25);
    });

    test('босс от простоя не лечится — только от того, что ты сдался', () {
      expect(hp(const Duration(days: 30), kind: MapNodeKind.boss), 5);
    });

    test('нетронутый дрифер и дрифер без истории боёв не меняются', () {
      expect(
        GameRules.hpAfterIdle(
          kind: MapNodeKind.drifter,
          currentHp: 25,
          maxHp: 25,
          lastFoughtAt: foughtAt,
          now: foughtAt.add(const Duration(days: 10)),
        ),
        25,
      );
      expect(
        GameRules.hpAfterIdle(
          kind: MapNodeKind.drifter,
          currentHp: 5,
          maxHp: 25,
          lastFoughtAt: null,
          now: foughtAt,
        ),
        5,
      );
    });
  });

  group('карта', () {
    test('в каждом мире ровно один босс, и он последний', () {
      for (var world = 1; world <= GameRules.worldCount; world++) {
        for (var pos = 1; pos < GameRules.nodesPerWorld; pos++) {
          expect(pos, lessThan(GameRules.nodesPerWorld));
        }
      }
      expect(GameRules.nodesPerWorld, GameRules.drifterNodesPerWorld + 1);
    });

    test('id узла устойчив и уникален', () {
      final ids = <String>{};
      for (var world = 1; world <= GameRules.worldCount; world++) {
        for (var pos = 1; pos <= GameRules.nodesPerWorld; pos++) {
          expect(ids.add(GameRules.nodeId(world, pos)), isTrue);
        }
      }
      expect(ids, hasLength(GameRules.worldCount * GameRules.nodesPerWorld));
      expect(GameRules.nodeId(2, 3), 'w2n3');
    });

    test('соседние узлы занимают разные существа', () {
      // Три подряд одинаковых силуэта читались бы как «один и тот же враг
      // трижды», а не как путь.
      for (var world = 1; world <= GameRules.worldCount; world++) {
        for (var pos = 1; pos < GameRules.drifterNodesPerWorld; pos++) {
          expect(
            GameRules.speciesFor(world, pos),
            isNot(GameRules.speciesFor(world, pos + 1)),
          );
        }
      }
    });

    test('стадии аватара переключаются по уровню и не откатываются', () {
      expect(GameRules.avatarStageForLevel(1), 0);
      expect(GameRules.avatarStageForLevel(3), 1);
      expect(GameRules.avatarStageForLevel(6), 2);
      expect(GameRules.avatarStageForLevel(10), 3);

      var previous = 0;
      for (var level = 1; level <= 40; level++) {
        final stage = GameRules.avatarStageForLevel(level);
        expect(stage, greaterThanOrEqualTo(previous));
        previous = stage;
      }
    });
  });

  group('ступени и звания персонажа', () {
    test('ступень вида меняется ровно на объявленных уровнях', () {
      // Таблица записана здесь заново, руками, а не выведена из
      // `avatarStageLevels`: тест, считающий по той же формуле, что и код,
      // не поймает изменение формулы — он его повторит.
      const expected = <int, int>{
        1: 0, 2: 0,
        3: 1, 4: 1, 5: 1,
        6: 2, 7: 2, 8: 2, 9: 2,
        10: 3, 11: 3, 14: 3,
        15: 4, 16: 4, 20: 4,
        21: 5, 30: 5, 99: 5,
      };
      expected.forEach((level, stage) {
        expect(
          GameRules.avatarStageForLevel(level),
          stage,
          reason: 'уровень $level',
        );
      });
    });

    test('ступень никогда не откатывается назад', () {
      var previous = 0;
      for (var level = 1; level <= 60; level++) {
        final stage = GameRules.avatarStageForLevel(level);
        expect(stage, greaterThanOrEqualTo(previous), reason: 'уровень $level');
        expect(stage, lessThan(GameRules.avatarStageCount));
        previous = stage;
      }
    });

    test('следующая ступень называется честно, а на последней — молчит', () {
      expect(GameRules.nextAvatarStageLevel(1), 3);
      expect(GameRules.nextAvatarStageLevel(3), 6);
      expect(GameRules.nextAvatarStageLevel(9), 10);
      expect(GameRules.nextAvatarStageLevel(14), 15);
      expect(GameRules.nextAvatarStageLevel(20), 21);
      // Дальше ступеней нет, и обещать их нечем.
      expect(GameRules.nextAvatarStageLevel(21), isNull);
      expect(GameRules.nextAvatarStageLevel(80), isNull);
    });

    test('звание меняется чаще, чем внешний вид', () {
      // Смысл двух лестниц именно в этом: между двумя перерисовками аватара
      // человек всё равно должен видеть, что продвинулся.
      final stageChanges = <int>{};
      final rankChanges = <int>{};
      for (var level = 2; level <= 30; level++) {
        if (GameRules.avatarStageForLevel(level) !=
            GameRules.avatarStageForLevel(level - 1)) {
          stageChanges.add(level);
        }
        if (GameRules.rankForLevel(level) != GameRules.rankForLevel(level - 1)) {
          rankChanges.add(level);
        }
      }
      expect(rankChanges.length, greaterThan(stageChanges.length));
    });

    test('звание по уровню — по объявленной таблице', () {
      const expected = <int, int>{
        1: 0, 2: 0,
        3: 1, 4: 1,
        5: 2, 7: 2,
        8: 3, 10: 3,
        11: 4, 14: 4,
        15: 5, 19: 5,
        20: 6, 26: 6,
        27: 7, 50: 7,
      };
      expected.forEach((level, rank) {
        expect(GameRules.rankForLevel(level), rank, reason: 'уровень $level');
      });
      expect(GameRules.rankCount, 8);
    });
  });

  group('полоска HP на экране боя', () {
    test('пустая сессия ничего не отнимает', () {
      expect(
        GameRules.previewHp(
          kind: MapNodeKind.drifter,
          currentHp: 40,
          focusSeconds: 0,
          mood: Mood.neutral,
        ),
        40,
      );
    });

    test('HP убывает минута за минутой и не уходит ниже нуля', () {
      int hpAfter(int minutes) => GameRules.previewHp(
            kind: MapNodeKind.drifter,
            currentHp: 25,
            focusSeconds: minutes * 60,
            mood: Mood.neutral,
          );

      expect(hpAfter(1), 24);
      expect(hpAfter(10), 15);
      expect(hpAfter(25), 0);
      // Пересидел — полоска стоит на нуле, а не уходит в минус.
      expect(hpAfter(90), 0);
    });

    test('показанное совпадает с тем, что будет записано', () {
      // Главное требование к полоске: она обещает ровно тот урон, который
      // доведённая до конца сессия и нанесёт. Полоска, живущая по своей
      // формуле, — худший вид украшения: правдоподобное, но врущее.
      for (final minutes in [1, 7, 25, 50]) {
        for (final mood in Mood.values) {
          for (final kind in MapNodeKind.values) {
            final damage = GameRules.damageFor(
              kind: kind,
              focusSeconds: minutes * 60,
              mood: mood,
              completedFully: true,
            );
            expect(
              GameRules.previewHp(
                kind: kind,
                currentHp: 500,
                focusSeconds: minutes * 60,
                mood: mood,
              ),
              500 - damage,
              reason: '$kind, $mood, $minutes мин',
            );
          }
        }
      }
    });

    test('босса без full f0kus полоска почти не двигает', () {
      final scratch = GameRules.previewHp(
        kind: MapNodeKind.boss,
        currentHp: 120,
        focusSeconds: 40 * 60,
        mood: Mood.neutral,
      );
      final real = GameRules.previewHp(
        kind: MapNodeKind.boss,
        currentHp: 120,
        focusSeconds: 40 * 60,
        mood: Mood.fullFokus,
      );
      // Разница должна быть видна сразу, а не «на пару процентов».
      expect(120 - scratch, 10);
      expect(120 - real, 80);
    });

    test('доля для полоски держится в границах 0..1', () {
      for (final minutes in [0, 3, 30, 300]) {
        final fraction = GameRules.previewHpFraction(
          kind: MapNodeKind.drifter,
          currentHp: 30,
          maxHp: 30,
          focusSeconds: minutes * 60,
          mood: Mood.good,
        );
        expect(fraction, inInclusiveRange(0.0, 1.0));
      }
      // Вырожденный узел не роняет экран делением на ноль.
      expect(
        GameRules.previewHpFraction(
          kind: MapNodeKind.drifter,
          currentHp: 0,
          maxHp: 0,
          focusSeconds: 600,
          mood: Mood.good,
        ),
        0,
      );
    });
  });

  group('состав миров', () {
    test('первый мир остался тем же, что и до расширения', () {
      // У людей с уже начатой партией узлы первого мира не должны сменить
      // обитателей: индексы видов лежат в базе, и «просто переставить»
      // означало бы, что вчерашний Морок сегодня стал кем-то другим.
      expect(GameRules.speciesFor(1, 1), DrifterSpecies.loom);
      expect(GameRules.speciesFor(1, 2), DrifterSpecies.buzz);
      expect(GameRules.speciesFor(1, 3), DrifterSpecies.creep);
    });

    test('индексы первых трёх видов не сдвинулись', () {
      // То же требование, но со стороны хранилища: в БД лежит именно индекс.
      expect(DrifterSpecies.buzz.index, 0);
      expect(DrifterSpecies.creep.index, 1);
      expect(DrifterSpecies.loom.index, 2);
      expect(DrifterSpecies.fromIndex(2), DrifterSpecies.loom);
    });

    test('на каждый узел каждого мира кто-то назначен', () {
      for (var world = 1; world <= GameRules.worldCount; world++) {
        for (var position = 1;
            position <= GameRules.drifterNodesPerWorld;
            position++) {
          expect(
            DrifterSpecies.values,
            contains(GameRules.speciesFor(world, position)),
          );
        }
      }
      // Запрос за пределами реализованных миров не роняет карту.
      expect(
        DrifterSpecies.values,
        contains(GameRules.speciesFor(99, 7)),
      );
    });
  });
}
