import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texfi_fokus/data/recommendation/bandit_recommendation_engine.dart';
import 'package:texfi_fokus/data/settings/custom_presets_store.dart';
import 'package:texfi_fokus/domain/entities/custom_preset.dart';
import 'package:texfi_fokus/domain/entities/focus_technique.dart';
import 'package:texfi_fokus/domain/entities/mood.dart';
import 'package:texfi_fokus/domain/entities/recommendation.dart';
import 'package:texfi_fokus/domain/entities/recommendation_weight_entity.dart';
import 'package:texfi_fokus/domain/entities/session_entity.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';
import 'package:texfi_fokus/domain/entities/technique_arm.dart';
import 'package:texfi_fokus/domain/repositories/recommendation_weight_repository.dart';
import 'package:texfi_fokus/domain/repositories/session_repository.dart';

/// Веса в памяти — движок проверяется без Drift: он про арифметику
/// распределений, а не про SQL.
class _MemoryWeights implements RecommendationWeightRepository {
  final Map<String, List<RecommendationWeightEntity>> rows = {};

  @override
  Future<List<RecommendationWeightEntity>> weightsForContext(String key) async =>
      rows[key] ?? const [];

  @override
  Future<Map<String, List<RecommendationWeightEntity>>> weightsForContexts(
    List<String> keys,
  ) async =>
      {for (final k in keys) k: rows[k] ?? const []};

  @override
  Future<List<RecommendationWeightEntity>> allWeights() async =>
      [for (final list in rows.values) ...list];

  @override
  Future<void> clear() async => rows.clear();

  @override
  Future<void> upsertWeight(RecommendationWeightEntity weight) async {
    final list = rows.putIfAbsent(weight.contextKey, () => []);
    list.removeWhere((w) => w.techniqueKey == weight.techniqueKey);
    list.add(weight);
  }
}

class _StubSessions implements SessionRepository {
  _StubSessions(this.total);

  final int total;

