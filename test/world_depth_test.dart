import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/core/theme/app_palettes.dart';
import 'package:texfi_fokus/data/local/database.dart';
import 'package:texfi_fokus/data/repositories/game_repository_impl.dart';
import 'package:texfi_fokus/domain/entities/game_entities.dart';
import 'package:texfi_fokus/domain/entities/game_rules.dart';
import 'package:texfi_fokus/domain/entities/mood.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';
import 'package:texfi_fokus/l10n/app_localizations.dart';
import 'package:texfi_fokus/l10n/app_localizations_en.dart';
import 'package:texfi_fokus/presentation/game/game_labels.dart';
import 'package:texfi_fokus/presentation/game/world_intro_overlay.dart';
import 'package:texfi_fokus/presentation/game/world_style.dart';

/// Три добавления этого прохода — перекличка мира с категорией задачи,
/// память дрифера о брошенных заходах и сквозная нить из обрывков — проверяются
/// здесь вместе, потому что у них общее требование, и оно важнее любого из них
/// по отдельности: ни одно не смеет менять то, как считаются урон, HP и ход
/// карты. Надстройка, которая тихо подвинула бы механику, — ровно та ошибка,
/// ради невозможности которой игровой слой вообще устроен отдельно.
void main() {
  group('перекличка мира с категорией', () {
    test('у каждого реализованного мира есть своя категория', () {
      final seen = <TaskCategory>{};
      for (var world = 1; world <= GameRules.worldCount; world++) {
        final category = GameRules.affinityOf(world);
        // «Прочее» — значение по умолчанию, а не выбор: мир, которому досталось
        // оно, на деле не связан ни с чем.
        expect(category, isNot(TaskCategory.other));
        seen.add(category);
      }
      // Два мира с одной категорией сделали бы карту менее осмысленной, а не
      // более: смысл ровно в том, что места разные.
      expect(seen, hasLength(GameRules.worldCount));
    });

    test('совпадение категории засчитывается, «прочее» — никогда', () {
      final first = GameRules.affinityOf(1);
      expect(GameRules.resonates(world: 1, category: first), isTrue);
      expect(
        GameRules.resonates(world: 1, category: TaskCategory.other),
        isFalse,
      );
      expect(
        GameRules.resonates(world: 1, category: GameRules.affinityOf(2)),
        isFalse,
      );
    });

    test('запрос про ещё не написанный мир не роняет правила', () {
      expect(TaskCategory.values, contains(GameRules.affinityOf(99)));
      expect(GameRules.worldAt(99), same(GameRules.worlds.last));
    });
  });

  group('память дрифера', () {
    test('до порога дрифер молчит', () {
      for (var i = 0; i < GameRules.drifterMemoryThreshold; i++) {
        expect(GameRules.drifterMemoryTier(i), 0);
      }
    });

    test('ступени идут по возрастанию и не перескакивают', () {
      expect(GameRules.drifterMemoryTier(GameRules.drifterMemoryThreshold), 1);
      expect(
        GameRules.drifterMemoryTier(GameRules.drifterMemoryDeepThreshold),
        2,
      );
      expect(GameRules.drifterMemoryTier(999), 2);
    });

    test('босс не помнит: у него уже есть свой способ вернуть к себе', () {
      const boss = MapNodeEntity(
        id: 'w1n4',
        world: 1,
        position: 4,
        kind: MapNodeKind.boss,
        status: MapNodeStatus.current,
        species: DrifterSpecies.loom,
        maxHp: 120,
        currentHp: 40,
        playerHp: 2,
        abandonedCount: 9,
      );
      expect(boss.memoryTier, 0);
    });
  });

  group('обрывки', () {
    test('до первой победы не открыт ни один', () {
      expect(GameRules.unlockedLoreFragments(0), 0);
      expect(GameRules.unlockedLoreFragments(-3), 0);
    });

    test('каждый босс открывает ровно один', () {
      for (var kills = 1; kills < GameRules.worldCount; kills++) {
        expect(GameRules.unlockedLoreFragments(kills), kills);
      }
    });

    test('последний придерживается до полного прохождения карты', () {
      // На предпоследнем боссе последнего обрывка ещё нет.
      expect(
        GameRules.unlockedLoreFragments(GameRules.worldCount - 1),
        lessThan(GameRules.loreFragmentCount),
      );
      // И появляется он ровно тогда, когда пройдены все миры.
      expect(
        GameRules.unlockedLoreFragments(GameRules.worldCount),
        GameRules.loreFragmentCount,
      );
      expect(
        GameRules.unlockedLoreFragments(GameRules.worldCount + 5),
        GameRules.loreFragmentCount,
      );
    });

    test('обрывков ровно по одному на мир плюс последний', () {
      expect(GameRules.loreFragmentCount, GameRules.worldCount + 1);
    });
  });

  group('задел на четвёртый мир', () {
    final AppLocalizations l10n = AppLocalizationsEn();

    test('у каждого написанного мира своё имя, босс и эпиграф', () {
      final names = <String>{};
      final bosses = <String>{};
      final epigraphs = <String>{};
      for (var world = 1; world <= GameRules.worldCount; world++) {
        names.add(worldName(l10n, world));
        bosses.add(bossLabel(l10n, world));
        expect(bossFlavor(l10n, world), isNotNull);
        final epigraph = worldEpigraph(l10n, world);
        expect(epigraph, isNotNull);
        epigraphs.add(epigraph!);
      }
      expect(names, hasLength(GameRules.worldCount));
      expect(bosses, hasLength(GameRules.worldCount));
      expect(epigraphs, hasLength(GameRules.worldCount));
    });

    test('ненаписанный мир не присваивает себе чужое имя', () {
      // Это и есть цена `_ =>` в подписях: добавив четвёртый мир в
      // `GameRules.worlds`, автор получил бы мир с именем и боссом третьего,
      // и увидеть это можно было бы только глазами на экране.
      const unwritten = 4;
      expect(worldName(l10n, unwritten), isNot(worldName(l10n, 3)));
      expect(bossLabel(l10n, unwritten), isNot(bossLabel(l10n, 3)));
      expect(bossFlavor(l10n, unwritten), isNull);
      expect(worldEpigraph(l10n, unwritten), isNull);
    });

    test('оформление ненаписанного мира не падает и остаётся в палитре', () {
      const colors = AppPalettes.dark;
      // Мир за пределами написанных берёт нейтральный акцент, а не чужой тон.
      expect(WorldStyle.tint(colors, 99), colors.accent);
      expect(WorldStyle.density(99), greaterThan(0));
      expect(
        WorldAtmosphereKind.values,
        contains(WorldStyle.atmosphere(99)),
      );
    });

    test('у каждого написанного мира свой тон и свой характер фона', () {
      final tints = <int>{};
      final kinds = <WorldAtmosphereKind>{};
      for (var world = 1; world <= GameRules.worldCount; world++) {
        tints.add(WorldStyle.tint(AppPalettes.dark, world).toARGB32());
        kinds.add(WorldStyle.atmosphere(world));
      }
      expect(tints, hasLength(GameRules.worldCount));
      expect(kinds, hasLength(GameRules.worldCount));
    });
  });

  group('на настоящей базе', () {
    late AppDatabase db;
    late GameRepositoryImpl game;
    late DateTime now;

    setUp(() async {
      now = DateTime(2026, 3, 1, 12);
      db = AppDatabase.forTesting(NativeDatabase.memory());
      game = GameRepositoryImpl(db, now: () => now);
      await game.setEnabled(true);
    });

    tearDown(() => db.close());

    Future<EncounterResult> session({
      int minutes = 5,
      bool completedFully = true,
      TaskCategory category = TaskCategory.other,
    }) =>
        game.applySession(
          focusSeconds: minutes * 60,
          difficulty: TaskDifficulty.medium,
          mood: Mood.neutral,
          completedFully: completedFully,
          category: category,
        );

    test('брошенный заход запоминается, доведённый — нет', () async {
      final first = await session(completedFully: false);
      expect(first.node!.abandonedCount, 1);

      final second = await session(completedFully: false);
      expect(second.node!.abandonedCount, 2);
      expect(second.node!.memoryTier, 1);

      // Доведённая до конца сессия, не добившая дрифера, счётчик не трогает:
      // считаются брошенные заходы, а не медленные.
      final third = await session(minutes: 1);
      expect(third.node!.abandonedCount, 2);
    });

    test('счётчик не влияет ни на урон, ни на HP', () async {
      // Один и тот же заход на «свежем» дрифере и на дрифере с историей
      // должен снимать одинаково: память — это текст, а не механика.
      final fresh = await session(minutes: 4, completedFully: false);
      final damageFresh = fresh.damageDealt;

      for (var i = 0; i < 5; i++) {
        await session(minutes: 1, completedFully: false);
      }
      final remembered = await session(minutes: 4, completedFully: false);

      expect(remembered.node!.memoryTier, 2);
      expect(remembered.damageDealt, damageFresh);
      expect(remembered.node!.maxHp, fresh.node!.maxHp);
    });

    test('память переживает перезапуск: она в базе, а не в памяти процесса',
        () async {
      await session(completedFully: false);
      await session(completedFully: false);

      final reopened = GameRepositoryImpl(db, now: () => now);
      final node = await reopened.currentNode();
      expect(node!.abandonedCount, 2);
      expect(node.memoryTier, 1);
    });

    test('совпавшая категория добавляет надбавку и называет причину', () async {
      final matching = GameRules.affinityOf(1);

      final plain = await session(category: TaskCategory.other);
      final resonant = await session(category: matching);

      expect(plain.resonated, isFalse);
      expect(resonant.resonated, isTrue);
      expect(
        resonant.xpGained - plain.xpGained,
        GameRules.resonanceBonusXp,
      );
    });

    test('надбавка не трогает урон — только опыт', () async {
      final matching = GameRules.affinityOf(1);
      final plain = await session(category: TaskCategory.other);
      final resonant = await session(category: matching);
      expect(resonant.damageDealt, plain.damageDealt);
    });

    test('пустая сессия не получает надбавку ни за что', () async {
      final empty = await session(minutes: 0, category: GameRules.affinityOf(1));
      expect(empty.xpGained, 0);
      expect(empty.resonated, isFalse);
    });

    test('в выключенном режиме не происходит вообще ничего', () async {
      await game.setEnabled(false);
      final result = await session(
        completedFully: false,
        category: GameRules.affinityOf(1),
      );
      expect(result.outcome, EncounterOutcome.none);
      expect(result.xpGained, 0);
      expect(result.resonated, isFalse);
    });
  });
}
