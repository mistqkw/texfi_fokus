import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/data_providers.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/statistics.dart';
import '../home/home_providers.dart';

enum StatsRange {
  week(days: 7),
  month(days: 30);

  const StatsRange({required this.days});

  final int days;
}

final statsRangeProvider = StateProvider<StatsRange>((ref) => StatsRange.week);

/// Начало выбранного периода. Конец — всегда сегодня.
final statsFromProvider = Provider<DateTime>((ref) {
  final today = ref.watch(todayProvider);
  final range = ref.watch(statsRangeProvider);
  return today.subtract(Duration(days: range.days - 1));
});

final statsSummaryProvider = StreamProvider<FocusSummary>((ref) {
  return ref.watch(sessionRepositoryProvider).watchSummary(
        ref.watch(statsFromProvider),
        ref.watch(todayProvider),
      );
});

final statsDailyFocusProvider = StreamProvider<List<DailyFocus>>((ref) {
  return ref.watch(sessionRepositoryProvider).watchDailyFocus(
        ref.watch(statsFromProvider),
        ref.watch(todayProvider),
      );
});

/// Heatmap всегда показывает последние ~15 недель независимо от выбранного
/// периода: смысл календаря именно в длинной перспективе.
final heatmapDaysProvider = StreamProvider<List<DailyFocus>>((ref) {
  final today = ref.watch(todayProvider);
  return ref.watch(sessionRepositoryProvider).watchDailyFocus(
        today.subtract(const Duration(days: 104)),
        today,
      );
});

final statsMoodProvider = StreamProvider<List<MoodOutcomeStat>>((ref) {
  return ref.watch(sessionRepositoryProvider).watchMoodStats(
        ref.watch(statsFromProvider),
        ref.watch(todayProvider),
      );
});

final statsCategoryProvider = StreamProvider<List<CategoryFocusStat>>((ref) {
  return ref.watch(sessionRepositoryProvider).watchCategoryStats(
        ref.watch(statsFromProvider),
        ref.watch(todayProvider),
      );
});

final statsHabitSuccessProvider =
    FutureProvider<List<HabitSuccessStat>>((ref) async {
  // Пересчитывается вместе с отметками привычек на сегодня.
  ref.watch(todayHabitsProvider);
  return ref.watch(habitRepositoryProvider).successStats(
        ref.watch(statsFromProvider),
        ref.watch(todayProvider),
      );
});

/// Сколько раз за период сработало «наказание». Пересчитывается вместе с
/// отметками привычек: блок обязан меняться сразу после закрытия цели.
final statsPunishmentProvider =
    FutureProvider<List<HabitPunishmentStat>>((ref) async {
  ref.watch(todayHabitsProvider);
  return ref.watch(habitRepositoryProvider).punishmentStats(
        ref.watch(statsFromProvider),
        ref.watch(todayProvider),
      );
});

final statsInterruptionProvider =
    StreamProvider<List<InterruptionReasonStat>>((ref) {
  return ref.watch(sessionRepositoryProvider).watchInterruptionStats(
        ref.watch(statsFromProvider),
        ref.watch(todayProvider),
      );
});

/// Сессии выбранного периода — лента истории под графиками.
///
/// Живой поток, а не разовый запрос: удалённая сессия должна исчезать из
/// списка сразу, а не после перезахода на вкладку.
///
/// Отбор идёт по уже загруженной ленте последних сессий, а не отдельным
/// запросом с диапазоном: этот же поток слушают защитные проверки перед
/// стартом, и две подписки на одни и те же строки означали бы два разных
/// представления об истории.
final statsSessionsProvider = StreamProvider<List<SessionEntity>>((ref) {
  final from = ref.watch(statsFromProvider);
  return ref
      .watch(sessionRepositoryProvider)
      .watchRecentSessions(limit: 200)
      .map(
        (sessions) => sessions
            .where((session) => !session.startedAt.isBefore(from))
            .toList(),
      );
});
