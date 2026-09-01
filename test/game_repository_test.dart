import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/data/local/database.dart';
import 'package:texfi_fokus/data/repositories/game_repository_impl.dart';
import 'package:texfi_fokus/domain/entities/game_entities.dart';
import 'package:texfi_fokus/domain/entities/game_rules.dart';
import 'package:texfi_fokus/domain/entities/mood.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';

/// Правила игры проверяются на настоящей базе: последовательность
/// разблокировки, недобитые дриферы и поражение от босса — это состояние,
/// которое живёт между запусками, и ошибиться в нём тихо очень легко.
void main() {
  late AppDatabase db;
  late GameRepositoryImpl game;
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 3, 1, 12);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    game = GameRepositoryImpl(db, now: () => now);
  });

  tearDown(() => db.close());

  Future<EncounterResult> session({
    int minutes = 25,
    Mood mood = Mood.neutral,
    bool completedFully = true,
    TaskDifficulty difficulty = TaskDifficulty.medium,
  }) =>
      game.applySession(
        focusSeconds: minutes * 60,
        difficulty: difficulty,
        mood: mood,
        completedFully: completedFully,
      );

  /// Добивает текущий узел, чем бы он ни был. Для боссов — только f0kus.
  Future<void> clearCurrentNode() async {
    for (var guard = 0; guard < 60; guard++) {
      final node = await game.currentNode();
      if (node == null) return;
      final before = node.id;
      await session(minutes: 120, mood: Mood.fullFokus);
      final after = await game.currentNode();
      if (after == null || after.id != before) return;
    }
    fail('узел не закрывается — вероятно, урон не проходит');
  }

  group('выключенный режим', () {
    test('ничего не начисляет и не заводит карту', () async {
      final result = await session();

      expect(result.outcome, EncounterOutcome.none);
      expect(result.xpGained, 0);
      expect((await game.progress()).totalXp, 0);
      expect(await game.mapNodes(), isEmpty);
    });
  });

  group('включение режима', () {
    setUp(() => game.setEnabled(true));

    test('карта строится один раз и последовательно', () async {
      final nodes = await game.mapNodes();

      expect(
        nodes,
        hasLength(GameRules.worldCount * GameRules.nodesPerWorld),
      );

      // Открыт ровно один узел — самый первый.
      final current = nodes.where((n) => n.status == MapNodeStatus.current);
      expect(current, hasLength(1));
      expect(current.single.id, GameRules.nodeId(1, 1));

      // Всё остальное заперто.
      expect(
        nodes.where((n) => n.status == MapNodeStatus.locked),
        hasLength(nodes.length - 1),
      );

      // Босс стоит в конце каждого мира и нигде больше.
      for (final node in nodes) {
        expect(node.isBoss, node.position == GameRules.nodesPerWorld);
      }
    });

    test('повторное включение карту не пересоздаёт', () async {
      await session(minutes: 10);
      final hpAfterFight = (await game.currentNode())!.currentHp;

      await game.setEnabled(false);
      await game.setEnabled(true);

      expect((await game.currentNode())!.currentHp, hpAfterFight);
    });

    test('выключение сохраняет и опыт, и карту', () async {
      await session(minutes: 30);
      final xp = (await game.progress()).totalXp;
      final nodeId = (await game.currentNode())!.id;
      expect(xp, greaterThan(0));

      await game.setEnabled(false);

      // Данные на месте — скрывается только интерфейс.
      expect((await game.progress()).totalXp, xp);
      expect(await game.mapNodes(), isNotEmpty);

      await game.setEnabled(true);
      expect((await game.currentNode())!.id, nodeId);
      expect((await game.progress()).totalXp, xp);
    });
  });

  group('обычные дриферы', () {
    setUp(() => game.setEnabled(true));

    test('короткая сессия ранит, но не добивает', () async {
      final node = await game.currentNode();
      final result = await session(minutes: 5);

      expect(result.outcome, EncounterOutcome.damaged);
      expect(result.node!.currentHp, node!.currentHp - 5);
      expect(result.node!.wounded, isTrue);
      // Следующий узел ещё заперт.
      expect((await game.currentNode())!.id, node.id);
    });

    test('недобитый дрифер добивается следующей сессией той же задачи',
        () async {
      await session(minutes: 10);
      final wounded = await game.currentNode();
      expect(wounded!.wounded, isTrue);

      final finish = await session(minutes: 60);

      expect(finish.outcome, EncounterOutcome.drifterDefeated);
      expect((await game.progress()).drifterKills, 1);
    });

    test('победа открывает ровно следующий узел', () async {
      await session(minutes: 120);

      final nodes = await game.mapNodes();
      expect(nodes.first.status, MapNodeStatus.completed);
      expect(
        nodes.where((n) => n.status == MapNodeStatus.current).single.id,
        GameRules.nodeId(1, 2),
      );
      // Через один — по-прежнему заперт: карта идёт по порядку.
      expect(
        nodes.firstWhere((n) => n.id == GameRules.nodeId(1, 3)).status,
        MapNodeStatus.locked,
      );
    });

    test('после долгого простоя недобитый дрифер восстанавливается', () async {
      await session(minutes: 10);
      final wounded = (await game.currentNode())!;
      expect(wounded.currentHp, lessThan(wounded.maxHp));

      // Возвращаемся через три дня и бьём на одно очко.
      now = now.add(const Duration(days: 3));
      await session(minutes: 1);

      final healed = (await game.currentNode())!;
      // Лечение произошло до удара, поэтому HP — почти полное, а не то, что
      // осталось три дня назад.
      expect(healed.currentHp, healed.maxHp - 1);
    });
  });

  group('боссы', () {
    setUp(() async {
      await game.setEnabled(true);
      // Расчищаем дорогу до первого босса.
      for (var i = 0; i < GameRules.drifterNodesPerWorld; i++) {
        await clearCurrentNode();
      }
    });

    test('до босса дошли, и он именно босс', () async {
      final node = await game.currentNode();
      expect(node!.isBoss, isTrue);
      expect(node.world, 1);
      expect(node.maxHp, GameRules.bossHp(1));
      expect(node.playerHp, GameRules.bossPlayerHp);
    });

    test('обычная сессия царапает босса, f0kus — бьёт', () async {
      final ordinary = await session(minutes: 40, mood: Mood.good);
      final focused = await session(minutes: 40, mood: Mood.fullFokus);

      expect(focused.damageDealt, greaterThan(ordinary.damageDealt * 5));
    });

    test('сорванный f0kus-заход стоит очка выносливости', () async {
      final before = (await game.currentNode())!.playerHp;
      await session(minutes: 10, mood: Mood.fullFokus, completedFully: false);

      expect((await game.currentNode())!.playerHp, before - 1);
    });

    test('исчерпав выносливость, теряешь бой целиком — босс как новый',
        () async {
      // Сначала прилично разбиваем босса.
      await session(minutes: 40, mood: Mood.fullFokus);
      final hurt = (await game.currentNode())!;
      expect(hurt.currentHp, lessThan(hurt.maxHp));

      EncounterResult? last;
      for (var i = 0; i < GameRules.bossPlayerHp; i++) {
        last = await session(
          minutes: 5,
          mood: Mood.fullFokus,
          completedFully: false,
        );
      }

      expect(last!.outcome, EncounterOutcome.playerDefeated);

      final reset = (await game.currentNode())!;
      // Босс восстановился полностью, а выносливость вернулась — бой
      // начинается заново, а не превращается в тупик.
      expect(reset.currentHp, reset.maxHp);
      expect(reset.playerHp, GameRules.bossPlayerHp);
      expect(reset.status, MapNodeStatus.current);
    });

    test('поражение не отменяет заработанный опыт', () async {
      final before = (await game.progress()).totalXp;
      for (var i = 0; i < GameRules.bossPlayerHp; i++) {
        await session(
          minutes: 20,
          mood: Mood.fullFokus,
          completedFully: false,
        );
      }

      // Часы всё равно были отсижены — забирать за них опыт было бы
      // наказанием за попытку.
      expect((await game.progress()).totalXp, greaterThan(before));
    });

    test('победа над боссом открывает следующий мир', () async {
      await clearCurrentNode();

      expect((await game.progress()).bossKills, 1);
      final current = await game.currentNode();
      expect(current!.world, 2);
      expect(current.position, 1);
      expect(current.isBoss, isFalse);
    });
  });

  group('опыт', () {
    setUp(() => game.setEnabled(true));

    test('привычка начисляет опыт, но урона не наносит', () async {
      final node = await game.currentNode();
      final result = await game.applyHabitCompletion();

      expect(result.xpGained, GameRules.habitXp);
      expect(result.damageDealt, 0);
      expect((await game.currentNode())!.currentHp, node!.currentHp);
    });

    test('взятый уровень сообщается наверх один раз', () async {
      // Первого уровня хватает на 50 опыта — добираем его сессиями.
      EncounterResult? levelUp;
      for (var i = 0; i < 5; i++) {
        final result = await session(minutes: 20);
        levelUp ??= result.leveledUpTo != null ? result : null;
      }

      expect(levelUp, isNotNull);
      expect(levelUp!.leveledUpTo, greaterThan(1));

      final progress = await game.progress();
      expect(progress.level, GameRules.levelForXp(progress.totalXp));
    });

    test('карта пройдена — опыт всё равно капает', () async {
      for (var i = 0;
          i < GameRules.worldCount * GameRules.nodesPerWorld;
          i++) {
        await clearCurrentNode();
      }
      expect(await game.currentNode(), isNull);

      final before = (await game.progress()).totalXp;
      final result = await session(minutes: 30);

      expect(result.xpGained, greaterThan(0));
      expect((await game.progress()).totalXp, greaterThan(before));
    });
  });

  group('сброс', () {
    test('возвращает карту в начало и обнуляет опыт', () async {
      await game.setEnabled(true);
      await session(minutes: 120);
      expect((await game.progress()).totalXp, greaterThan(0));

      await game.resetProgress();

      expect((await game.progress()).totalXp, 0);
      expect((await game.currentNode())!.id, GameRules.nodeId(1, 1));
    });
  });
}
