import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/data/local/database.dart';
import 'package:texfi_fokus/data/repositories/habit_repository_impl.dart';
import 'package:texfi_fokus/domain/entities/habit_entity.dart';

/// Привычки хранят не только текст, но и правила: чем считается стрик, когда
/// заморозка доступна, что попадает в «наказание сработало». Всё это легко
/// сломать одним лишним `continue`, поэтому проверяется на настоящей базе.
void main() {
  late AppDatabase db;
  late HabitRepositoryImpl repository;

  final createdAt = DateTime(2026, 1, 1);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = HabitRepositoryImpl(db);
  });

  tearDown(() => db.close());

  HabitEntity habit({
    String id = 'h1',
    HabitFrequencyType frequency = HabitFrequencyType.weekdays,
    int weekdayMask = HabitEntity.everyDayMask,
    int timesPerWeek = 3,
    int freezeIntervalDays = HabitEntity.defaultFreezeIntervalDays,
    String? reward,
    int rewardStreakDays = 7,
  }) {
    return HabitEntity(
      id: id,
      name: 'Зарядка',
      punishment: 'Без сериала',
      frequency: frequency,
      weekdayMask: weekdayMask,
      timesPerWeek: timesPerWeek,
      freezeIntervalDays: freezeIntervalDays,
      reward: reward,
      rewardStreakDays: rewardStreakDays,
      createdAt: createdAt,
    );
  }

  Future<void> complete(String id, List<DateTime> days) async {
    for (final day in days) {
      await repository.setCompletion(habitId: id, day: day, done: true);
    }
  }

  group('streak freeze', () {
    test('a frozen day holds the streak without inflating it', () async {
      await repository.createHabit(habit());
      // Понедельник и среда закрыты, вторник заморожен.
      await complete('h1', [DateTime(2026, 3, 2), DateTime(2026, 3, 4)]);
      final frozen = await repository.setFreeze(
        habitId: 'h1',
        day: DateTime(2026, 3, 3),
        frozen: true,
      );
      expect(frozen, isTrue);

      final status = await repository.getHabitsForDay(DateTime(2026, 3, 4));
      // Два выполненных дня, не три: заморозка спасает серию, но сама в неё
      // не засчитывается.
      expect(status.single.streak, 2);
      expect(status.single.frozenToday, isFalse);
    });

    test('without the freeze the same gap breaks the streak', () async {
      await repository.createHabit(habit());
      await complete('h1', [DateTime(2026, 3, 2), DateTime(2026, 3, 4)]);

      final status = await repository.getHabitsForDay(DateTime(2026, 3, 4));
      expect(status.single.streak, 1);
    });

    test('a second freeze inside the interval is refused', () async {
      await repository.createHabit(habit());

      final first = await repository.setFreeze(
        habitId: 'h1',
        day: DateTime(2026, 3, 3),
        frozen: true,
      );
      final second = await repository.setFreeze(
        habitId: 'h1',
        day: DateTime(2026, 3, 6),
        frozen: true,
      );

      expect(first, isTrue);
      expect(second, isFalse, reason: 'три дня спустя — ещё внутри недели');
      expect(
        (await repository.freezesInRange(
          DateTime(2026, 3, 1),
          DateTime(2026, 3, 10),
        )),
        hasLength(1),
      );
    });

    test('once the interval has passed the freeze comes back', () async {
      await repository.createHabit(habit());
      await repository.setFreeze(
        habitId: 'h1',
        day: DateTime(2026, 3, 3),
        frozen: true,
      );

      final later = await repository.setFreeze(
        habitId: 'h1',
        day: DateTime(2026, 3, 10),
        frozen: true,
      );
      expect(later, isTrue);
    });

    test('the status says when the next freeze is due', () async {
      await repository.createHabit(habit());
      await repository.setFreeze(
        habitId: 'h1',
        day: DateTime(2026, 3, 3),
        frozen: true,
      );

      final status = await repository.getHabitsForDay(DateTime(2026, 3, 4));
      expect(status.single.freezeAvailable, isFalse);
      expect(status.single.nextFreezeOn, DateTime(2026, 3, 10));

      final later = await repository.getHabitsForDay(DateTime(2026, 3, 11));
      expect(later.single.freezeAvailable, isTrue);
      expect(later.single.nextFreezeOn, isNull);
    });

    test('unfreezing is always allowed and frees the quota', () async {
      await repository.createHabit(habit());
      await repository.setFreeze(
        habitId: 'h1',
        day: DateTime(2026, 3, 3),
        frozen: true,
      );

      expect(
        await repository.setFreeze(
          habitId: 'h1',
          day: DateTime(2026, 3, 3),
          frozen: false,
        ),
        isTrue,
      );
      expect(
        await repository.setFreeze(
          habitId: 'h1',
          day: DateTime(2026, 3, 4),
          frozen: true,
        ),
        isTrue,
      );
    });

    test('a habit with freezes turned off never gets one', () async {
      await repository.createHabit(habit(freezeIntervalDays: 0));
      expect(
        await repository.setFreeze(
          habitId: 'h1',
          day: DateTime(2026, 3, 3),
          frozen: true,
        ),
        isFalse,
      );
    });
  });

  group('N times a week', () {
    test('the streak counts whole weeks, not days', () async {
      await repository.createHabit(
        habit(frequency: HabitFrequencyType.timesPerWeek, timesPerWeek: 3),
      );
      // Неделя 23–29 марта и неделя 30 марта — 5 апреля, по три отметки.
      await complete('h1', [
        DateTime(2026, 3, 23),
        DateTime(2026, 3, 25),
        DateTime(2026, 3, 28),
        DateTime(2026, 3, 30),
        DateTime(2026, 3, 31),
        DateTime(2026, 4, 2),
      ]);

      final status = await repository.getHabitsForDay(DateTime(2026, 4, 3));
      expect(status.single.streak, 2);
      expect(status.single.doneThisWeek, 3);
      expect(status.single.weeklyQuotaMet, isTrue);
    });

    test('an unfinished current week does not break the streak yet', () async {
      await repository.createHabit(
        habit(frequency: HabitFrequencyType.timesPerWeek, timesPerWeek: 3),
      );
      await complete('h1', [
        DateTime(2026, 3, 23),
        DateTime(2026, 3, 25),
        DateTime(2026, 3, 28),
        // Текущая неделя закрыта только наполовину — она ещё идёт.
        DateTime(2026, 3, 30),
      ]);

      final status = await repository.getHabitsForDay(DateTime(2026, 3, 31));
      expect(status.single.streak, 1);
      expect(status.single.doneThisWeek, 1);
      expect(status.single.weeklyQuotaMet, isFalse);
    });

    test('a missed past week ends the streak', () async {
      await repository.createHabit(
        habit(frequency: HabitFrequencyType.timesPerWeek, timesPerWeek: 3),
      );
      await complete('h1', [
        DateTime(2026, 3, 16),
        DateTime(2026, 3, 17),
        DateTime(2026, 3, 18),
        // Неделя 23–29 пропущена целиком.
        DateTime(2026, 3, 30),
        DateTime(2026, 3, 31),
        DateTime(2026, 4, 1),
      ]);

      final status = await repository.getHabitsForDay(DateTime(2026, 4, 2));
      expect(status.single.streak, 1);
    });

    test('such a habit is due every day of the week', () async {
      await repository.createHabit(
        habit(frequency: HabitFrequencyType.timesPerWeek),
      );
      for (var day = 2; day <= 8; day++) {
        final status = await repository.getHabitsForDay(DateTime(2026, 3, day));
        expect(status, hasLength(1), reason: 'день $day');
      }
    });
  });

  group('punishment stats', () {
    test('only real misses count, freezes and today do not', () async {
      await repository.createHabit(habit());
      final today = DateTime.now();
      final from = today.subtract(const Duration(days: 6));

      // Закрываем всё, кроме двух дней; один из них замораживаем.
      for (var i = 0; i <= 6; i++) {
        final day = from.add(Duration(days: i));
        if (i == 2 || i == 4) continue;
        await repository.setCompletion(habitId: 'h1', day: day, done: true);
      }
      await repository.setFreeze(
        habitId: 'h1',
        day: from.add(const Duration(days: 2)),
        frozen: true,
      );

      final stats = await repository.punishmentStats(from, today);
      expect(stats, hasLength(1));
      expect(stats.single.missedDays, 1);
      expect(stats.single.frozenDays, 1);
      expect(stats.single.punishment, 'Без сериала');
      // Сегодня в знаменатель не входит: день ещё не проигран.
      expect(stats.single.scheduledDays, 6);
    });

    test('days before the habit existed are not held against it', () async {
      await repository.createHabit(habit());
      final stats = await repository.punishmentStats(
        DateTime(2025, 12, 1),
        DateTime(2025, 12, 31),
      );
      expect(stats, isEmpty);
    });
  });

  group('reward', () {
    test('it is earned exactly at the configured streak', () async {
      await repository.createHabit(
        habit(reward: 'Долгая ванна', rewardStreakDays: 3),
      );
      await complete('h1', [
        DateTime(2026, 3, 2),
        DateTime(2026, 3, 3),
      ]);

      var status = await repository.getHabitsForDay(DateTime(2026, 3, 3));
      expect(status.single.rewardEarned, isFalse);

      await complete('h1', [DateTime(2026, 3, 4)]);
      status = await repository.getHabitsForDay(DateTime(2026, 3, 4));
      expect(status.single.streak, 3);
      expect(status.single.rewardEarned, isTrue);
    });

    test('no reward text means nothing to earn', () async {
      await repository.createHabit(habit(rewardStreakDays: 1));
      await complete('h1', [DateTime(2026, 3, 2)]);

      final status = await repository.getHabitsForDay(DateTime(2026, 3, 2));
      expect(status.single.streak, 1);
      expect(status.single.rewardEarned, isFalse);
    });
  });
}
