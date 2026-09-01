import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/domain/entities/phase_clock.dart';

/// Арифметика обратного отсчёта, из-за которой таймер «не шёл» при
/// заблокированном экране. Раньше остаток уменьшался на каждый тик
/// `Timer.periodic`; система придерживала тики в фоне, и отсчёт отставал.
/// Теперь остаток — разность со стенными часами, и все проверки ниже про то,
/// что эта разность верна независимо от того, спрашивали её или нет.
void main() {
  final t0 = DateTime(2026, 3, 14, 10, 0, 0);

  group('PhaseClock — остаток по стенным часам', () {
    test('остаток не зависит от того, как часто его спрашивали', () {
      final clock = PhaseClock.startedAt(t0, const Duration(minutes: 25));

      // Один прыжок на двадцать минут вперёд — ровно то, что происходит,
      // когда телефон лежал заблокированным и ни один тик не пришёл.
      expect(
        clock.remainingAt(t0.add(const Duration(minutes: 20))),
        const Duration(minutes: 5),
      );
    });

    test('стоящие часы времени не набирают', () {
      const clock = PhaseClock.paused(Duration(minutes: 7));
      expect(clock.running, isFalse);
      expect(
        clock.remainingAt(t0.add(const Duration(hours: 3))),
        const Duration(minutes: 7),
      );
    });

    test('перелёт за конец фазы виден как отрицательный остаток', () {
      final clock = PhaseClock.startedAt(t0, const Duration(minutes: 5));
      expect(
        clock.remainingAt(t0.add(const Duration(minutes: 8))),
        const Duration(minutes: -3),
      );
      // ...но на табло уходит ноль, а не минус три.
      expect(
        clock.displayRemainingAt(t0.add(const Duration(minutes: 8))),
        Duration.zero,
      );
      expect(clock.isExpiredAt(t0.add(const Duration(minutes: 8))), isTrue);
    });

    test('переведённые назад часы устройства не отматывают таймер', () {
      final clock = PhaseClock.startedAt(t0, const Duration(minutes: 25));
      expect(
        clock.remainingAt(t0.subtract(const Duration(minutes: 10))),
        const Duration(minutes: 25),
      );
    });
  });

  group('PhaseClock — пауза и снятие с паузы', () {
    test('пауза запоминает фактический остаток, а не плановый', () {
      final clock = PhaseClock.startedAt(t0, const Duration(minutes: 25));
      final paused = clock.pausedAt(t0.add(const Duration(minutes: 10)));

      expect(paused.running, isFalse);
      expect(paused.plannedRemaining, const Duration(minutes: 15));
    });

    test('время на паузе в зачёт не идёт', () {
      final paused = PhaseClock.startedAt(t0, const Duration(minutes: 25))
          .pausedAt(t0.add(const Duration(minutes: 10)));

      // Полчаса простояли, потом сняли с паузы и подождали минуту.
      final resumed = paused.resumedAt(t0.add(const Duration(minutes: 40)));
      expect(
        resumed.remainingAt(t0.add(const Duration(minutes: 41))),
        const Duration(minutes: 14),
      );
    });
  });

  group('PhaseClock — отработанное время', () {
    test('отработанное не превышает длину фазы', () {
      final clock = PhaseClock.startedAt(t0, const Duration(minutes: 25));

      expect(
        clock.servedAt(t0.add(const Duration(minutes: 10))),
        const Duration(minutes: 10),
      );
      // Час под заблокированным экраном не превращает 25-минутную фазу в час
      // «фокуса» — иначе врала бы статистика и начисленный опыт.
      expect(
        clock.servedAt(t0.add(const Duration(hours: 1))),
        const Duration(minutes: 25),
      );
    });
  });

  group('PhaseClock — подкрутка диском', () {
    test('новый остаток отсчитывается от момента подкрутки', () {
      final clock = PhaseClock.startedAt(t0, const Duration(minutes: 25));
      final at = t0.add(const Duration(minutes: 10));
      final adjusted = clock.withRemaining(const Duration(minutes: 20), at);

      expect(adjusted.running, isTrue);
      expect(
        adjusted.remainingAt(at.add(const Duration(minutes: 5))),
        const Duration(minutes: 15),
      );
    });

    test('подкрутка стоящих часов их не запускает', () {
      const clock = PhaseClock.paused(Duration(minutes: 5));
      final adjusted = clock.withRemaining(const Duration(minutes: 9), t0);
      expect(adjusted.running, isFalse);
      expect(
        adjusted.remainingAt(t0.add(const Duration(minutes: 30))),
        const Duration(minutes: 9),
      );
    });

    test('остаток не уходит ниже нуля', () {
      final clock = PhaseClock.startedAt(t0, const Duration(minutes: 25));
      expect(
        clock.withRemaining(const Duration(minutes: -4), t0).plannedRemaining,
        Duration.zero,
      );
    });
  });

  group('PhaseClock — следующая фаза', () {
    test('перелёт переносится в следующую фазу, а не теряется', () {
      final clock = PhaseClock.startedAt(t0, const Duration(minutes: 25));
      // Узнали о конце фазы на восемь минут позже, чем он случился.
      final at = t0.add(const Duration(minutes: 33));

      final next = clock.nextPhase(
        duration: const Duration(minutes: 5),
        running: true,
        overshoot: const Duration(minutes: 8),
        now: at,
      );

      // Пятиминутный перерыв, начавшийся восемь минут назад, уже истёк —
      // именно так это и должно выглядеть после разблокировки экрана.
      expect(next.isExpiredAt(at), isTrue);
      expect(next.remainingAt(at), const Duration(minutes: -3));
    });

    test('без автостарта следующая фаза ждёт целиком и на паузе', () {
      final clock = PhaseClock.startedAt(t0, const Duration(minutes: 25));
      final next = clock.nextPhase(
        duration: const Duration(minutes: 5),
        running: false,
        overshoot: const Duration(minutes: 8),
        now: t0.add(const Duration(minutes: 33)),
      );

      expect(next.running, isFalse);
      expect(next.plannedRemaining, const Duration(minutes: 5));
    });
  });
}
