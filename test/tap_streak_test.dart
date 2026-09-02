import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/presentation/shared/tap_streak.dart';

/// У счётчика быстрых нажатий есть ровно один способ ошибиться незаметно —
/// не сбрасываться на паузе. Тогда серия, растянутая на неделю, однажды
/// замкнётся сама собой, и человек получит экран, которого не звал.
void main() {
  final start = DateTime(2026, 9, 1, 12);

  test('серия из семи быстрых нажатий срабатывает на седьмом', () {
    final taps = TapStreak();
    for (var i = 0; i < 6; i++) {
      expect(
        taps.register(start.add(Duration(milliseconds: 200 * i))),
        isFalse,
        reason: 'нажатие ${i + 1} не должно ничего открывать',
      );
    }
    expect(taps.register(start.add(const Duration(milliseconds: 1200))), isTrue);
  });

  test('пауза дольше окна начинает счёт заново', () {
    final taps = TapStreak();
    for (var i = 0; i < 6; i++) {
      taps.register(start.add(Duration(milliseconds: 200 * i)));
    }
    // Отвлёкся на пару секунд — и это уже другая серия.
    expect(taps.register(start.add(const Duration(seconds: 5))), isFalse);
    expect(taps.count, 1);
  });

  test('редкие одиночные нажатия не накапливаются никогда', () {
    final taps = TapStreak();
    for (var day = 0; day < 30; day++) {
      expect(taps.register(start.add(Duration(days: day))), isFalse);
    }
    expect(taps.count, 1);
  });

  test('восьмое нажатие второй раз не срабатывает', () {
    final taps = TapStreak();
    var fired = 0;
    for (var i = 0; i < 9; i++) {
      if (taps.register(start.add(Duration(milliseconds: 200 * i)))) fired++;
    }
    expect(fired, 1);
  });

  test('две полные серии подряд срабатывают дважды', () {
    final taps = TapStreak();
    var fired = 0;
    for (var i = 0; i < 14; i++) {
      if (taps.register(start.add(Duration(milliseconds: 200 * i)))) fired++;
    }
    expect(fired, 2);
  });

  test('нажатие ровно на границе окна ещё считается', () {
    final taps = TapStreak(required: 2, window: const Duration(seconds: 1));
    taps.register(start);
    expect(taps.register(start.add(const Duration(seconds: 1))), isTrue);
  });

  test('на миллисекунду позже границы — уже нет', () {
    final taps = TapStreak(required: 2, window: const Duration(seconds: 1));
    taps.register(start);
    expect(
      taps.register(start.add(const Duration(seconds: 1, milliseconds: 1))),
      isFalse,
    );
  });
}
