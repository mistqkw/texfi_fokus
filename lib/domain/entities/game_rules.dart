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

/// Разновидность обычного дрифера. Не окраска одного силуэта, а три разных
/// существа: у каждого свой спрайт, свои пропорции и свой характер.
///
/// Индекс хранится в БД — порядок менять нельзя.
enum DrifterSpecies {
  /// Гудок — широкий крылатый: мелкое тело, размах в весь кадр. Тот самый
  /// «звякнуло и утащило».
  buzz,

  /// Ползун — приземистый многоногий. Не налетает, а подбирается снизу.
  creep,

  /// Морок — высокий и узкий, с одним большим пустым глазом. Ничего не
  /// делает, просто стоит и смотрит.
  loom;

  static DrifterSpecies fromIndex(int index) =>
      index >= 0 && index < DrifterSpecies.values.length
          ? DrifterSpecies.values[index]
          : DrifterSpecies.buzz;
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

  /// Сколько миров реализовано в первом заходе. Каждый — со своим боссом и
  /// своим набором дриферов.
  static const int worldCount = 3;

  /// Сколько обычных дриферов стоит перед боссом мира.
  static const int drifterNodesPerWorld = 3;

  /// Всего узлов в мире: дриферы плюс босс в конце.
  static const int nodesPerWorld = drifterNodesPerWorld + 1;

  /// Устойчивый id узла. Строкой, а не парой чисел: так его удобно класть в
  /// ссылки и логи, и он не разъедется при смене нумерации.
  static String nodeId(int world, int position) => 'w${world}n$position';

  /// Какое существо стоит на узле. Разные, а не одно и то же: три силуэта
  /// чередуются так, чтобы соседние узлы не повторялись.
  static DrifterSpecies speciesFor(int world, int position) {
    return DrifterSpecies.fromIndex((world + position) % 3);
  }

  /// Стадия аватара по уровню — четыре ступени, а не новая деталь на каждый
  /// уровень: иначе изменения перестают читаться.
  static int avatarStageForLevel(int level) {
    if (level >= 10) return 3;
    if (level >= 6) return 2;
    if (level >= 3) return 1;
    return 0;
  }
}
