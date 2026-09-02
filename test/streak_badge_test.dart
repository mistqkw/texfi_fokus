import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/domain/entities/habit_entity.dart';

/// Значок долгого стрика ничего не объявляет, поэтому ошибиться в его
/// ступенях можно надолго и незаметно: неверный порог просто не покажет
/// метку тому, кто её заслужил.
void main() {
  test('до первого порога значка нет', () {
    expect(StreakBadge.tierFor(0), 0);
    expect(StreakBadge.tierFor(1), 0);
    expect(StreakBadge.tierFor(29), 0);
  });

  test('ступень появляется ровно на пороге', () {
    expect(StreakBadge.tierFor(30), 1);
    expect(StreakBadge.tierFor(100), 2);
    expect(StreakBadge.tierFor(365), 3);
  });

  test('между порогами ступень держится', () {
    expect(StreakBadge.tierFor(31), 1);
    expect(StreakBadge.tierFor(99), 1);
    expect(StreakBadge.tierFor(101), 2);
    expect(StreakBadge.tierFor(364), 2);
  });

  test('выше последнего порога ступень не растёт', () {
    expect(StreakBadge.tierFor(366), StreakBadge.tierCount);
    expect(StreakBadge.tierFor(10000), StreakBadge.tierCount);
  });

  test('на отрицательном стрике не падает', () {
    expect(StreakBadge.tierFor(-1), 0);
  });

  test('пороги идут по возрастанию', () {
    for (var i = 1; i < StreakBadge.thresholds.length; i++) {
      expect(
        StreakBadge.thresholds[i],
        greaterThan(StreakBadge.thresholds[i - 1]),
      );
    }
  });
}
