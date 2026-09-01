import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/data_providers.dart';
import '../../data/repositories/habit_repository_impl.dart' show dayOf;
import '../../domain/entities/habit_entity.dart';
import '../../domain/entities/insight.dart';
import '../game/game_providers.dart';
import '../settings/settings_providers.dart';

/// Сегодняшний день, нормализованный к полуночи. Отдельный провайдер, чтобы
/// его можно было подменить в тестах и инвалидировать при смене суток.
final todayProvider = Provider<DateTime>((ref) => dayOf(DateTime.now()));

/// Начало текущей недели — по настройке пользователя, а не всегда с
/// понедельника: для части мира неделя начинается с воскресенья, и «за эту
/// неделю» у них означает другой набор дней.
final weekStartProvider = Provider<DateTime>((ref) {
  final today = ref.watch(todayProvider);
  return ref.watch(weekStartDayProvider).startOf(today);
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

/// Сколько дней истории уходит в наблюдение на Home. Месяц — компромисс:
/// на неделе закономерность ещё не отличить от случайности, а на квартале
/// она уже описывает не сегодняшнего человека.
const int insightWindowDays = 30;

/// Одно наблюдение о том, как пользователь работает, — или null, если данных
/// пока не хватает.
///
/// Подписываемся на поток последних сессий, а не на разовый запрос: карточка
/// обязана обновиться сразу после завершённой сессии, иначе она выглядит
/// сломанной ровно в тот момент, когда пользователь на неё смотрит.
final homeInsightProvider = StreamProvider<Insight?>((ref) {
  final today = ref.watch(todayProvider);
  final from = today.subtract(const Duration(days: insightWindowDays - 1));
  // Лимит с запасом: 120 сессий за месяц — это по четыре в день, дальше
  // наблюдение всё равно не изменится, а память экономится.
  return ref.watch(sessionRepositoryProvider).watchRecentSessions(limit: 120).map(
        (sessions) => InsightBuilder.build(
          sessions.where((s) => !s.startedAt.isBefore(from)).toList(),
          today,
        ),
      );
});

/// Переключает отметку выполнения привычки за сегодня.
final toggleHabitProvider =
    Provider<Future<void> Function(String habitId, bool done)>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final today = ref.watch(todayProvider);
  return (habitId, done) async {
    await repository.setCompletion(
      habitId: habitId,
      day: today,
      done: done,
    );
    // Опыт начисляется только за закрытие цели. Снятие галочки его не
    // отбирает: отменённая по ошибке отметка не должна стоить прогресса, а
    // накрутить так можно разве что самого себя.
    if (done) await ref.read(gameHabitRecorderProvider)();
  };
});

/// Замораживает или снимает заморозку сегодняшнего дня.
///
/// Возвращает `false`, если заморозку потратить нельзя: лимит по частоте
/// ещё не истёк. Экран по этому ответу решает, показать ли отказ, —
/// молча проигнорированный тап выглядел бы поломкой.
final toggleFreezeProvider =
    Provider<Future<bool> Function(String habitId, bool frozen)>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final today = ref.watch(todayProvider);
  return (habitId, frozen) => repository.setFreeze(
        habitId: habitId,
        day: today,
        frozen: frozen,
      );
});
