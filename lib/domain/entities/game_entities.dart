import 'game_rules.dart';

/// Накопленный прогресс персонажа. Одна строка на приложение.
class PlayerProgressEntity {
  const PlayerProgressEntity({
    this.totalXp = 0,
    this.drifterKills = 0,
    this.bossKills = 0,
  });

  final int totalXp;
  final int drifterKills;
  final int bossKills;

  int get level => GameRules.levelForXp(totalXp);

  double get levelProgress => GameRules.levelProgress(totalXp);

  int get avatarStage => GameRules.avatarStageForLevel(level);

  /// Звание — короткая словесная ступень («искра», «уголёк»). Меняется чаще,
  /// чем спрайт: между двумя перерисовками аватара человек всё равно должен
  /// видеть, что продвинулся.
  int get rank => GameRules.rankForLevel(level);

  /// Уровень, на котором аватар изменится в следующий раз. null — дальше
  /// ступеней нет.
  int? get nextAvatarStageLevel => GameRules.nextAvatarStageLevel(level);

  PlayerProgressEntity copyWith({
    int? totalXp,
    int? drifterKills,
    int? bossKills,
  }) {
    return PlayerProgressEntity(
      totalXp: totalXp ?? this.totalXp,
      drifterKills: drifterKills ?? this.drifterKills,
      bossKills: bossKills ?? this.bossKills,
    );
  }
}

/// Узел карты — одна остановка на пути: дрифер или босс в конце мира.
class MapNodeEntity {
  const MapNodeEntity({
    required this.id,
    required this.world,
    required this.position,
    required this.kind,
    required this.status,
    required this.species,
    required this.maxHp,
    required this.currentHp,
    required this.playerHp,
    this.golden = false,
    this.abandonedCount = 0,
    this.lastFoughtAt,
  });

  final String id;

  /// 1-based номер мира.
  final int world;

  /// 1-based позиция внутри мира.
  final int position;

  final MapNodeKind kind;
  final MapNodeStatus status;

  /// Какой именно дрифер здесь стоит. Для боссов не значима: у каждого мира
  /// свой собственный спрайт, привязанный к номеру мира.
  final DrifterSpecies species;

  final int maxHp;
  final int currentHp;

  /// Запас персонажа на текущем заходе к боссу. У обычных узлов не
  /// расходуется: дрифер сдачи не даёт.
  final int playerHp;

  /// Редкая окраска этого узла. Чисто внешняя разница плюс небольшая
  /// надбавка к опыту за победу — на HP, урон и порядок узлов не влияет.
  final bool golden;

  /// Сколько раз заход сюда обрывался, не добив противника.
  ///
  /// Только для одной строки текста при следующей встрече. Ни на HP, ни на
  /// урон, ни на опыт не влияет: приложение просит останавливаться честно, и
  /// штрафовать за честную остановку означало бы просить об одном, а
  /// наказывать за другое.
  final int abandonedCount;

  final DateTime? lastFoughtAt;

  bool get isBoss => kind == MapNodeKind.boss;

  bool get defeated => currentHp <= 0;

  /// Дрифер, которого начали, но не добили.
  bool get wounded => currentHp < maxHp && currentHp > 0;

  /// Ступень памяти дрифера, 0..2. 0 — дриферу нечего сказать.
  ///
  /// Только у обычных дриферов: босс и так возвращает к себе целиком, и
  /// отдельная реплика про брошенные заходы к нему была бы вторым
  /// напоминанием об одном и том же.
  int get memoryTier =>
      isBoss ? 0 : GameRules.drifterMemoryTier(abandonedCount);

  /// Доля оставшегося HP, 0..1 — то, что рисует полоска.
  double get hpFraction =>
      maxHp <= 0 ? 0 : (currentHp / maxHp).clamp(0.0, 1.0);

  MapNodeEntity copyWith({
    MapNodeStatus? status,
    int? maxHp,
    int? currentHp,
    int? playerHp,
    int? abandonedCount,
    DateTime? lastFoughtAt,
  }) {
    return MapNodeEntity(
      id: id,
      world: world,
      position: position,
      kind: kind,
      status: status ?? this.status,
      species: species,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      playerHp: playerHp ?? this.playerHp,
      golden: golden,
      abandonedCount: abandonedCount ?? this.abandonedCount,
      lastFoughtAt: lastFoughtAt ?? this.lastFoughtAt,
    );
  }
}

/// Чем закончился заход на узел. Возвращается из репозитория, чтобы
/// интерфейс мог показать нужный момент — и в том числе объяснить поражение,
/// а не молча откатить прогресс.
enum EncounterOutcome {
  /// Урон нанесён, противник ещё жив.
  damaged,

  /// Дрифер побеждён.
  drifterDefeated,

  /// Босс побеждён — открывается следующий мир.
  bossDefeated,

  /// Запас персонажа кончился, босс восстановил HP полностью.
  playerDefeated,

  /// Урона не было: игровой режим выключен, узла нет или сессия слишком
  /// короткая, чтобы что-то значить.
  none,
}

/// Итог одного захода: сколько опыта начислено, что стало с противником.
class EncounterResult {
  const EncounterResult({
    required this.outcome,
    required this.xpGained,
    required this.damageDealt,
    this.node,
    this.leveledUpTo,
    this.resonated = false,
  });

  const EncounterResult.none()
      : outcome = EncounterOutcome.none,
        xpGained = 0,
        damageDealt = 0,
        node = null,
        leveledUpTo = null,
        resonated = false;

  final EncounterOutcome outcome;
  final int xpGained;
  final int damageDealt;

  /// Состояние узла после захода.
  final MapNodeEntity? node;

  /// Новый уровень, если он взят этим заходом. null — уровень не изменился.
  final int? leveledUpTo;

  /// Категория задачи совпала с тем, с чем перекликается этот мир, и за это
  /// начислена небольшая надбавка. Нужно только затем, чтобы итоговый экран
  /// мог назвать причину: непрошеная прибавка к опыту без объяснения читается
  /// как сбой подсчёта.
  final bool resonated;

  bool get isSomething => outcome != EncounterOutcome.none;
}
