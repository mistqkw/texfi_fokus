import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/data_providers.dart';
import '../../domain/entities/habit_entity.dart';

final allHabitsProvider = StreamProvider<List<HabitEntity>>((ref) {
  return ref.watch(habitRepositoryProvider).watchHabits();
});

final habitByIdProvider =
    FutureProvider.family<HabitEntity?, String>((ref, id) {
  // Подписка на общий список заставляет карточку обновиться после
  // редактирования, а не показывать устаревшие данные.
  ref.watch(allHabitsProvider);
  return ref.watch(habitRepositoryProvider).getHabitById(id);
});

final saveHabitProvider =
    Provider<Future<void> Function(HabitEntity habit, {required bool isNew})>(
        (ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return (habit, {required isNew}) async {
    if (isNew) {
      await repository.createHabit(habit);
    } else {
      await repository.updateHabit(habit);
    }
  };
});

final deleteHabitProvider = Provider<Future<void> Function(String id)>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return (id) async {
    await repository.deleteHabit(id);
    // Уведомление удалённой привычки не должно пережить её саму.
    await notifications.cancelHabitReminder(id);
  };
});
