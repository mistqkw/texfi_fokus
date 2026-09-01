import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/providers/data_providers.dart';
import '../../domain/entities/habit_entity.dart';

const _uuid = Uuid();

/// Разрешение на уведомления, полученное на онбординге. Хранится в памяти:
/// в настройках источником правды остаётся системное разрешение.
final onboardingNotificationsGrantedProvider = StateProvider<bool>((ref) => false);

/// Выбранный на онбординге режим: обычный трекер или трекер с игрой.
///
/// Хранится в памяти до конца онбординга и записывается в `game_settings`
/// одним вызовом на финише — вместе со всем остальным, что человек успел
/// выбрать. Заводить партию в момент касания карточки было бы неверно: до
/// последней кнопки он ещё может передумать, а карта в базе уже осталась бы.
///
/// По умолчанию выключено: обычный трекер остаётся поведением по умолчанию и
/// здесь, ровно как в настройках.
final onboardingGameModeProvider = StateProvider<bool>((ref) => false);

/// Создаёт первую привычку пользователя. Возвращает `false`, если полей не
/// хватает — тогда онбординг просто завершится без привычки, а не упрётся
/// в ошибку: заставлять придумывать «наказание» на первом экране жестоко.
final createFirstHabitProvider =
    Provider<Future<bool> Function({required String name, required String punishment})>(
        (ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return ({required String name, required String punishment}) async {
    final trimmedName = name.trim();
    final trimmedPunishment = punishment.trim();
    if (trimmedName.isEmpty || trimmedPunishment.isEmpty) return false;

    await repository.createHabit(
      HabitEntity(
        id: _uuid.v4(),
        name: trimmedName,
        punishment: trimmedPunishment,
        weekdayMask: HabitEntity.everyDayMask,
        createdAt: DateTime.now(),
        reminderMinutes: 20 * 60,
      ),
    );
    return true;
  };
});
