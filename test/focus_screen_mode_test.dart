import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/core/screen/focus_screen_mode.dart';

/// Записывает всё, что режим делает с экраном.
class _FakeControls implements ScreenControls {
  final List<String> calls = [];
  bool awake = false;
  double? brightness;

  /// Сколько раз яркость возвращали к системной.
  int restores = 0;

  @override
  Future<void> keepAwake(bool enabled) async {
    awake = enabled;
    calls.add('awake:$enabled');
  }

  @override
  Future<void> setBrightness(double value) async {
    brightness = value;
    calls.add('dim:$value');
  }

  @override
  Future<void> restoreBrightness() async {
    brightness = null;
    restores++;
    calls.add('restore');
  }
}

void main() {
  late _FakeControls controls;
  late FocusScreenMode mode;

  setUp(() {
    controls = _FakeControls();
    mode = FocusScreenMode(controls: controls);
  });

  group('экран не гаснет, пока открыт таймер', () {
    test('вход включает блокировку сна', () async {
      await mode.enter();
      expect(controls.awake, isTrue);
      expect(mode.isAwake, isTrue);
    });

    test('повторный вход не дёргает платформу дважды', () async {
      await mode.enter();
      await mode.enter();
      expect(controls.calls.where((c) => c == 'awake:true'), hasLength(1));
    });
  });

  group('тихий режим', () {
    test('включение гасит яркость, выключение возвращает', () async {
      await mode.setQuiet(true);
      expect(mode.isQuiet, isTrue);
      expect(controls.brightness, FocusScreenMode.dimBrightness);

      await mode.setQuiet(false);
      expect(mode.isQuiet, isFalse);
      expect(controls.brightness, isNull);
      expect(controls.restores, 1);
    });

    test('яркость приглушается, но экран не гаснет совсем', () {
      expect(FocusScreenMode.dimBrightness, greaterThan(0));
      expect(FocusScreenMode.dimBrightness, lessThan(0.5));
    });

    test('повторное включение ничего не меняет', () async {
      await mode.setQuiet(true);
      await mode.setQuiet(true);
      expect(controls.calls.where((c) => c.startsWith('dim')), hasLength(1));
    });

    test('переключатель ходит в обе стороны', () async {
      await mode.toggleQuiet();
      expect(mode.isQuiet, isTrue);
      await mode.toggleQuiet();
      expect(mode.isQuiet, isFalse);
    });
  });

  group('снятие на любом пути выхода', () {
    // Главное свойство всей фичи. Забытая пониженная яркость переживает уход
    // с экрана и выглядит как сломавшийся телефон, а не как забытый флаг.
    test('выход из тихого режима возвращает яркость и снимает блокировку',
        () async {
      await mode.enter();
      await mode.setQuiet(true);

      await mode.release();

      expect(controls.awake, isFalse);
      expect(controls.brightness, isNull);
      expect(mode.isQuiet, isFalse);
      expect(mode.isAwake, isFalse);
    });

    test('яркость возвращается даже если тихий режим не включали', () async {
      // Состояние приложения могло разойтись с состоянием экрана: запрос на
      // яркость мог не пройти. Верить надо экрану, поэтому возврат
      // безусловный.
      await mode.enter();
      await mode.release();
      expect(controls.restores, 1);
      expect(controls.awake, isFalse);
    });

    test('снятие без единого входа не падает', () async {
      await mode.release();
      expect(controls.awake, isFalse);
    });

    test('снятие идемпотентно', () async {
      await mode.enter();
      await mode.setQuiet(true);
      await mode.release();
      final after = controls.calls.length;

      await mode.release();
      expect(controls.calls, hasLength(after));
    });

    test('после снятия режим не оживает', () async {
      // dispose() уже прошёл: отложенный колбэк не должен заново зажечь
      // экран или приглушить яркость у следующего экрана.
      await mode.release();
      await mode.enter();
      await mode.setQuiet(true);

      expect(controls.awake, isFalse);
      expect(controls.brightness, isNull);
      expect(mode.isQuiet, isFalse);
      expect(mode.isAwake, isFalse);
    });

    test('выход руками, а затем dispose — яркость всё равно на месте',
        () async {
      await mode.enter();
      await mode.setQuiet(true);
      await mode.setQuiet(false);
      await mode.release();

      expect(controls.brightness, isNull);
      expect(controls.awake, isFalse);
      // Дважды вернуть яркость — не ошибка; не вернуть ни разу — ошибка.
      expect(controls.restores, greaterThanOrEqualTo(1));
    });
  });
}
