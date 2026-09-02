import 'dart:math';

import 'mood.dart';
import 'task_category.dart';

/// Что стоит на узле карты.
enum MapNodeKind {
  drifter,
  boss;

  static MapNodeKind fromIndex(int index) =>
      index >= 0 && index < MapNodeKind.values.length
          ? MapNodeKind.values[index]
          : MapNodeKind.drifter;
}

/// Состояние узла. Порядок значим — индекс хранится в БД.
enum MapNodeStatus {
  locked,
  current,
  completed;

  static MapNodeStatus fromIndex(int index) =>
      index >= 0 && index < MapNodeStatus.values.length
          ? MapNodeStatus.values[index]
          : MapNodeStatus.locked;
}

/// Разновидность обычного дрифера. Не окраска одного силуэта, а девять разных
/// существ: у каждого свой спрайт, свои пропорции и свой характер.
///
/// Девять, а не три, потому что миров три и каждому положен собственный
/// набор. Повтор одной и той же тройки во всех мирах — самая заметная
/// причина, по которой карта читается как заглушка: пройдя первый мир,
/// человек во втором встречает ровно тех же противников под теми же именами,
/// и «продвижение» перестаёт что-либо значить.
///
/// Индекс хранится в БД — порядок менять нельзя, только дописывать в конец.
/// Первые три поэтому остались на своих местах: у людей, уже начавших партию,
/// узлы первого мира не должны молча превратиться в других существ.
enum DrifterSpecies {
  /// Гудок — широкий крылатый: мелкое тело, размах в весь кадр. Тот самый
  /// «звякнуло и утащило».
  buzz,

  /// Ползун — приземистый многоногий. Не налетает, а подбирается снизу.
  creep,

  /// Морок — высокий и узкий, с одним большим пустым глазом. Ничего не
  /// делает, просто стоит и смотрит.
  loom,

  // --- Мир 2 ---

  /// Клубок — песочные часы из скрещённых нитей: чем дольше распутываешь,
  /// тем ровнее он затягивается обратно.
  tangle,

  /// Мошкара — не одно существо, а горсть мелких пятен по углам кадра.
  /// Каждое по отдельности ничего не весит.
  mote,

  /// Скорлупа — пустое кольцо: оболочка задачи, из которой давно вынули
  /// содержимое.
  husk,

  // --- Мир 3 ---

  /// Воронка — широкая сверху, сходится в тонкую струйку внизу.
  siphon,

  /// Узел — столб с двумя перекладинами. Стоит поперёк дороги и не двигается.
  knot,

  /// Полог — косая тяжёлая занавесь, сползающая через весь кадр наискось.
  veil;

  static DrifterSpecies fromIndex(int index) =>
      index >= 0 && index < DrifterSpecies.values.length
          ? DrifterSpecies.values[index]
          : DrifterSpecies.buzz;
}

/// Из чего состоит один мир.
///
/// Заведено отдельным описанием, а не тремя параллельными списками, ровно
/// по той причине, по которой в этом файле вообще есть [worlds]: мир — это
/// не «номер в цикле», а набор согласованных между собой решений. Чтобы
/// появился четвёртый, достаточно дописать сюда одну строку и три вида в
/// [DrifterSpecies]; ни схема БД, ни репозиторий, ни экраны при этом не
/// меняются. Пока миров три, разница между «списком списков» и этим
/// классом почти незаметна — она станет заметна ровно в тот день, когда
/// у мира появится второе свойство, и его придётся вписывать в код,
/// который к тому времени успел разъехаться.
final class WorldDefinition {
  const WorldDefinition({required this.roster, required this.affinity});

  /// Кто стоит на обычных узлах этого мира. Внутри мира повторов нет.
  final List<DrifterSpecies> roster;

  /// С какой категорией задач мир перекликается.
  ///
  /// Это не требование и не фильтр: в «Громком поле» можно спокойно учиться,
  /// и ничего не сломается. Совпадение только добавляет небольшую разовую
  /// надбавку к опыту и одну строку на карте — ровно столько, чтобы порядок
  /// миров перестал быть случайным и начал что-то говорить о том, над чем
  /// человек на самом деле работает.
  final TaskCategory affinity;
}

/// Правила игрового слоя.
///
/// Всё здесь — чистые функции без состояния и без Flutter: игровая механика
/// должна проверяться тестами целиком, а не «на глаз» через интерфейс.
///
/// Слой принципиально надстроечный. Он читает уже сохранённые сессии и
/// привычки, чтобы начислить опыт, но ничего не решает за движок
/// рекомендаций и не трогает его веса: выключенный игровой режим не должен
/// менять ни одной цифры в обычном трекере.
abstract final class GameRules {
  // --- Опыт и уровни ---

