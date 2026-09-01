import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/providers/data_providers.dart';
import '../../domain/entities/mood.dart';
import '../../domain/entities/mood_entry_entity.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/session_guards.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_entity.dart';
import '../timer/session_guard_providers.dart';

const _uuid = Uuid();

/// Черновик будущей сессии: то, что пользователь набрал на check-in и что
/// затем читают экран рекомендации и экран таймера.
class SessionDraft {
  const SessionDraft({
    this.mood = Mood.neutral,
    this.taskId,
    this.taskTitle = '',
    this.category = TaskCategory.other,
    this.difficulty = TaskDifficulty.medium,
    this.moodEntryId,
  });

  final Mood mood;
  final String? taskId;
  final String taskTitle;
  final TaskCategory category;
  final TaskDifficulty difficulty;

  /// Id записанной отметки настроения — к ней потом привяжется сессия.
  final String? moodEntryId;

  bool get isValid => taskTitle.trim().isNotEmpty;

  RecommendationContext get context => RecommendationContext.now(
        mood: mood,
        category: category,
        difficulty: difficulty,
      );

  SessionDraft copyWith({
    Mood? mood,
    String? taskId,
    bool clearTaskId = false,
    String? taskTitle,
    TaskCategory? category,
    TaskDifficulty? difficulty,
    String? moodEntryId,
  }) {
    return SessionDraft(
      mood: mood ?? this.mood,
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      taskTitle: taskTitle ?? this.taskTitle,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      moodEntryId: moodEntryId ?? this.moodEntryId,
    );
  }
}

class SessionDraftNotifier extends StateNotifier<SessionDraft> {
  SessionDraftNotifier(this._ref) : super(const SessionDraft());

  final Ref _ref;

  void reset() => state = const SessionDraft();

  void setMood(Mood mood) => state = state.copyWith(mood: mood);

  /// Выбор существующей задачи подтягивает её категорию и сложность —
  /// пользователю не нужно вводить их заново.
  void selectTask(TaskEntity task) {
    state = state.copyWith(
      taskId: task.id,
      taskTitle: task.title,
      category: task.category,
      difficulty: task.difficulty,
    );
  }

  /// Ввод свободного текста отвязывает черновик от сохранённой задачи.
  void setTitle(String title) =>
      state = state.copyWith(taskTitle: title, clearTaskId: true);

  void setCategory(TaskCategory category) =>
      state = state.copyWith(category: category);

  void setDifficulty(TaskDifficulty difficulty) =>
      state = state.copyWith(difficulty: difficulty);

  /// Записывает отметку настроения. Делается сразу после переключателя, ещё
  /// до выбора задачи: даже если пользователь передумает и закроет экран,
  /// сам факт «проверился и ушёл» останется в истории.
  Future<void> recordMood() async {
    final id = _uuid.v4();
    await _ref.read(moodRepositoryProvider).addEntry(
          MoodEntryEntity(id: id, mood: state.mood, recordedAt: DateTime.now()),
        );
    state = state.copyWith(moodEntryId: id);
  }

  /// Сохраняет введённую задачу, если её ещё нет в базе, и возвращает её id.
  Future<String?> persistTask() async {
    final title = state.taskTitle.trim();
    if (title.isEmpty) return null;

    final repository = _ref.read(taskRepositoryProvider);
    if (state.taskId != null) {
      await repository.touchTask(state.taskId!);
      return state.taskId;
    }

    final id = _uuid.v4();
    await repository.createTask(
      TaskEntity(
        id: id,
        title: title,
        category: state.category,
        difficulty: state.difficulty,
        createdAt: DateTime.now(),
        lastUsedAt: DateTime.now(),
      ),
    );
    state = state.copyWith(taskId: id);
    return id;
  }
}

final sessionDraftProvider =
    StateNotifierProvider<SessionDraftNotifier, SessionDraft>((ref) {
  return SessionDraftNotifier(ref);
});

final tasksProvider = StreamProvider<List<TaskEntity>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTasks();
});

/// Рекомендация для текущего черновика. Пересчитывается при каждом входе на
/// экран: бандит стохастический, и повторный запрос — это честная новая
/// выборка, а не кеш.
final recommendationProvider =
    FutureProvider.autoDispose<Recommendation>((ref) async {
  final draft = ref.watch(sessionDraftProvider);
  final recommendation =
      await ref.watch(recommendationEngineProvider).recommend(draft.context);

  // Ночной кап применяется поверх движка, а не внутри него: это не вывод из
  // статистики, а внешнее правило, и движку не за что учить его как знание
  // о пользователе.
  final capHour = ref.watch(effectiveNightCapHourProvider);
  if (capHour == null) return recommendation;
  return SessionGuards.capForNight(
    recommendation,
    hour: DateTime.now().hour,
    capHour: capHour,
  );
});
