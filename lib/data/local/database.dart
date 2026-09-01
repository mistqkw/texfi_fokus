import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/habits_table.dart';
import 'tables/mood_entries_table.dart';
import 'tables/recommendation_weights_table.dart';
import 'tables/sessions_table.dart';
import 'tables/tasks_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Habits,
    HabitCompletions,
    HabitFreezes,
    Tasks,
    Sessions,
    MoodEntries,
    RecommendationWeights,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  /// Миграции только добавляют — существующие данные тестировщиков и первых
  /// пользователей переживают обновление. Пересоздание таблиц здесь
  /// недопустимо: история сессий и стрики восстановлению не подлежат.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // v2: более богатый сигнал о сессии — причина прерывания, заметка
          // и признак «пользователь переопределил рекомендацию вручную».
          if (from < 2) {
            await m.addColumn(sessions, sessions.wasManualOverride);
            await m.addColumn(sessions, sessions.interruptionReason);
            await m.addColumn(sessions, sessions.sessionNote);
          }

          // v3: гибкая частота привычек, награда за стрик и заморозки.
          if (from < 3) {
            await m.addColumn(habits, habits.frequencyType);
            await m.addColumn(habits, habits.timesPerWeek);
            await m.addColumn(habits, habits.reward);
            await m.addColumn(habits, habits.rewardStreakDays);
            await m.addColumn(habits, habits.freezeIntervalDays);
            await m.createTable(habitFreezes);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'texfi_fokus');
  }
}