  /// Сколько всего опыта нужно, чтобы оказаться на уровне [level].
  ///
  /// Квадратичная кривая: шаг между соседними уровнями растёт линейно
  /// (50, 100, 150, …), а сумма — квадратично. Первые уровни берутся за
  /// пару сессий, десятый — за пару недель, и это ровно тот темп, при
  /// котором прогресс ещё виден, но уже не сыплется даром.
  static int totalXpForLevel(int level) {
    if (level <= 1) return 0;
    return 25 * (level - 1) * level;
  }

  /// Сколько опыта нужно набрать на уровне [level], чтобы уйти на следующий.
  static int xpToAdvance(int level) =>
      totalXpForLevel(level + 1) - totalXpForLevel(level);

  /// Уровень, соответствующий накопленному опыту. Уровни начинаются с 1.
  static int levelForXp(int totalXp) {
    if (totalXp <= 0) return 1;
    var level = 1;
    while (totalXpForLevel(level + 1) <= totalXp) {
      level += 1;
      // Страховка от бесконечного цикла на абсурдных значениях: выше сотого
      // уровня кривая всё равно перестаёт что-либо значить.
      if (level >= 100) break;
    }
    return level;
  }

  /// Прогресс внутри текущего уровня, 0..1 — то, что рисует полоска опыта.
  static double levelProgress(int totalXp) {
    final level = levelForXp(totalXp);
    final floor = totalXpForLevel(level);
    final span = xpToAdvance(level);
    if (span <= 0) return 1;
    return ((totalXp - floor) / span).clamp(0.0, 1.0);
  }

  /// Опыт внутри уровня и сколько его нужно всего — для подписи «120 / 250».
  static ({int current, int needed}) levelXpBreakdown(int totalXp) {
    final level = levelForXp(totalXp);
    return (
      current: totalXp - totalXpForLevel(level),
      needed: xpToAdvance(level),
    );
  }

  // --- Множители ---

  /// Сложность задачи — и множитель опыта, и множитель HP дрифера: трудная
  /// задача выставляет против тебя противника покрупнее.
  static double difficultyMultiplier(TaskDifficulty difficulty) =>
      switch (difficulty) {
        TaskDifficulty.easy => 1.0,
        TaskDifficulty.medium => 1.25,
        TaskDifficulty.hard => 1.5,
      };

  // --- Опыт за действия ---

  /// Опыт за фокус-сессию.
  ///
  /// База — минута за минуту реально отсиженного времени. Оборванная сессия
  /// приносит половину: она всё равно была работой, и обнулять её значило бы
  /// наказывать за честную остановку. Старт в состоянии full f0kus даёт
  /// надбавку — это единственное место, где настроение влияет на награду.
  static int xpForSession({
    required int focusSeconds,
    required TaskDifficulty difficulty,
    required Mood mood,
    required bool completedFully,
  }) {
    final minutes = focusSeconds ~/ 60;
    if (minutes <= 0) return 0;

    var xp = minutes * difficultyMultiplier(difficulty);
    if (mood == Mood.fullFokus) xp *= 1.25;
    if (!completedFully) xp *= 0.5;
    return xp.floor();
  }

  // --- Редкая окраска ---

  /// Один шанс из скольких, что очередной дрифер окажется редким.
  ///
  /// Двадцать четыре — примерно раз в несколько недель обычной игры: реже,
  /// чем «а, опять», и чаще, чем «никогда».
  static const int goldenOneIn = 24;

  /// Бросок на редкую окраску. Только для обычных дриферов: босс мира —
  /// событие само по себе, и «золотой» босс обесценил бы и то, и другое.
  static bool rollGolden(Random random, {required MapNodeKind kind}) {
    if (kind != MapNodeKind.drifter) return false;
    return random.nextInt(goldenOneIn) == 0;
  }

  /// Надбавка за победу над редким дрифером.
  ///
  /// Плоская и маленькая — примерно четверть обычной сессии. Ровно столько,
  /// чтобы заметивший что-то получил, и настолько мало, чтобы темп уровней
  /// от этого не поехал: узлов на карте двенадцать, и даже если бы редкими
  /// оказались все, суммарная прибавка не дотянула бы до одного уровня.
  static const int goldenBonusXp = 12;

