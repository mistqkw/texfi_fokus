import '../entities/habit_entity.dart';
import '../entities/statistics.dart';

abstract class HabitRepository {
  Stream<List<HabitEntity>> watchHabits();

  Future<List<HabitEntity>> getHabits();

  Future<HabitEntity?> getHabitById(String id);

  /// Привычки, запланированные на указанный день, вместе с отметкой
  /// выполнения и текущим стриком.
  Stream<List<HabitWithStatus>> watchHabitsForDay(DateTime day);

  /// Привычки на день без подписки — нужны планировщику уведомлений.
  Future<List<HabitWithStatus>> getHabitsForDay(DateTime day);

  Future<void> createHabit(HabitEntity habit);

  Future<void> updateHabit(HabitEntity habit);

  Future<void> deleteHabit(String id);

  /// Отмечает или снимает выполнение привычки за день.
  Future<void> setCompletion({
    required String habitId,
    required DateTime day,
    required bool done,
  });

  Future<List<HabitCompletionEntity>> completionsInRange(
    DateTime from,
    DateTime to,
  );

  /// Сколько дней подряд закрыты все запланированные на день привычки.
  /// Это и есть «стрик» на главном экране.
  Future<int> overallStreak({DateTime? until});

  Future<List<HabitSuccessStat>> successStats(DateTime from, DateTime to);
}
