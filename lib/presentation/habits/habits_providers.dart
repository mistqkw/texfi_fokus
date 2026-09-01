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

/// Текст фильтра списка привычек. Живёт в провайдере, а не в состоянии
/// экрана: так он переживает уход в редактор привычки и обратно — иначе
/// человек, поправивший найденную привычку, возвращался бы к полному списку
/// и искал её заново.
final habitSearchQueryProvider = StateProvider<String>((ref) => '');

/// С какой длины списка показываем поле поиска.
///
/// На пяти привычках оно только отнимало бы высоту у самого списка: глазами
/// найти быстрее, чем печатать. Десяток — та граница, после которой список
/// перестаёт помещаться на экран целиком.
const int habitSearchThreshold = 10;

/// Отбор без учёта регистра и по подстроке в любом месте названия.
///
/// Ищем и по названию, и по тексту наказания: «если не выполнишь» человек
/// формулирует своими словами, и найти привычку по нему бывает проще, чем
/// по формальному названию вроде «Спорт».
List<HabitEntity> filterHabits(List<HabitEntity> habits, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return habits;
  return [
    for (final habit in habits)
      if (habit.name.toLowerCase().contains(needle) ||
          habit.punishment.toLowerCase().contains(needle) ||
          (habit.reward?.toLowerCase().contains(needle) ?? false))
        habit,
  ];
}