  /// Один шанс из скольких, что удержанное крайнее положение переключателя
  /// настроения отзовётся состоянием сверх full f0kus.
  ///
  /// Реже, чем «каждый раз», и достаточно часто, чтобы упорство окупилось за
  /// один присест: пятнадцать удержаний по две секунды — это полминуты.
  static const int unstoppableOneIn = 15;

  /// Бросок на это состояние. Отдельной функцией, а не строкой в виджете, по
  /// той же причине, что и [rollGolden]: вероятность — это правило игры, и
  /// проверяться она должна тестом.
  static bool rollUnstoppable(Random random) =>
      random.nextInt(unstoppableOneIn) == 0;

  /// Надбавка за скрытое состояние сверх full f0kus.
  ///
  /// Того же порядка и по той же причине: это не множитель, а разовая
  /// прибавка поверх уже посчитанного опыта сессии.
  static const int unstoppableBonusXp = 10;

  /// Опыт за закрытую привычку.
  ///
  /// Заметно меньше длинной сессии — привычка и стоит дешевле, — но не ноль:
  /// «сделал зарядку» тоже продвигает, иначе игровой слой молча объявил бы
  /// половину приложения не считающейся.
  static const int habitXp = 15;

  // --- Дриферы ---

  /// HP обычного дрифера: одна минута запланированного фокуса — одно HP,
  /// с поправкой на сложность задачи.
  static int drifterHp({
    required int plannedFocusMinutes,
    required TaskDifficulty difficulty,
  }) {
    final hp = plannedFocusMinutes * difficultyMultiplier(difficulty);
    return hp.round().clamp(5, 999);
  }

  /// HP босса мира. Кратно больше обычного дрифера: босса не закрывают одной
  /// сессией, к нему возвращаются.
  static int bossHp(int world) => 120 + (world - 1).clamp(0, 99) * 60;

  /// Сколько раз можно сорваться на боссе, прежде чем он полностью
  /// восстановится. Три — это «не с первого раза, но и не бесконечная
  /// мясорубка».
  static const int bossPlayerHp = 3;

  /// Урон, который сессия наносит противнику на узле.
  ///
  /// Обычному дриферу урон наносит любая честно отсиженная минута.
  ///
  /// С боссом иначе: его пробивают только сессии, начатые в состоянии
  /// full f0kus. Всё остальное царапает символически — не ноль, чтобы работа
  /// не пропадала совсем, но в восемь раз слабее, и разница видна сразу.
  static int damageFor({
    required MapNodeKind kind,
    required int focusSeconds,
    required Mood mood,
    required bool completedFully,
  }) {
    final minutes = focusSeconds ~/ 60;
    if (minutes <= 0) return 0;

    if (kind == MapNodeKind.drifter) {
      // Оборванная сессия недобивает дрифера, но и не пропадает: он
      // остаётся раненым и ждёт следующего захода.
      return completedFully ? minutes : (minutes * 0.5).floor();
    }

    if (mood != Mood.fullFokus) return (minutes / 4).floor();
    if (!completedFully) return 0;
    return minutes * 2;
  }

  /// Сколько HP теряет персонаж на этом заходе.
  ///
  /// Только босс бьёт в ответ и только за сорванную f0kus-сессию: обычный
  /// дрифер ничего с тобой сделать не может, а неудачная попытка с
  /// «не тем» настроением — это не поражение, а просто слабый заход.
  static int playerDamageFor({
    required MapNodeKind kind,
    required Mood mood,
    required bool completedFully,
  }) {
    if (kind != MapNodeKind.boss) return 0;
    if (completedFully) return 0;
    return mood == Mood.fullFokus ? 1 : 0;
  }

  /// Через сколько простоя недобитый дрифер зализывает раны.
  ///
  /// Прогресс не исчезает молча: интерфейс показывает, что дрифер
  /// восстановился, и почему. Два дня — достаточно, чтобы вернуться к той же
  /// задаче на выходных, и мало, чтобы «недобитый месяц назад» считался.
  static const Duration drifterHealAfter = Duration(days: 2);

  /// Сколько HP осталось у дрифера с учётом простоя.
  ///
  /// Возвращает исходное HP, если с последнего боя прошло больше
  /// [drifterHealAfter] — но решение показать это пользователю принимает
  /// интерфейс, а не хранилище.
  static int hpAfterIdle({
    required MapNodeKind kind,
    required int currentHp,
    required int maxHp,
    required DateTime? lastFoughtAt,
    required DateTime now,
  }) {
    // Босс не восстанавливается от простоя — только от того, что ты сдался.
    if (kind == MapNodeKind.boss) return currentHp;
    if (lastFoughtAt == null || currentHp >= maxHp) return currentHp;
    if (now.difference(lastFoughtAt) < drifterHealAfter) return currentHp;
    return maxHp;
  }

