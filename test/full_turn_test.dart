import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/presentation/shared/full_turn_detector.dart';

/// Полный оборот крутилки — жест, который очень легко «поймать» слишком
/// охотно: обычная подкрутка времени туда-сюда набирает те же радианы по
/// модулю. Поэтому именно эта арифметика проверяется отдельно.
void main() {
  const turn = 2 * math.pi;

  /// Прокручивает [radians] мелкими шагами — как настоящий жест, а не одним
  /// скачком: одним событием на весь круг это не приходит никогда.
  int stepsThrough(FullTurnDetector detector, double radians, {int steps = 40}) {
    var fired = 0;
    for (var i = 0; i < steps; i++) {
      if (detector.add(radians / steps)) fired++;
    }
    return fired;
  }

  test('полный круг за одно движение засчитывается один раз', () {
    final detector = FullTurnDetector()..start();
    expect(stepsThrough(detector, turn), 1);
  });

  test('чуть меньше круга не засчитывается', () {
    final detector = FullTurnDetector()..start();
    expect(stepsThrough(detector, turn * 0.98), 0);
  });

  test('два круга подряд, не отрывая пальца, — два раза', () {
    final detector = FullTurnDetector()..start();
    expect(stepsThrough(detector, turn * 2, steps: 80), 2);
  });

  test('круг по частям, с отрывом пальца, не считается', () {
    final detector = FullTurnDetector();
    var fired = 0;
    // Четыре четверти круга — но каждая отдельным жестом.
    for (var i = 0; i < 4; i++) {
      detector.start();
      fired += stepsThrough(detector, turn / 4, steps: 10);
      detector.end();
    }
    expect(fired, 0);
  });

  test('движение туда-обратно кругом не становится', () {
    final detector = FullTurnDetector()..start();
    var fired = 0;
    // Полкруга вперёд и полкруга назад: по модулю набрано ровно 2pi, но
    // человек вернулся туда, откуда начал, и оборота не сделал.
    fired += stepsThrough(detector, turn / 2);
    fired += stepsThrough(detector, -turn / 2);
    expect(fired, 0);
  });

  test('круг в обратную сторону тоже круг', () {
    final detector = FullTurnDetector()..start();
    expect(stepsThrough(detector, -turn), 1);
  });

  test('после отматывания назад следующий полный круг снова считается', () {
    final detector = FullTurnDetector()..start();
    expect(stepsThrough(detector, turn), 1);
    expect(stepsThrough(detector, -turn), 0);
    // Вернулись в ноль — и ушли на полный круг в другую сторону.
    expect(stepsThrough(detector, -turn), 1);
  });

  test('start обнуляет накопленное', () {
    final detector = FullTurnDetector()..start();
    stepsThrough(detector, turn * 0.9);
    detector.start();
    expect(stepsThrough(detector, turn * 0.5), 0);
    expect(detector.progress, closeTo(0.5, 0.01));
  });
}
