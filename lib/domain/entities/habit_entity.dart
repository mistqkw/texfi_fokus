/// Как задана частота привычки.
enum HabitFrequencyType {
  /// По конкретным дням недели — маска в [HabitEntity.weekdayMask].
  weekdays,

  /// N раз в неделю, без привязки к дням. Для привычек, которые важно
  /// делать регулярно, но не важно когда именно: спортзал три раза в
  /// неделю — это не «понедельник, среда, пятница».
  timesPerWeek;

  static HabitFrequencyType fromIndex(int index) =>
      index >= 0 && index < HabitFrequencyType.values.length
          ? HabitFrequencyType.values[index]
          : HabitFrequencyType.weekdays;
}

/// Привычка — цель плюс «наказание», которое пользователь назначил себе сам,
/// и необязательная награда за выдержанный стрик. Ни то, ни другое
/// приложение не автоматизирует: только хранит текст и показывает вовремя.
/// Границы длины текстовых полей привычки.
///
/// Схема Drift ограничивает `name` и `punishment` (`withLength`), и это
/// ограничение проверяется на вставке. Форма редактирования обязана знать те
/// же числа: иначе набранный текст доходит до `createHabit` и падает там
/// исключением уже после нажатия «Сохранить», когда пользователю остаётся
/// только гадать, что не так. Держим их здесь, чтобы схема и форма не
/// разъехались при следующей правке.
abstract final class HabitLimits {
  /// Совпадает с `withLength(max: 120)` в `habits_table.dart`.
  static const int nameMaxLength = 120;

  /// Совпадает с `withLength(max: 300)` там же.
  static const int punishmentMaxLength = 300;

  /// В схеме награда не ограничена, но поле у неё того же назначения, что и
  /// у наказания, и разрешать здесь роман, когда там нельзя, незачем.
  static const int rewardMaxLength = 300;
}

class HabitEntity {
  const HabitEntity({
    required this.id,
    required this.name,
    required this.punishment,
    required this.weekdayMask,
    required this.createdAt,
    this.frequency = HabitFrequencyType.weekdays,
    this.timesPerWeek = 3,
    this.reward,
    this.rewardStreakDays = 7,
    this.freezeIntervalDays = defaultFreezeIntervalDays,
    this.reminderMinutes,
    this.archived = false,
    this.sortOrder = 0,
  });

  final String id;
  final String name;

  /// То, что пользователь сам себе назначил за невыполнение. Обязательное
  /// поле при создании — в этом вся идея.
  final String punishment;

  final HabitFrequencyType frequency;

  /// Битовая маска дней недели: бит 0 — понедельник … бит 6 — воскресенье.
  /// [everyDayMask] — привычка на каждый день. Осмысленна при
  /// [HabitFrequencyType.weekdays].
  final int weekdayMask;

  /// Сколько раз в неделю нужно закрыть привычку при
  /// [HabitFrequencyType.timesPerWeek].
  final int timesPerWeek;

  /// Награда за [rewardStreakDays] подряд. null — не задана. Симметрична
  /// наказанию: тот же принцип «пользователь вписывает сам».
  final String? reward;

  final int rewardStreakDays;

  /// Как часто разрешена заморозка дня. 0 — заморозки для этой привычки
  /// выключены.
  final int freezeIntervalDays;

  /// Минуты от полуночи для персонального напоминания. null — напоминание
  /// по этой привычке выключено (общий итог дня приходит всё равно).
  final int? reminderMinutes;

  final DateTime createdAt;
  final bool archived;
  final int sortOrder;

  static const int everyDayMask = 0x7F;

  /// Раз в неделю — ровно то, что делает заморозку страховкой, а не второй
  /// валютой: чаще, и стрик перестаёт что-либо значить.
  static const int defaultFreezeIntervalDays = 7;

  bool get isDaily =>
      frequency == HabitFrequencyType.weekdays && weekdayMask == everyDayMask;

  bool get freezeEnabled => freezeIntervalDays > 0;

  bool get hasReward => (reward ?? '').trim().isNotEmpty;

  /// Запланирована ли привычка на конкретный день недели (1 — понедельник).
  ///
  /// Для «N раз в неделю» запланирован любой день: конкретные дни выбирает
  /// сам пользователь по ходу недели, а недельная норма проверяется отдельно.
  bool isScheduledOnWeekday(int weekday) {
    if (frequency == HabitFrequencyType.timesPerWeek) return true;
    return weekdayMask & (1 << (weekday - 1)) != 0;
  }