  // --- Карта ---

  /// Миры по порядку. Индекс в списке — это `world - 1`.
  ///
  /// Первый мир оставлен ровно в том составе и порядке, в каком он
  /// раскладывался прежней формулой `(world + position) % 3`, — иначе у
  /// людей с уже начатой партией узлы сменили бы обитателей на ровном
  /// месте.
  ///
  /// Соответствие мира категории выбрано по характеру, а не по алфавиту:
  /// тихая комната — это про то, как садятся за учёбу; громкое поле — про
  /// рабочий день, где всё требует очереди; длинный зал — про дела, которые
  /// не кончаются. Творчество и спорт намеренно оставлены четвёртому и
  /// пятому мирам: их характер ещё не написан, и раздавать им категории
  /// заранее значило бы решать за ещё не существующий контент.
  static const List<WorldDefinition> worlds = [
    WorldDefinition(
      roster: [DrifterSpecies.loom, DrifterSpecies.buzz, DrifterSpecies.creep],
      affinity: TaskCategory.study,
    ),
    WorldDefinition(
      roster: [DrifterSpecies.tangle, DrifterSpecies.mote, DrifterSpecies.husk],
      affinity: TaskCategory.work,
    ),
    WorldDefinition(
      roster: [DrifterSpecies.siphon, DrifterSpecies.knot, DrifterSpecies.veil],
      affinity: TaskCategory.chores,
    ),
  ];

  /// Сколько миров реализовано. Считается по [worlds], а не задано числом:
  /// два источника правды про одно и то же — самый дешёвый способ однажды
  /// разложить карту на четыре мира, из которых наполнены три.
  static int get worldCount => worlds.length;

  /// Мир по 1-based номеру. За пределами реализованного возвращает
  /// последний: карта не должна падать от запроса про мир, которого ещё нет.
  static WorldDefinition worldAt(int world) =>
      worlds[(world - 1).clamp(0, worlds.length - 1)];

  /// Категория, с которой перекликается мир.
  static TaskCategory affinityOf(int world) => worldAt(world).affinity;

  /// Сколько обычных дриферов стоит перед боссом мира.
  static const int drifterNodesPerWorld = 3;

  /// Всего узлов в мире: дриферы плюс босс в конце.
  static const int nodesPerWorld = drifterNodesPerWorld + 1;

  /// Устойчивый id узла. Строкой, а не парой чисел: так его удобно класть в
  /// ссылки и логи, и он не разъедется при смене нумерации.
  static String nodeId(int world, int position) => 'w${world}n$position';

  /// Какое существо стоит на узле. У каждого мира свой набор, внутри мира
  /// повторов нет.
  static DrifterSpecies speciesFor(int world, int position) {
    final row = worldAt(world).roster;
    return row[(position - 1) % row.length];
  }

  // --- Перекличка мира с категорией задачи ---

  /// Надбавка за работу «в тему» мира.
  ///
  /// Плоская и намеренно маленькая — примерно треть короткой сессии. Смысл
  /// не в том, чтобы направлять человека («учись, пока ты в первом мире»),
  /// а в том, чтобы совпадение было замечено, когда оно случается само.
  /// Множитель здесь был бы вредной механикой: он превратил бы карту в
  /// расписание того, чем сейчас положено заниматься.
  static const int resonanceBonusXp = 8;

  /// Начисляется ли надбавка за перекличку.
  ///
  /// «Прочее» не в счёт: это значение по умолчанию, а не выбор, и совпадать
  /// с ним не должно ничего.
  static bool resonates({required int world, required TaskCategory category}) {
    if (category == TaskCategory.other) return false;
    return affinityOf(world) == category;
  }

  // --- Память дрифера ---

  /// Со скольких брошенных заходов дрифер начинает это замечать.
  ///
  /// Два, а не один: один оборванный заход — это просто оборванный заход, и
  /// делать из него наблюдение о человеке было бы и неточно, и неприятно.
  static const int drifterMemoryThreshold = 2;

  /// Со скольких — вторая, более прямая строка.
  static const int drifterMemoryDeepThreshold = 4;