  @override
  Future<int> totalSessionCount() async => total;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SessionEntity _session({
  required FocusTechnique technique,
  String? customKey,
  required bool success,
  required String contextKey,
}) {
  return SessionEntity(
    id: 'x',
    taskTitle: 't',
    category: TaskCategory.work,
    difficulty: TaskDifficulty.medium,
    mood: Mood.neutral,
    technique: technique,
    customTechniqueKey: customKey,
    plannedFocusMinutes: 35,
    plannedBreakMinutes: 7,
    plannedCycles: 3,
    actualFocusSeconds: 35 * 60,
    outcome: success ? SessionOutcome.completed : SessionOutcome.aborted,
    startedAt: DateTime(2026, 3, 1, 10),
    endedAt: DateTime(2026, 3, 1, 11),
    contextKey: contextKey,
  );
}

void main() {
  group('пресет как ключ', () {
    test('ключ пресета не пересекается с именами встроенных техник', () {
      const preset = CustomPreset(
        id: 'abc',
        name: '35/7',
        focusMinutes: 35,
        breakMinutes: 7,
        cycles: 3,
      );
      expect(preset.key, 'custom:abc');
      expect(CustomPreset.isCustomKey(preset.key), isTrue);
      expect(CustomPreset.idFromKey(preset.key), 'abc');

      for (final t in FocusTechnique.values) {
        expect(CustomPreset.isCustomKey(t.key), isFalse);
        expect(t.key, isNot(preset.key));
      }
    });

    test('сессия по пресету не выдаёт себя за встроенную технику', () {
      final s = _session(
        technique: FocusTechnique.pomodoro2505,
        customKey: 'custom:abc',
        success: true,
        contextKey: 'k',
      );
      // Именно это разделение спасает статистику помидора: enum — подложка,
      // а ключ — правда.
      expect(s.technique, FocusTechnique.pomodoro2505);
      expect(s.techniqueKey, 'custom:abc');
      expect(s.isCustomTechnique, isTrue);
    });

    test('сессия без пресета отдаёт ключ встроенной техники', () {
      final s = _session(
        technique: FocusTechnique.deepWork90,
        success: true,
        contextKey: 'k',
      );
      expect(s.techniqueKey, 'deepWork90');
      expect(s.isCustomTechnique, isFalse);
    });

    test('значения за границами подрезаются, а не принимаются как есть', () {
      const wild = CustomPreset(
        id: 'a',
        name: '  дикий  ',
        focusMinutes: 9000,
        breakMinutes: -5,
        cycles: 0,
      );
      final ok = wild.normalized();
      expect(ok.focusMinutes, CustomPreset.maxFocusMinutes);
      expect(ok.breakMinutes, 0);
      expect(ok.cycles, 1);
      expect(ok.name, 'дикий');
    });
  });

  group('обучение по пресету', () {
    test('исход пресета пишется в его ключ, а не в ближайшую технику',
        () async {
      final weights = _MemoryWeights();
      final engine = BanditRecommendationEngine(
        weights: weights,
        sessions: _StubSessions(50),
      );

      const context = RecommendationContext(
        mood: Mood.neutral,
        category: TaskCategory.work,
        difficulty: TaskDifficulty.medium,
        timeOfDay: TimeOfDayBucket.morning,
        weekday: 1,
      );

      await engine.recordOutcome(
        _session(
          technique: FocusTechnique.pomodoro2505,
          customKey: 'custom:abc',
          success: true,
          contextKey: context.key,
        ),
      );

      final stored = weights.rows[context.key]!;
      expect(
        stored.map((w) => w.techniqueKey),
        contains('custom:abc'),
      );
      // Главное утверждение всего файла: статистика помидора осталась
      // нетронутой, хотя enum сессии указывал именно на него.
      expect(
        stored.map((w) => w.techniqueKey),
        isNot(contains('pomodoro2505')),
      );
    });

    test('движок может предложить пресет наравне со встроенными', () async {
      final weights = _MemoryWeights();
      const preset = CustomPreset(
        id: 'abc',
        name: '35/7',
        focusMinutes: 35,
        breakMinutes: 7,
        cycles: 3,
      );

      const context = RecommendationContext(
        mood: Mood.neutral,
        category: TaskCategory.work,
        difficulty: TaskDifficulty.medium,
        timeOfDay: TimeOfDayBucket.morning,
        weekday: 1,
      );

      final engine = BanditRecommendationEngine(
        weights: weights,
        sessions: _StubSessions(50),
        presets: () => const [preset],
        random: Random(7),
      );

      // Кормим пресет только успехами, встроенные — только провалами.
      for (var i = 0; i < 40; i++) {
        await engine.recordOutcome(
          _session(
            technique: FocusTechnique.pomodoro2505,
            customKey: preset.key,
            success: true,
            contextKey: context.key,
          ),
        );
        for (final t in FocusTechnique.values) {
          await engine.recordOutcome(
            _session(technique: t, success: false, contextKey: context.key),
          );
        }
      }

      // Пресет должен выигрывать на подавляющем большинстве розыгрышей.
      var presetWins = 0;
      for (var i = 0; i < 40; i++) {
        final r = await engine.recommend(context);
        if (r.preset?.id == preset.id) presetWins++;
      }

      expect(presetWins, greaterThan(25));
    });

    test('рекомендация пресета несёт его длительности, а не встроенные',
        () async {
      const preset = CustomPreset(
        id: 'abc',
        name: '35/7',
        focusMinutes: 35,
        breakMinutes: 7,
        cycles: 3,
      );
      final arm = TechniqueArm.custom(preset);
      final r = Recommendation.ofArm(
        arm,
        reason: RecommendationReason.learned,
      );

      expect(r.focusMinutes, 35);
      expect(r.breakMinutes, 7);
      expect(r.cycles, 3);
      expect(r.techniqueKey, 'custom:abc');
      expect(r.preset, preset);
    });

    test('удалённый пресет не роняет разбор ключа', () {
      final arm = TechniqueArm.fromKey('custom:gone', const []);
      expect(arm.isCustom, isFalse);
      expect(arm.technique, FocusTechnique.pomodoro2505);
    });
  });

  group('хранилище пресетов', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('пресет переживает перезапуск', () async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = CustomPresetsNotifier(prefs);
      await notifier.add(
        const CustomPreset(
          id: 'a',
          name: '35/7',
          focusMinutes: 35,
          breakMinutes: 7,
          cycles: 3,
        ),
      );

      final reloaded = CustomPresetsNotifier(prefs);
      expect(reloaded.state, hasLength(1));
      expect(reloaded.state.single.name, '35/7');
      expect(reloaded.state.single.focusMinutes, 35);
    });

    test('лимит пресетов не обходится', () async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = CustomPresetsNotifier(prefs);
      for (var i = 0; i < CustomPreset.maxPresets; i++) {
        expect(
          await notifier.add(
            CustomPreset(
              id: '$i',
              name: 'p$i',
              focusMinutes: 20,
              breakMinutes: 5,
              cycles: 2,
            ),
          ),
          isTrue,
        );
      }
      expect(
        await notifier.add(
          const CustomPreset(
            id: 'over',
            name: 'over',
            focusMinutes: 20,
            breakMinutes: 5,
            cycles: 2,
          ),
        ),
        isFalse,
      );
      expect(notifier.state, hasLength(CustomPreset.maxPresets));
    });

    test('одна битая запись не уносит остальные', () async {
      SharedPreferences.setMockInitialValues({
        CustomPresetsNotifier.prefsKey: jsonEncode([
          {'id': 'ok', 'name': 'ok', 'focusMinutes': 30,
            'breakMinutes': 5, 'cycles': 2},
          {'id': 'broken'},
          'не объект вовсе',
        ]),
      });
      final prefs = await SharedPreferences.getInstance();
      expect(CustomPresetsNotifier(prefs).state.map((p) => p.id), ['ok']);
    });

    test('мусор вместо JSON читается как пустой список', () async {
      SharedPreferences.setMockInitialValues({
        CustomPresetsNotifier.prefsKey: 'не json',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(CustomPresetsNotifier(prefs).state, isEmpty);
    });

    test('удаление убирает только свой пресет', () async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = CustomPresetsNotifier(prefs);
      await notifier.add(const CustomPreset(
          id: 'a', name: 'a', focusMinutes: 20, breakMinutes: 5, cycles: 2));
      await notifier.add(const CustomPreset(
          id: 'b', name: 'b', focusMinutes: 40, breakMinutes: 8, cycles: 2));
      await notifier.remove('a');
      expect(notifier.state.map((p) => p.id), ['b']);
    });
  });
}
