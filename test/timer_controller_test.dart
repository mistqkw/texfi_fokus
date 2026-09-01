import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/domain/entities/focus_technique.dart';
import 'package:texfi_fokus/presentation/timer/timer_providers.dart';

/// Поведение контроллера таймера вокруг главного бага: экран гаснет или
/// приложение уходит в фон — тики не приходят — отсчёт обязан догнать
/// реальность, как только его снова спросят.
///
/// Часы подставные, поэтому «двадцать минут в кармане» проверяются без
/// ожидания в двадцать минут: контроллеру просто сообщают другое «сейчас».
void main() {
  // Переходы между фазами дёргают вибрацию, а та ходит через канал платформы.
  // В тесте канала нет, и без инициализации биндинга обращение к нему падает.
  TestWidgetsFlutterBinding.ensureInitialized();

  final t0 = DateTime(2026, 3, 14, 10, 0, 0);

  const plan = TimerPlan(
    technique: FocusTechnique.pomodoro2505,
    focusMinutes: 25,
    breakMinutes: 5,
    cycles: 2,
  );

  /// Контроллер на управляемых часах. Наблюдателя жизненного цикла не
  /// заводим: `WidgetsBinding` в чистом unit-тесте не поднят, а проверяем мы
  /// сам пересчёт — тот же, который вызывается по возврату из фона.
  ({TimerController controller, void Function(Duration) advance}) build({
    TimerPlan withPlan = plan,
    void Function()? onAlarm,
  }) {
    var now = t0;
    final controller = TimerController(
      withPlan,
      clock: () => now,
      observeLifecycle: false,
      onAlarm: onAlarm,
    );
    return (
      controller: controller,
      advance: (Duration by) => now = now.add(by),
    );
  }

  group('отсчёт по стенным часам', () {
    test('пропущенные тики отсчёт не тормозят', () {
      final t = build();
      addTearDown(t.controller.dispose);

      // Ни одного тика за двадцать минут — экран был заблокирован.
      t.advance(const Duration(minutes: 20));
      t.controller.settle();

      expect(t.controller.state.remaining, const Duration(minutes: 5));
      expect(t.controller.state.focusSeconds, 20 * 60);
    });

    test('фактическое время фокуса не отстаёт от показанного', () {
      final t = build();
      addTearDown(t.controller.dispose);

      t.advance(const Duration(minutes: 7));
      t.controller.settle();

      expect(t.controller.state.focusSeconds, 7 * 60);
      expect(t.controller.state.remaining, const Duration(minutes: 18));
    });
  });

  group('пауза', () {
    test('время на паузе не идёт ни в отсчёт, ни в статистику', () {
      final t = build();
      addTearDown(t.controller.dispose);

      t.advance(const Duration(minutes: 10));
      t.controller.pause();
      expect(t.controller.state.focusSeconds, 10 * 60);

      // Полчаса на паузе — в том числе со свёрнутым приложением.
      t.advance(const Duration(minutes: 30));
      t.controller.settle();
      expect(t.controller.state.remaining, const Duration(minutes: 15));
      expect(t.controller.state.focusSeconds, 10 * 60);

      t.controller.resume();
      t.advance(const Duration(minutes: 5));
      t.controller.settle();
      expect(t.controller.state.remaining, const Duration(minutes: 10));
      expect(t.controller.state.focusSeconds, 15 * 60);
    });
  });

  group('границы фаз, пройденные в фоне', () {
    test('фаза, истёкшая под замком, переключается при возврате', () {
      final t = build();
      addTearDown(t.controller.dispose);

      // Фокус (25) кончился, идёт третья минута перерыва.
      t.advance(const Duration(minutes: 28));
      t.controller.settle();

      expect(t.controller.state.phase, TimerPhase.rest);
      expect(t.controller.state.remaining, const Duration(minutes: 2));
      expect(t.controller.state.focusSeconds, 25 * 60);
    });

    test('несколько границ подряд разбираются за один пересчёт', () {
      final t = build();
      addTearDown(t.controller.dispose);

      // 25 фокуса + 5 перерыва + 10 второго фокуса.
      t.advance(const Duration(minutes: 40));
      t.controller.settle();

      expect(t.controller.state.phase, TimerPhase.focus);
      expect(t.controller.state.cycleIndex, 1);
      expect(t.controller.state.remaining, const Duration(minutes: 15));
      // Первый цикл целиком плюс десять минут второго — перерыв в фокус
      // не засчитан.
      expect(t.controller.state.focusSeconds, 35 * 60);
    });

    test('сигнал звучит один раз, а не по разу на пропущенную границу', () {
      var alarms = 0;
      final t = build(onAlarm: () => alarms++);
      addTearDown(t.controller.dispose);

      t.advance(const Duration(minutes: 40));
      t.controller.settle();

      expect(alarms, 1);
    });

    test('вся сессия, прошедшая в фоне, завершается корректно', () {
      final t = build();
      addTearDown(t.controller.dispose);

      // 25 + 5 + 25 = 55 минут плана; ушли на два часа.
      t.advance(const Duration(hours: 2));
      t.controller.settle();

      expect(t.controller.state.finished, isTrue);
      expect(t.controller.state.completedFully, isTrue);
      // Ровно запланированные 50 минут фокуса, а не два часа.
      expect(t.controller.state.focusSeconds, 50 * 60);
    });

    test('без автостарта следующая фаза ждёт и лишнего не накручивает', () {
      final t = build(
        withPlan: plan.copyWith(autoStartNext: false),
      );
      addTearDown(t.controller.dispose);

      t.advance(const Duration(minutes: 40));
      t.controller.settle();

      expect(t.controller.state.phase, TimerPhase.rest);
      expect(t.controller.state.running, isFalse);
      expect(t.controller.state.remaining, const Duration(minutes: 5));
      expect(t.controller.state.focusSeconds, 25 * 60);
    });
  });

  group('подкрутка диском', () {
    test('новый остаток отсчитывается от момента подкрутки', () {
      final t = build();
      addTearDown(t.controller.dispose);

      t.advance(const Duration(minutes: 10));
      t.controller.settle();
      t.controller.adjustMinutes(5);
      expect(t.controller.state.remaining, const Duration(minutes: 20));

      t.advance(const Duration(minutes: 3));
      t.controller.settle();
      expect(t.controller.state.remaining, const Duration(minutes: 17));
    });

    test('прибавка сверх длины фазы растягивает знаменатель прогресса', () {
      final t = build();
      addTearDown(t.controller.dispose);

      t.controller.adjustMinutes(10);
      expect(t.controller.state.phaseTotal, const Duration(minutes: 35));
      expect(t.controller.state.progress, 0);
    });

    test('график будильников переставляется, а обычный пересчёт — нет', () {
      final t = build();
      addTearDown(t.controller.dispose);

      final before = t.controller.state.scheduleEpoch;
      t.advance(const Duration(minutes: 3));
      t.controller.settle();
      expect(t.controller.state.scheduleEpoch, before);

      t.controller.adjustMinutes(-1);
      expect(t.controller.state.scheduleEpoch, greaterThan(before));
    });
  });

  group('пропуск и остановка', () {
    test('пропуск фокуса не дарит незаработанных секунд', () {
      final t = build();
      addTearDown(t.controller.dispose);

      t.advance(const Duration(minutes: 4));
      t.controller.skipPhase();

      expect(t.controller.state.phase, TimerPhase.rest);
      expect(t.controller.state.focusSeconds, 4 * 60);
    });

    test('досрочная остановка сохраняет отсиженное', () {
      final t = build();
      addTearDown(t.controller.dispose);

      t.advance(const Duration(minutes: 9));
      t.controller.stop();

      expect(t.controller.state.finished, isTrue);
      expect(t.controller.state.completedFully, isFalse);
      expect(t.controller.state.focusSeconds, 9 * 60);
    });

    test('после остановки время больше не набегает', () {
      final t = build();
      addTearDown(t.controller.dispose);

      t.advance(const Duration(minutes: 9));
      t.controller.stop();
      t.advance(const Duration(hours: 1));
      t.controller.settle();

      expect(t.controller.state.focusSeconds, 9 * 60);
    });
  });
}
