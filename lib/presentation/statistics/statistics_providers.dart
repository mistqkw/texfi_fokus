import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/data_providers.dart';
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