  bool isScheduledOn(DateTime day) => isScheduledOnWeekday(day.weekday);

  HabitEntity copyWith({
    String? name,
    String? punishment,
    HabitFrequencyType? frequency,
    int? weekdayMask,
    int? timesPerWeek,
    String? reward,
    bool clearReward = false,
    int? rewardStreakDays,
    int? freezeIntervalDays,
    int? reminderMinutes,
    bool clearReminder = false,
    bool? archived,
    int? sortOrder,
  }) {
    return HabitEntity(
      id: id,
      name: name ?? this.name,
      punishment: punishment ?? this.punishment,
      frequency: frequency ?? this.frequency,
      weekdayMask: weekdayMask ?? this.weekdayMask,
      timesPerWeek: timesPerWeek ?? this.timesPerWeek,
      reward: clearReward ? null : (reward ?? this.reward),
      rewardStreakDays: rewardStreakDays ?? this.rewardStreakDays,
      freezeIntervalDays: freezeIntervalDays ?? this.freezeIntervalDays,
      reminderMinutes:
          clearReminder ? null : (reminderMinutes ?? this.reminderMinutes),
      createdAt: createdAt,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Отметка выполнения привычки за конкретный день.
class HabitCompletionEntity {
  const HabitCompletionEntity({
    required this.id,
    required this.habitId,
    required this.day,
    required this.completedAt,
  });

  final String id;
  final String habitId;

  /// Дата без времени — нормализована к полуночи локального дня.
  final DateTime day;

  final DateTime completedAt;
}

/// Заморозка одного дня: пропуск, который не рвёт стрик.
class HabitFreezeEntity {
  const HabitFreezeEntity({
    required this.id,
    required this.habitId,
    required this.day,
    required this.createdAt,
  });

  final String id;
  final String habitId;
  final DateTime day;
  final DateTime createdAt;
}

/// Привычка вместе с состоянием на выбранный день — то, что рисует Home.
class HabitWithStatus {
  const HabitWithStatus({
    required this.habit,
    required this.doneToday,
    required this.streak,
    this.frozenToday = false,
    this.freezeAvailable = true,
    this.nextFreezeOn,
    this.doneThisWeek = 0,
  });

  final HabitEntity habit;
  final bool doneToday;

  /// Сколько запланированных дней подряд привычка выполнялась, считая назад
  /// от сегодняшнего дня. Для «N раз в неделю» — сколько недель подряд
  /// закрыта норма.
  final int streak;

  /// Сегодня заморожено — день пропущен намеренно.
  final bool frozenToday;

  /// Заморозку можно потратить прямо сейчас.
  final bool freezeAvailable;

  /// Когда заморозка снова станет доступна. null — доступна уже сейчас
  /// либо выключена для этой привычки.
  final DateTime? nextFreezeOn;

  /// Сколько раз привычка закрыта на текущей неделе — для «N раз в неделю»
  /// это и есть основной прогресс.
  final int doneThisWeek;

  /// Заслужена ли назначенная себе награда.
  bool get rewardEarned =>
      habit.hasReward && streak > 0 && streak >= habit.rewardStreakDays;

  /// Норма недели закрыта — только для [HabitFrequencyType.timesPerWeek].
  bool get weeklyQuotaMet =>
      habit.frequency == HabitFrequencyType.timesPerWeek &&
      doneThisWeek >= habit.timesPerWeek;
}

/// Тихий значок долгого стрика.
///
/// Три ступени и ни одного слова: длинный стрик — это то, что человек и так
/// про себя знает, и объявлять ему об этом баннером значило бы превращать
/// признание в поздравительную открытку. Значок просто появляется сбоку от
/// названия и остаётся там.
abstract final class StreakBadge {
  /// Пороги ступеней. Месяц, сто дней и год — три рубежа, каждый из которых
  /// человек отмечает про себя и без приложения.
  static const List<int> thresholds = [30, 100, 365];

  static int get tierCount => thresholds.length;

  /// Ступень значка: 0 — значка нет, 1..3 — есть.
  static int tierFor(int streak) {
    var tier = 0;
    for (final threshold in thresholds) {
      if (streak >= threshold) tier++;
    }
    return tier;
  }
}
