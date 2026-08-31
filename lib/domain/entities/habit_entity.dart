/// Привычка — дневная цель плюс «наказание», которое пользователь назначил
/// себе сам. Приложение наказание не автоматизирует: только хранит текст и
/// показывает его в напоминании.
class HabitEntity {
  const HabitEntity({
    required this.id,
    required this.name,
    required this.punishment,
    required this.weekdayMask,
    required this.createdAt,
    this.reminderMinutes,
    this.archived = false,
    this.sortOrder = 0,
  });

  final String id;
  final String name;

  /// То, что пользователь сам себе назначил за невыполнение. Обязательное
  /// поле при создании — в этом вся идея.
  final String punishment;

  /// Битовая маска дней недели: бит 0 — понедельник … бит 6 — воскресенье.
  /// [everyDayMask] — привычка на каждый день.
  final int weekdayMask;

  /// Минуты от полуночи для персонального напоминания. null — напоминание
  /// по этой привычке выключено (общий итог дня приходит всё равно).
  final int? reminderMinutes;

  final DateTime createdAt;
  final bool archived;
  final int sortOrder;

  static const int everyDayMask = 0x7F;

  bool get isDaily => weekdayMask == everyDayMask;

  /// Запланирована ли привычка на конкретный день недели (1 — понедельник).
  bool isScheduledOnWeekday(int weekday) =>
      weekdayMask & (1 << (weekday - 1)) != 0;

  bool isScheduledOn(DateTime day) => isScheduledOnWeekday(day.weekday);

  HabitEntity copyWith({
    String? name,
    String? punishment,
    int? weekdayMask,
    int? reminderMinutes,
    bool clearReminder = false,
    bool? archived,
    int? sortOrder,
  }) {
    return HabitEntity(
      id: id,
      name: name ?? this.name,
      punishment: punishment ?? this.punishment,
      weekdayMask: weekdayMask ?? this.weekdayMask,
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

/// Привычка вместе с состоянием на выбранный день — то, что рисует Home.
class HabitWithStatus {
  const HabitWithStatus({
    required this.habit,
    required this.doneToday,
    required this.streak,
  });

  final HabitEntity habit;
  final bool doneToday;

  /// Сколько запланированных дней подряд привычка выполнялась, считая назад
  /// от сегодняшнего дня.
  final int streak;
}
