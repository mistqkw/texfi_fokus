import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/providers/data_providers.dart';
import '../../domain/entities/game_entities.dart';
import '../../domain/entities/game_rules.dart';
import '../../domain/entities/mood.dart';
import '../../domain/entities/task_category.dart';

/// Провайдеры игрового слоя — той же рукописной формы, что и весь остальной
/// Riverpod в проекте: никаких генераторов и хуков.
///
/// Все они читают из игрового репозитория и ни один не трогает движок
/// рекомендаций: `BanditRecommendationEngine` про игру не знает вовсе и
/// продолжает учиться ровно на том же сигнале, что и раньше.

/// Включён ли игровой режим. Поток, а не разовое чтение: переключатель в
/// настройках должен мгновенно менять и таббар, и экран рекомендации.
final gameModeEnabledProvider = StreamProvider<bool>((ref) {
  return ref.watch(gameRepositoryProvider).watchEnabled();
});

/// Удобная синхронная форма для мест, где ждать поток нечем: пока значение
/// не приехало, считаем режим выключённым — обычный трекер по умолчанию.
final gameModeOnProvider = Provider<bool>((ref) {
  return ref.watch(gameModeEnabledProvider).valueOrNull ?? false;
});

final playerProgressProvider = StreamProvider<PlayerProgressEntity>((ref) {
  return ref.watch(gameRepositoryProvider).watchProgress();
});

final mapNodesProvider = StreamProvider<List<MapNodeEntity>>((ref) {
  final repository = ref.watch(gameRepositoryProvider);

  // Карта заводится и здесь, а не только при включении режима. Включённый
  // флаг без карты — состояние достижимое (импорт чужой базы, ручная правка,
  // оборванная миграция), и в нём экран карты крутил бы спиннер вечно.
  // `ensureInitialized` идемпотентна, поэтому лишний вызов ничего не стоит.
  ref.read(gameRepositoryProvider).isEnabled().then((enabled) {
    if (enabled) repository.ensureInitialized();
  });

  return repository.watchMap();
});

/// Текущий противник — то, против кого пойдёт следующая сессия.
///
/// Считается из того же потока, что и карта, а не отдельным запросом: две
/// подписки на одно состояние неизбежно разъезжаются на кадр-другой, и
/// экран рекомендации показывал бы одного дрифера, а карта — другого.
final currentNodeProvider = Provider<MapNodeEntity?>((ref) {
  final nodes = ref.watch(mapNodesProvider).valueOrNull;
  if (nodes == null) return null;
  for (final node in nodes) {
    if (node.status == MapNodeStatus.current) return node;
  }
  return null;
});

/// Узлы, сгруппированные по мирам, — в том виде, в каком их рисует карта.
final worldsProvider = Provider<List<List<MapNodeEntity>>>((ref) {
  final nodes = ref.watch(mapNodesProvider).valueOrNull ?? const [];
  final worlds = <int, List<MapNodeEntity>>{};
  for (final node in nodes) {
    worlds.putIfAbsent(node.world, () => []).add(node);
  }
  final keys = worlds.keys.toList()..sort();
  return [for (final key in keys) worlds[key]!];
});

/// Итог последнего захода — то, что интерфейс ещё не показал пользователю.
///
/// Живёт отдельным состоянием, потому что показать его нужно один раз и в
/// подходящий момент: экран победы над боссом посреди сохранения сессии
/// выглядел бы как сбой. Забравший его экран обязан сбросить состояние.
class LastEncounterNotifier extends StateNotifier<EncounterResult?> {
  LastEncounterNotifier() : super(null);

  void set(EncounterResult result) {
    // Пустые заходы не показываем: «ничего не произошло» — не новость.
    if (!result.isSomething) return;
    state = result;
  }

  void clear() => state = null;
}

final lastEncounterProvider =
    StateNotifierProvider<LastEncounterNotifier, EncounterResult?>((ref) {
  return LastEncounterNotifier();
});

/// Разносит итог сессии по игровому слою и запоминает его для показа.
///
/// Вызывается после того, как сессия уже сохранена и скормлена движку
/// рекомендаций: игра — надстройка, и её сбой не должен ставить под удар
/// основную запись. Поэтому ошибки здесь глотаются: потерянное очко опыта
/// — неприятность, потерянная сессия — потеря данных.
final gameSessionRecorderProvider = Provider<
    Future<EncounterResult> Function({
  required int focusSeconds,
  required TaskDifficulty difficulty,
  required Mood mood,
  required bool completedFully,
  TaskCategory category,
  int bonusXp,
})>((ref) {
  return ({
    required int focusSeconds,
    required TaskDifficulty difficulty,
    required Mood mood,
    required bool completedFully,
    TaskCategory category = TaskCategory.other,
    int bonusXp = 0,
  }) async {
    try {
      final result = await ref.read(gameRepositoryProvider).applySession(
            focusSeconds: focusSeconds,
            difficulty: difficulty,
            mood: mood,
            completedFully: completedFully,
            category: category,
            bonusXp: bonusXp,
          );
      ref.read(lastEncounterProvider.notifier).set(result);
      return result;
    } catch (error, stack) {
      debugPrint('applySession to game layer failed: $error\n$stack');
      return const EncounterResult.none();
    }
  };
});

/// Опыт за закрытую привычку. Отдельно от сессий: привычка не заход на
/// узел, урона она не наносит и экранов не открывает.
final gameHabitRecorderProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    try {
      await ref.read(gameRepositoryProvider).applyHabitCompletion();
    } catch (error, stack) {
      debugPrint('applyHabitCompletion failed: $error\n$stack');
    }
  };
});

/// Какой мир человеку уже представляли заставкой.
///
/// Живёт в SharedPreferences, а не в Drift: это не данные о прогрессе, а
/// память интерфейса о том, что он уже показывал. В схеме прогресса такой
/// записи делать нечего — по ней ничего не считается, и при экспорте её
/// незачем переносить.
///
/// Хранится номер последнего представленного мира, а не список: миры
/// открываются строго по порядку, и одного числа достаточно.
class WorldIntroNotifier extends StateNotifier<int> {
  WorldIntroNotifier(this._prefs) : super(_prefs.getInt(_key) ?? 0);

  static const String _key = 'game.world_intro_seen';

  final SharedPreferences _prefs;

  /// Отмечает мир представленным. Возвращает `false`, если он уже был
  /// показан — тогда заставку открывать не нужно.
  bool markSeen(int world) {
    if (world <= state) return false;
    state = world;
    _prefs.setInt(_key, world);
    return true;
  }
}

final worldIntroProvider =
    StateNotifierProvider<WorldIntroNotifier, int>((ref) {
  return WorldIntroNotifier(ref.watch(sharedPreferencesProvider));
});
