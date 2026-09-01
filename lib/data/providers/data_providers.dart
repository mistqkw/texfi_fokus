import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/notifications/notification_service.dart';
import '../../domain/entities/recommendation_engine.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/mood_repository.dart';
import '../../domain/repositories/planner_repository.dart';
import '../../domain/repositories/recommendation_weight_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../local/database.dart';
import '../local/export_service.dart';
import '../recommendation/bandit_recommendation_engine.dart';
import '../repositories/game_repository_impl.dart';
import '../repositories/habit_repository_impl.dart';
import '../repositories/mood_repository_impl.dart';
import '../repositories/planner_repository_impl.dart';
import '../repositories/recommendation_weight_repository_impl.dart';
import '../repositories/session_repository_impl.dart';
import '../repositories/task_repository_impl.dart';

/// Переопределяется в `main()` уже загруженным экземпляром — так настройки
/// доступны синхронно с первого кадра, без экрана загрузки.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(ref.watch(databaseProvider));
});

/// Игровой слой. Отдельный репозиторий поверх той же базы: он читает итоги
/// сессий и привычек, но пишет только в свои три таблицы.
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(ref.watch(databaseProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(databaseProvider));
});

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return PlannerRepositoryImpl(ref.watch(databaseProvider));
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl(ref.watch(databaseProvider));
});

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepositoryImpl(ref.watch(databaseProvider));
});

final recommendationWeightRepositoryProvider =
    Provider<RecommendationWeightRepository>((ref) {
  return RecommendationWeightRepositoryImpl(ref.watch(databaseProvider));
});

/// Реализация движка подменяется здесь одной строкой — ни один экран об этом
/// не узнает: они видят только интерфейс `RecommendationEngine`.
final recommendationEngineProvider = Provider<RecommendationEngine>((ref) {
  return BanditRecommendationEngine(
    weights: ref.watch(recommendationWeightRepositoryProvider),
    sessions: ref.watch(sessionRepositoryProvider),
  );
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(databaseProvider));
});
