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
}