  /// Ступень памяти дрифера, 0..2. 0 — молчит.
  ///
  /// Это только текст. Ни на HP, ни на урон, ни на опыт счётчик не влияет и
  /// влиять не должен: механический штраф за брошенные сессии наказывал бы
  /// ровно за то, что приложение вообще-то просит делать честно — за
  /// признание, что сессия не пошла.
  static int drifterMemoryTier(int abandonedCount) {
    if (abandonedCount >= drifterMemoryDeepThreshold) return 2;
    if (abandonedCount >= drifterMemoryThreshold) return 1;
    return 0;
  }

  // --- Сквозная нить ---

  /// Сколько всего обрывков записок спрятано за боссами.
  ///
  /// По одному на мир плюс последний, который открывается только когда
  /// пройдены все. Считается от [worldCount]: появится четвёртый мир —
  /// появится и четвёртый обрывок, и последний уедет за него сам.
  static int get loreFragmentCount => worldCount + 1;

  /// Сколько обрывков открыто при таком числе побеждённых боссов.
  ///
  /// Последний придерживается до полного прохождения карты: он единственный,
  /// что говорит про место целиком, и до конца пути ему нечего подытоживать.
  static int unlockedLoreFragments(int bossKills) {
    if (bossKills <= 0) return 0;
    if (bossKills >= worldCount) return loreFragmentCount;
    return bossKills.clamp(0, worldCount);
  }

  // --- Персонаж ---

  /// Уровни, на которых у аватара появляется новая ступень внешнего вида.
  ///
  /// Ступени, а не деталь на каждый уровень: изменение раз в несколько
  /// уровней читается как событие, а прибавка одной клетки каждый раз — как
  /// шум. Шесть ступеней покрывают три десятка уровней — заведомо дальше,
  /// чем человек уйдёт за первые месяцы, и рост при этом не упирается в
  /// потолок на десятом.
  static const List<int> avatarStageLevels = [1, 3, 6, 10, 15, 21];

  static int get avatarStageCount => avatarStageLevels.length;

  /// Стадия аватара по уровню, 0-based.
  static int avatarStageForLevel(int level) {
    var stage = 0;
    for (var i = 0; i < avatarStageLevels.length; i++) {
      if (level >= avatarStageLevels[i]) stage = i;
    }
    return stage;
  }

  /// Уровень, на котором откроется следующая ступень. null — последняя.
  static int? nextAvatarStageLevel(int level) {
    for (final threshold in avatarStageLevels) {
      if (level < threshold) return threshold;
    }
    return null;
  }

  /// Уровни, с которых начинается очередное звание.
  ///
  /// Званий больше, чем ступеней вида: текст меняется чаще, чем спрайт, и
  /// поэтому подтверждает продвижение в те уровни, когда картинка ещё та же.
  static const List<int> rankLevels = [1, 3, 5, 8, 11, 15, 20, 27];

  static int get rankCount => rankLevels.length;

  /// Звание по уровню, 0-based индекс в [rankLevels].
  static int rankForLevel(int level) {
    var rank = 0;
    for (var i = 0; i < rankLevels.length; i++) {
      if (level >= rankLevels[i]) rank = i;
    }
    return rank;
  }

  // --- Бой в реальном времени ---

  /// Сколько HP останется у противника, если сессия закончится прямо сейчас
  /// и будет доведена до конца.
  ///
  /// Нужна экрану боя: полоска должна убывать вместе с таймером, а не
  /// прыгать одним скачком в конце. Считается тем же [damageFor], что и
  /// настоящее начисление, — чтобы показанное и записанное не разъезжались.
  /// Берётся вариант «довёл до конца»: полоска показывает, к чему человек
  /// идёт, а не к чему придёт, если сдастся на этой секунде.
  static int previewHp({
    required MapNodeKind kind,
    required int currentHp,
    required int focusSeconds,
    required Mood mood,
  }) {
    final damage = damageFor(
      kind: kind,
      focusSeconds: focusSeconds,
      mood: mood,
      completedFully: true,
    );
    return (currentHp - damage).clamp(0, currentHp);
  }

  /// Доля HP противника для полоски на экране боя, 0..1.
  static double previewHpFraction({
    required MapNodeKind kind,
    required int currentHp,
    required int maxHp,
    required int focusSeconds,
    required Mood mood,
  }) {
    if (maxHp <= 0) return 0;
    final hp = previewHp(
      kind: kind,
      currentHp: currentHp,
      focusSeconds: focusSeconds,
      mood: mood,
    );
    return (hp / maxHp).clamp(0.0, 1.0);
  }
}
