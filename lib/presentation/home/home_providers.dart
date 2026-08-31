import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/data_providers.dart';
import '../../data/repositories/habit_repository_impl.dart' show dayOf;
import '../../domain/entities/habit_entity.dart';

/// Сегодняшний день, нормализованный к полуночи. Отдельный провайдер, чтобы
/// его можно было подменить в тестах и инвалидировать при смене суток.
final todayProvider = Provider<DateTime>((ref) => dayOf(DateTime.now()));

/// Начало текущей недели (понедельник).
final weekStartProvider = Provider<DateTime>((ref) {
  final today = ref.watch(todayProvider);
  return today.subtract(Duration(days: today.weekday - 1));
});

final todayHabitsProvider = StreamProvider<List<HabitWithStatus>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchHabitsForDay(ref.watch(todayProvider));
});

/// Общий стрик: пересчитывается при любом изменении отметок, поэтому
/// подписан на тот же поток, что и список привычек.
final overallStreakProvider = FutureProvider<int>((ref) async {
  ref.watch(todayHabitsProvider);
  return ref.watch(habitRepositoryProvider).overallStreak(
        until: ref.watch(todayProvider),
      );
});

final focusSecondsTodayProvider = StreamProvider<int>((ref) {
  final today = ref.watch(todayProvider);
  return ref.watch(sessionRepositoryProvider).watchFocusSecondsForDay(today);
});

final focusSecondsWeekProvider = StreamProvider<int>((ref) {
  return ref.watch(sessionRepositoryProvider).watchFocusSecondsInRange(
        ref.watch(weekStartProvider),
        ref.watch(todayProvider),
      );
});

/// Переключает отметку выполнения привычки за сегодня.
final toggleHabitProvider =
    Provider<Future<void> Function(String habitId, bool done)>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final today = ref.watch(todayProvider);
  return (habitId, done) => repository.setCompletion(
        habitId: habitId,
        day: today,
        done: done,
      );
});
