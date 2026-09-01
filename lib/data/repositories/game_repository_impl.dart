import 'package:drift/drift.dart';

import '../../domain/entities/game_entities.dart';
import '../../domain/entities/game_rules.dart';
import '../../domain/entities/mood.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/repositories/game_repository.dart';
import '../local/database.dart';
import '../local/tables/game_tables.dart';

/// Игровой слой поверх обычного трекера.
///
/// Ключевое ограничение, ради которого всё устроено именно так: этот класс
/// пишет только в свои три таблицы. Сессии, привычки и веса рекомендаций он
/// читает через уже посчитанные результаты, которые ему передают, и никогда
/// не открывает их на запись. Выключенный игровой режим не должен менять в
/// обычном трекере ни одной цифры — а лучший способ это гарантировать —
/// просто не иметь такой возможности.
class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl(this._db, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final AppDatabase _db;

  /// Подменяется в тестах: восстановление недобитого дрифера завязано на
  /// «сколько прошло», и ждать двое суток в тесте невозможно.
  final DateTime Function() _now;

  // --- Настройки режима ---

  @override
  Stream<bool> watchEnabled() => _db
      .select(_db.gameSettings)
      .watchSingleOrNull()
      .map((row) => row?.enabled ?? false);

  @override
  Future<bool> isEnabled() async {
    final row = await _db.select(_db.gameSettings).getSingleOrNull();
    return row?.enabled ?? false;
  }

  @override
  Future<void> setEnabled(bool value) async {
    // Только флаг. Ни карта, ни опыт здесь не трогаются — в этом и смысл:
    // выключить игру должно быть так же безопасно, как свернуть её.
    await _db.into(_db.gameSettings).insertOnConflictUpdate(
          GameSettingsCompanion.insert(
            id: const Value(gameSingletonId),
            enabled: Value(value),
          ),
        );
    if (value) await ensureInitialized();
  }

  // --- Прогресс ---

  PlayerProgressEntity _progressOf(PlayerProgressData? row) =>
      PlayerProgressEntity(
        totalXp: row?.totalXp ?? 0,
        drifterKills: row?.drifterKills ?? 0,
        bossKills: row?.bossKills ?? 0,
      );

  @override
  Stream<PlayerProgressEntity> watchProgress() =>
      _db.select(_db.playerProgress).watchSingleOrNull().map(_progressOf);

  @override
  Future<PlayerProgressEntity> progress() async =>
      _progressOf(await _db.select(_db.playerProgress).getSingleOrNull());

  Future<void> _writeProgress(PlayerProgressEntity progress) async {
    await _db.into(_db.playerProgress).insertOnConflictUpdate(
          PlayerProgressCompanion.insert(
            id: const Value(gameSingletonId),
            totalXp: Value(progress.totalXp),
            drifterKills: Value(progress.drifterKills),
            bossKills: Value(progress.bossKills),
            updatedAt: Value(_now()),
          ),
        );
  }

  // --- Карта ---

  MapNodeEntity _nodeOf(MapNode row) => MapNodeEntity(
        id: row.id,
        world: row.world,
        position: row.position,
        kind: MapNodeKind.fromIndex(row.kind),
        status: MapNodeStatus.fromIndex(row.status),
        species: DrifterSpecies.fromIndex(row.species),
        maxHp: row.maxHp,
        currentHp: row.currentHp,
        playerHp: row.playerHp,
        lastFoughtAt: row.lastFoughtAt,
      );

  SimpleSelectStatement<$MapNodesTable, MapNode> _orderedNodes() =>
      _db.select(_db.mapNodes)
        ..orderBy([
          (t) => OrderingTerm(expression: t.world),
          (t) => OrderingTerm(expression: t.position),
        ]);

  @override
  Stream<List<MapNodeEntity>> watchMap() =>
      _orderedNodes().watch().map((rows) => rows.map(_nodeOf).toList());

  @override
  Future<List<MapNodeEntity>> mapNodes() async =>
      (await _orderedNodes().get()).map(_nodeOf).toList();

  @override
  Future<MapNodeEntity?> currentNode() async {
    final row = await (_db.select(_db.mapNodes)
          ..where((t) => t.status.equals(MapNodeStatus.current.index))
          ..orderBy([
            (t) => OrderingTerm(expression: t.world),
            (t) => OrderingTerm(expression: t.position),
          ])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _nodeOf(row);
  }

  /// HP по умолчанию для узла, который ещё ни разу не открывали.
  ///
  /// У обычного дрифера оно уточняется в момент боя под конкретную задачу
  /// (длительность сессии и сложность), у босса фиксировано с самого начала:
  /// босса нельзя облегчить, выбрав задачу попроще.
  int _initialHp(MapNodeKind kind, int world) => switch (kind) {
        MapNodeKind.boss => GameRules.bossHp(world),
        MapNodeKind.drifter => GameRules.drifterHp(
            plannedFocusMinutes: 25,
            difficulty: TaskDifficulty.medium,
          ),
      };

  @override
  Future<void> ensureInitialized() async {
    final existing = await _db.select(_db.mapNodes).get();
    if (existing.isNotEmpty) return;

    // Первый узел первого мира открыт, всё остальное заперто: карта
    // разблокируется строго последовательно.
    final rows = <MapNodesCompanion>[];
    for (var world = 1; world <= GameRules.worldCount; world++) {
      for (var position = 1; position <= GameRules.nodesPerWorld; position++) {
        final isBoss = position == GameRules.nodesPerWorld;
        final kind = isBoss ? MapNodeKind.boss : MapNodeKind.drifter;
        final hp = _initialHp(kind, world);
        rows.add(
          MapNodesCompanion.insert(
            id: GameRules.nodeId(world, position),
            world: world,
            position: position,
            kind: kind.index,
            status: (world == 1 && position == 1)
                ? MapNodeStatus.current.index
                : MapNodeStatus.locked.index,
            species: Value(GameRules.speciesFor(world, position).index),
            maxHp: hp,
            currentHp: hp,
            playerHp: Value(isBoss ? GameRules.bossPlayerHp : 0),
          ),
        );
      }
    }

    await _db.batch((batch) => batch.insertAll(_db.mapNodes, rows));

    // Строку прогресса заводим здесь же, чтобы экран персонажа не разбирался
    // с её отсутствием.
    await _db.into(_db.playerProgress).insertOnConflictUpdate(
          PlayerProgressCompanion.insert(
            id: const Value(gameSingletonId),
            updatedAt: Value(_now()),
          ),
        );
  }

  Future<void> _writeNode(MapNodeEntity node) async {
    await (_db.update(_db.mapNodes)..where((t) => t.id.equals(node.id))).write(
      MapNodesCompanion(
        status: Value(node.status.index),
        maxHp: Value(node.maxHp),
        currentHp: Value(node.currentHp),
        playerHp: Value(node.playerHp),
        lastFoughtAt: Value(node.lastFoughtAt),
      ),
    );
  }

  /// Открывает следующий узел после побеждённого.
  ///
  /// Внутри мира — соседний, на границе миров — первый узел следующего.
  /// Последний босс последнего мира не открывает ничего: карта пройдена.
  Future<void> _unlockNext(MapNodeEntity defeated) async {
    final nextId = defeated.position < GameRules.nodesPerWorld
        ? GameRules.nodeId(defeated.world, defeated.position + 1)
        : GameRules.nodeId(defeated.world + 1, 1);

    final next = await (_db.select(_db.mapNodes)
          ..where((t) => t.id.equals(nextId)))
        .getSingleOrNull();
    if (next == null) return;

    // Уже пройденный узел заново текущим не делаем: иначе возврат на карту
    // после последнего босса воскрешал бы её начало.
    if (MapNodeStatus.fromIndex(next.status) == MapNodeStatus.completed) return;

    await (_db.update(_db.mapNodes)..where((t) => t.id.equals(nextId)))
        .write(MapNodesCompanion(status: Value(MapNodeStatus.current.index)));
  }

  // --- Заходы ---

  @override
  Future<EncounterResult> applySession({
    required int focusSeconds,
    required TaskDifficulty difficulty,
    required Mood mood,
    required bool completedFully,
  }) async {
    if (!await isEnabled()) return const EncounterResult.none();
    await ensureInitialized();

    final xp = GameRules.xpForSession(
      focusSeconds: focusSeconds,
      difficulty: difficulty,
      mood: mood,
      completedFully: completedFully,
    );

    final node = await currentNode();
    if (node == null) {
      // Карта пройдена целиком — опыт всё равно начисляем: приложением
      // продолжают пользоваться и после последнего босса.
      final levelUp = await _awardXp(xp);
      return EncounterResult(
        outcome: xp > 0 ? EncounterOutcome.damaged : EncounterOutcome.none,
        xpGained: xp,
        damageDealt: 0,
        leveledUpTo: levelUp,
      );
    }

    // Недобитый дрифер, к которому давно не возвращались, успел
    // восстановиться. Решение показать это принимает интерфейс — здесь
    // только приводим состояние в порядок перед боем.
    final now = _now();
    final healedHp = GameRules.hpAfterIdle(
      kind: node.kind,
      currentHp: node.currentHp,
      maxHp: node.maxHp,
      lastFoughtAt: node.lastFoughtAt,
      now: now,
    );

    final damage = GameRules.damageFor(
      kind: node.kind,
      focusSeconds: focusSeconds,
      mood: mood,
      completedFully: completedFully,
    );
    final playerDamage = GameRules.playerDamageFor(
      kind: node.kind,
      mood: mood,
      completedFully: completedFully,
    );

    final hpAfter = (healedHp - damage).clamp(0, node.maxHp);
    final playerHpAfter = (node.playerHp - playerDamage).clamp(0, 99);

    final levelUp = await _awardXp(xp);

    // Персонаж выдохся раньше босса: тот приходит в себя целиком, бой
    // начинается заново. Это не скрытый штраф — интерфейс обязан объяснить
    // происходящее отдельным экраном.
    if (node.isBoss && playerHpAfter <= 0 && hpAfter > 0) {
      final reset = node.copyWith(
        currentHp: node.maxHp,
        playerHp: GameRules.bossPlayerHp,
        lastFoughtAt: now,
      );
      await _writeNode(reset);
      return EncounterResult(
        outcome: EncounterOutcome.playerDefeated,
        xpGained: xp,
        damageDealt: damage,
        node: reset,
        leveledUpTo: levelUp,
      );
    }

    if (hpAfter <= 0) {
      final done = node.copyWith(
        status: MapNodeStatus.completed,
        currentHp: 0,
        lastFoughtAt: now,
      );
      await _writeNode(done);
      await _unlockNext(done);
      await _countKill(isBoss: node.isBoss);
      return EncounterResult(
        outcome: node.isBoss
            ? EncounterOutcome.bossDefeated
            : EncounterOutcome.drifterDefeated,
        xpGained: xp,
        damageDealt: damage,
        node: done,
        leveledUpTo: levelUp,
      );
    }

    final wounded = node.copyWith(
      currentHp: hpAfter,
      playerHp: playerHpAfter,
      lastFoughtAt: now,
    );
    await _writeNode(wounded);
    return EncounterResult(
      outcome: EncounterOutcome.damaged,
      xpGained: xp,
      damageDealt: damage,
      node: wounded,
      leveledUpTo: levelUp,
    );
  }

  @override
  Future<EncounterResult> applyHabitCompletion() async {
    if (!await isEnabled()) return const EncounterResult.none();
    await ensureInitialized();

    final levelUp = await _awardXp(GameRules.habitXp);
    return EncounterResult(
      outcome: EncounterOutcome.damaged,
      xpGained: GameRules.habitXp,
      damageDealt: 0,
      leveledUpTo: levelUp,
    );
  }

  /// Начисляет опыт и возвращает новый уровень, если он взят этим действием.
  Future<int?> _awardXp(int xp) async {
    if (xp <= 0) return null;
    final before = await progress();
    final after = before.copyWith(totalXp: before.totalXp + xp);
    await _writeProgress(after);
    return after.level > before.level ? after.level : null;
  }

  Future<void> _countKill({required bool isBoss}) async {
    final current = await progress();
    await _writeProgress(
      isBoss
          ? current.copyWith(bossKills: current.bossKills + 1)
          : current.copyWith(drifterKills: current.drifterKills + 1),
    );
  }

  @override
  Future<void> resetProgress() async {
    await _db.delete(_db.mapNodes).go();
    await _db.delete(_db.playerProgress).go();
    await ensureInitialized();
  }
}
