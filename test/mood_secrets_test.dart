import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/domain/entities/game_rules.dart';
import 'package:texfi_fokus/domain/entities/late_night_pattern.dart';

class _ScriptedRandom implements Random {
  _ScriptedRandom(this._answers);

  final List<int> _answers;
  int _at = 0;

  @override
  int nextInt(int max) => _at >= _answers.length ? 1 : _answers[_at++] % max;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

void main() {
  group('редкий отклик переключателя настроения', () {
    test('срабатывает на нуле и молчит на всём остальном', () {
      expect(GameRules.rollUnstoppable(_ScriptedRandom([0])), isTrue);
      for (var answer = 1; answer < GameRules.unstoppableOneIn; answer++) {
        expect(GameRules.rollUnstoppable(_ScriptedRandom([answer])), isFalse);
      }
    });

    test('остаётся редким, но достижимым за один присест', () {
      final random = Random(4242);
      var hits = 0;
      for (var i = 0; i < 15000; i++) {
        if (GameRules.rollUnstoppable(random)) hits++;
      }
      expect(hits, greaterThan(800));
      expect(hits, lessThan(1200));
    });
  });

  group('длинные ночи', () {
    // Ночь называется по своему вечеру: и 23:30 первого, и 01:30 второго
    // относятся к одной и той же ночи.
    test('час ночи относится к предыдущему вечеру', () {
      expect(
        LateNightPattern.nightOf(DateTime(2026, 3, 2, 1, 30)),
        DateTime(2026, 3, 1),
      );
      expect(
        LateNightPattern.nightOf(DateTime(2026, 3, 1, 23, 30)),
        DateTime(2026, 3, 1),
      );
    });

    test('дневные и вечерние сессии ночными не считаются', () {
      expect(LateNightPattern.isLateNight(DateTime(2026, 3, 1, 14)), isFalse);
      expect(LateNightPattern.isLateNight(DateTime(2026, 3, 1, 22, 59)), isFalse);
      expect(LateNightPattern.isLateNight(DateTime(2026, 3, 1, 23)), isTrue);
      expect(LateNightPattern.isLateNight(DateTime(2026, 3, 2, 4, 59)), isTrue);
      // Пять утра — это уже «встал рано», а не «не ложился».
      expect(LateNightPattern.isLateNight(DateTime(2026, 3, 2, 5)), isFalse);
    });

    /// Три ночи подряд по две сессии, кончая ночью на [lastNight].
    List<DateTime> threeNights(DateTime lastNight) => [
          for (var back = 0; back < 3; back++) ...[
            lastNight.subtract(Duration(days: back)).add(
                  const Duration(hours: 23, minutes: 30),
                ),
            lastNight.subtract(Duration(days: back)).add(
                  const Duration(hours: 25),
                ),
          ],
        ];

    final now = DateTime(2026, 3, 4, 1, 30);

    test('три ночи подряд по две сессии — закономерность', () {
      expect(
        LateNightPattern.detect(threeNights(DateTime(2026, 3, 3)), now: now),
        isTrue,
      );
    });

    test('одна сессия за ночь ещё ничего не значит', () {
      final starts = [
        for (var back = 0; back < 5; back++)
          DateTime(2026, 3, 3 - back, 23, 40),
      ];
      expect(LateNightPattern.detect(starts, now: now), isFalse);
    });

    test('две ночи подряд — ещё не закономерность', () {
      final starts = threeNights(DateTime(2026, 3, 3))
        ..removeWhere((at) => LateNightPattern.nightOf(at) == DateTime(2026, 3, 1));
      expect(LateNightPattern.detect(starts, now: now), isFalse);
    });

    test('разрыв посреди цепочки её обрывает', () {
      final starts = [
        ...threeNights(DateTime(2026, 3, 3)).where(
          (at) => LateNightPattern.nightOf(at) != DateTime(2026, 3, 2),
        ),
      ];
      expect(LateNightPattern.detect(starts, now: now), isFalse);
    });

    test('давняя цепочка про сейчас ничего не говорит', () {
      expect(
        LateNightPattern.detect(threeNights(DateTime(2026, 2, 10)), now: now),
        isFalse,
      );
    });

    test('дневные сессии закономерность не создают и не ломают', () {
      final starts = [
        ...threeNights(DateTime(2026, 3, 3)),
        for (var back = 0; back < 10; back++) DateTime(2026, 3, 3 - back, 15),
      ];
      expect(LateNightPattern.detect(starts, now: now), isTrue);
      expect(
        LateNightPattern.detect(
          [for (var back = 0; back < 10; back++) DateTime(2026, 3, 3 - back, 15)],
          now: now,
        ),
        isFalse,
      );
    });

    test('пустая история не падает', () {
      expect(LateNightPattern.detect(const [], now: now), isFalse);
    });
  });
}
