import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/data/local/database.dart';
import 'package:texfi_fokus/data/repositories/game_repository_impl.dart';
import 'package:texfi_fokus/domain/entities/game_entities.dart';
import 'package:texfi_fokus/domain/entities/game_rules.dart';
import 'package:texfi_fokus/domain/entities/mood.dart';
import 'package:texfi_fokus/domain/entities/task_category.dart';

/// Генератор с заранее заданными ответами: настоящая случайность здесь
/// проверялась бы вечно и всё равно ничего не доказала бы. Нужны обе ветки —
/// и «выпало», и «не выпало», — причём именно тогда, когда мы их ждём.
class _ScriptedRandom implements Random {
  _ScriptedRandom(this._answers);

  final List<int> _answers;
  int _at = 0;

  @override
  int nextInt(int max) {
    if (_at >= _answers.length) return 1;
    return _answers[_at++] % max;
  }

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

void main() {
  group('бросок на редкую окраску', () {
    test('срабатывает ровно на нуле и только для обычного дрифера', () {
      expect(
        GameRules.rollGolden(_ScriptedRandom([0]), kind: MapNodeKind.drifter),
        isTrue,
      );
      expect(
        GameRules.rollGolden(_ScriptedRandom([1]), kind: MapNodeKind.drifter),
        isFalse,
      );
      // Босс редким не бывает ни при каком броске: событие само по себе.
      expect(
        GameRules.rollGolden(_ScriptedRandom([0]), kind: MapNodeKind.boss),
        isFalse,
      );
    });

    test('на настоящем генераторе остаётся редким, но случается', () {
      final random = Random(20260901);
      var hits = 0;
      for (var i = 0; i < 24000; i++) {
        if (GameRules.rollGolden(random, kind: MapNodeKind.drifter)) hits++;
      }
      // Ожидание — 1000 на 24000 бросков. Границы широкие: тест проверяет
      // порядок величины, а не качество генератора.
      expect(hits, greaterThan(800));
      expect(hits, lessThan(1200));
    });

    test('надбавка мала настолько, что не сдвигает темп уровней', () {
      // Мера «маленького» здесь одна: обычная получасовая сессия должна
      // стоить заметно больше, чем разовая надбавка за редкость. Иначе
      // выгоднее было бы искать редкость, а не работать.
      final ordinarySession = GameRules.xpForSession(
        focusSeconds: 25 * 60,
        difficulty: TaskDifficulty.medium,
        mood: Mood.neutral,
        completedFully: true,
      );
      expect(GameRules.goldenBonusXp, lessThan(ordinarySession ~/ 2));
      expect(GameRules.unstoppableBonusXp, lessThan(ordinarySession ~/ 2));

      // Ожидаемая прибавка за всю карту — девять дриферов с шансом один из
      // двадцати четырёх — не дотягивает даже до одного уровня.
      final expectedOverWholeMap = GameRules.goldenBonusXp * 9 / GameRules.goldenOneIn;
      expect(expectedOverWholeMap, lessThan(GameRules.xpToAdvance(1)));
    });
  });

  group('редкий дрифер на настоящей базе', () {
    late AppDatabase db;
    late DateTime now;

    Future<GameRepositoryImpl> gameWith(List<int> rolls) async {
      final game = GameRepositoryImpl(
        db,
        now: () => now,
        random: _ScriptedRandom(rolls),
      );
      await game.setEnabled(true);
      return game;
    }

    setUp(() {
      now = DateTime(2026, 3, 1, 12);
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test('первый узел карты получает окраску по броску и хранит её', () async {
      final game = await gameWith([0]);
      final node = await game.currentNode();
      expect(node!.golden, isTrue);

      // Перечитывание — не то же самое, что чтение из памяти: окраска должна
      // лежать в базе, иначе противник менял бы цвет при перезапуске.
      final again = await game.mapNodes();
      expect(again.first.golden, isTrue);
    });

    test('обычный узел остаётся обычным', () async {
      final game = await gameWith([7]);
      expect((await game.currentNode())!.golden, isFalse);
    });

    test('победа над редким дрифером даёт надбавку, обычный — нет', () async {
      Future<int> xpForFirstKill(List<int> rolls) async {
        final fresh = AppDatabase.forTesting(NativeDatabase.memory());
        final game = GameRepositoryImpl(
          fresh,
          now: () => now,
          random: _ScriptedRandom(rolls),
        );
        await game.setEnabled(true);
        final result = await game.applySession(
          focusSeconds: 60 * 60,
          difficulty: TaskDifficulty.medium,
          mood: Mood.neutral,
          completedFully: true,
        );
        expect(result.outcome, EncounterOutcome.drifterDefeated);
        await fresh.close();
        return result.xpGained;
      }

      final golden = await xpForFirstKill([0]);
      final plain = await xpForFirstKill([5]);
      expect(golden - plain, GameRules.goldenBonusXp);
    });

    test('недобитый редкий дрифер надбавки ещё не приносит', () async {
      final game = await gameWith([0]);
      final result = await game.applySession(
        focusSeconds: 5 * 60,
        difficulty: TaskDifficulty.medium,
        mood: Mood.neutral,
        completedFully: true,
      );
      expect(result.outcome, EncounterOutcome.damaged);
      expect(result.xpGained, GameRules.xpForSession(
        focusSeconds: 5 * 60,
        difficulty: TaskDifficulty.medium,
        mood: Mood.neutral,
        completedFully: true,
      ));
    });

    test('надбавка сверху ограничена потолком и не даётся пустой сессии',
        () async {
      final game = await gameWith([9]);

      // Запрошено вдесятеро больше потолка — начислено ровно по потолку.
      final greedy = await game.applySession(
        focusSeconds: 10 * 60,
        difficulty: TaskDifficulty.medium,
        mood: Mood.neutral,
        completedFully: true,
        bonusXp: GameRules.unstoppableBonusXp * 10,
      );
      final base = GameRules.xpForSession(
        focusSeconds: 10 * 60,
        difficulty: TaskDifficulty.medium,
        mood: Mood.neutral,
        completedFully: true,
      );
      expect(greedy.xpGained, base + GameRules.unstoppableBonusXp);

      // Сессия короче минуты не заработала ничего — надбавлять не к чему.
      final empty = await game.applySession(
        focusSeconds: 30,
        difficulty: TaskDifficulty.medium,
        mood: Mood.neutral,
        completedFully: true,
        bonusXp: GameRules.unstoppableBonusXp,
      );
      expect(empty.xpGained, 0);
    });
  });
}
