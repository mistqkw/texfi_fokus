import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texfi_fokus/core/theme/app_motion.dart';
import 'package:texfi_fokus/core/theme/app_theme.dart';
import 'package:texfi_fokus/presentation/game/game_providers.dart';
import 'package:texfi_fokus/presentation/game/game_sprites.dart';
import 'package:texfi_fokus/presentation/game/game_widgets.dart';
import 'package:texfi_fokus/presentation/shared/pixel_radio.dart';

/// Тесты на ту часть анимаций, у которой есть проверяемое поведение.
///
/// Сознательно не проверяется то, что субъективно: «достаточно ли короткая»
/// вспышка, «читается ли» просадка кнопки, совпал ли оттенок. Golden-снимок
/// на такое завёл бы обязательство перерисовывать эталон при каждой правке
/// цвета — и ничего не сказал бы о том, работает ли эффект.
///
/// Проверяется другое: порядок распада спрайта (он задан формулой и обязан
/// идти снизу вверх) и то, что счётчик опыта действительно проходит через
/// промежуточные значения, а не появляется готовым числом.
Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.build(brightness: Brightness.dark),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('распад спрайта идёт снизу вверх', () {
    // Сетка спрайтов приложения — 8×8; проверяем на ней и на паре крайних.
    const rowCount = 8;

    List<double> rowThresholds(int y, int rowCount) => [
          for (var x = 0; x < rowCount; x++)
            creatureCellDissolveThreshold(x, y, rowCount),
        ];

    test('нижняя строка гаснет раньше верхней', () {
      final bottom = rowThresholds(rowCount - 1, rowCount);
      final top = rowThresholds(0, rowCount);

      expect(
        bottom.reduce((a, b) => a > b ? a : b),
        lessThan(top.reduce((a, b) => a < b ? a : b)),
        reason: 'диапазоны крайних строк не должны пересекаться',
      );
    });

    test('диапазоны соседних строк не пересекаются ни на одной паре', () {
      // Это и есть «построчно»: пока строка не догорела целиком, следующая
      // не начинает. Если веса в формуле разъедутся, распад станет обычной
      // случайной россыпью — и тест обязан это поймать.
      for (var y = rowCount - 1; y > 0; y--) {
        final lower = rowThresholds(y, rowCount);
        final upper = rowThresholds(y - 1, rowCount);
        expect(
          lower.reduce((a, b) => a > b ? a : b),
          lessThan(upper.reduce((a, b) => a < b ? a : b)),
          reason: 'строка $y должна догореть раньше строки ${y - 1}',
        );
      }
    });

    test('порог всегда в пределах 0..1', () {
      for (var y = 0; y < rowCount; y++) {
        for (var x = 0; x < rowCount; x++) {
          final t = creatureCellDissolveThreshold(x, y, rowCount);
          expect(t, inInclusiveRange(0.0, 1.0));
        }
      }
    });

    test('сетка в одну строку не делит на ноль', () {
      expect(
        creatureCellDissolveThreshold(0, 0, 1),
        inInclusiveRange(0.0, 1.0),
      );
    });

    test('порог устойчив: одна и та же клетка даёт одно и то же значение', () {
      // Иначе спрайт «кипит» на каждом кадре перерисовки вместо распада.
      expect(
        creatureCellDissolveThreshold(3, 5, rowCount),
        creatureCellDissolveThreshold(3, 5, rowCount),
      );
    });

    test('порядок держится и на сетках другого размера (8×8, 10×10)', () {
      for (var n = 4; n <= 16; n++) {
        for (var y = n - 1; y > 0; y--) {
          final lower = [
            for (var x = 0; x < n; x++) creatureCellDissolveThreshold(x, y, n),
          ].reduce((a, b) => a > b ? a : b);
          final upper = [
            for (var x = 0; x < n; x++)
              creatureCellDissolveThreshold(x, y - 1, n),
          ].reduce((a, b) => a < b ? a : b);
          expect(lower, lessThan(upper), reason: 'сетка $n, строка $y');
        }
      }
    });

    test('порядок считается по реальному спрайту, а не только по числам', () {
      final rows = GameSprites.avatar(0);
      final filledByRow = <int, List<double>>{};
      for (var y = 0; y < rows.length; y++) {
        for (var x = 0; x < rows[y].length; x++) {
          if (rows[y][x] == '.') continue;
          filledByRow
              .putIfAbsent(y, () => <double>[])
              .add(creatureCellDissolveThreshold(x, y, rows.length));
        }
      }

      final rowsPresent = filledByRow.keys.toList()..sort();
      for (var i = rowsPresent.length - 1; i > 0; i--) {
        final lower = filledByRow[rowsPresent[i]]!;
        final upper = filledByRow[rowsPresent[i - 1]]!;
        expect(
          lower.reduce((a, b) => a > b ? a : b),
          lessThan(upper.reduce((a, b) => a < b ? a : b)),
        );
      }
    });
  });

  group('счётчик опыта накручивается', () {
    testWidgets('проходит через промежуточные значения и доходит до итога',
        (tester) async {
      final seen = <int>[];

      await tester.pumpWidget(
        _host(
          PixelCountUp(
            value: 40,
            builder: (context, current) {
              seen.add(current);
              return Text('$current', textDirection: TextDirection.ltr);
            },
          ),
        ),
      );

      // Первый кадр — ноль: опыт обязан быть виден растущим с нуля.
      expect(find.text('0'), findsOneWidget);

      await tester.pump(AppMotion.count ~/ 2);
      final mid = int.parse(
        (tester.widget<Text>(find.byType(Text)).data)!,
      );
      expect(mid, greaterThan(0));
      expect(mid, lessThan(40));

      await tester.pumpAndSettle();
      expect(find.text('40'), findsOneWidget);

      // Значения целые: дробного опыта не бывает, и «12.4» выдало бы, что
      // это просто интерполяция.
      expect(seen.every((v) => v >= 0 && v <= 40), isTrue);
    });

    testWidgets('задержка придерживает счётчик на нуле', (tester) async {
      await tester.pumpWidget(
        _host(
          PixelCountUp(
            value: 25,
            delay: AppMotion.normal,
            builder: (context, current) =>
                Text('$current', textDirection: TextDirection.ltr),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      // На середине задержки счётчик ещё не стартовал.
      await tester.pump(AppMotion.normal ~/ 2);
      expect(find.text('0'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('нулевой опыт не ломает счётчик', (tester) async {
      await tester.pumpWidget(
        _host(
          PixelCountUp(
            value: 0,
            builder: (context, current) =>
                Text('$current', textDirection: TextDirection.ltr),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
    });
  });

  group('заставка мира показывается один раз', () {
    Future<WorldIntroNotifier> notifier([Map<String, Object> seed = const {}]) async {
      SharedPreferences.setMockInitialValues(seed);
      return WorldIntroNotifier(await SharedPreferences.getInstance());
    }

    test('первый заход в мир показывает заставку, второй — нет', () async {
      final intro = await notifier();
      expect(intro.markSeen(2), isTrue);
      expect(intro.markSeen(2), isFalse);
    });

    test('возврат в пройденный мир заставку не повторяет', () async {
      final intro = await notifier();
      expect(intro.markSeen(2), isTrue);
      expect(intro.markSeen(3), isTrue);
      // Откат назад по карте не должен показывать мир заново.
      expect(intro.markSeen(2), isFalse);
      expect(intro.markSeen(3), isFalse);
    });

    test('отметка переживает перезапуск', () async {
      final intro = await notifier();
      expect(intro.markSeen(2), isTrue);

      // Тот же ключ, новый экземпляр — как после перезапуска приложения.
      final reopened = WorldIntroNotifier(await SharedPreferences.getInstance());
      expect(reopened.markSeen(2), isFalse);
      expect(reopened.state, 2);
    });
  });

  // Ниже — проверки, что анимация действительно проигрывается, а не просто
  // объявлена: между началом и концом виджет обязан пройти через состояние,
  // которого нет ни в одной из крайних точек. Это то, что скриншот одного
  // кадра показать не может в принципе.

  group('полоска HP отбивает урон', () {
    Widget bar(double value) => _host(
          SizedBox(
            width: 200,
            child: PixelStatBar(
              value: value,
              color: const Color(0xFFFF0000),
              flashOnDecrease: true,
            ),
          ),
        );

    double shakeOffset(WidgetTester tester) {
      final transform = tester.widget<Transform>(
        find
            .descendant(
              of: find.byType(PixelStatBar),
              matching: find.byType(Transform),
            )
            .first,
      );
      return transform.transform.getTranslation().x;
    }

    testWidgets('убыль на сегмент даёт тряску, покой — нет', (tester) async {
      await tester.pumpWidget(bar(1));
      expect(
        shakeOffset(tester),
        closeTo(0, 1e-9),
        reason: 'в покое полоска стоит ровно',
      );

      await tester.pumpWidget(bar(0.5));
      await tester.pump(const Duration(milliseconds: 60));
      expect(
        shakeOffset(tester).abs(),
        greaterThan(0),
        reason: 'на убыли полоска должна сдвинуться',
      );

      await tester.pumpAndSettle();
      expect(
        shakeOffset(tester),
        closeTo(0, 1e-9),
        reason: 'удар одиночный, не пульсация',
      );
    });

    testWidgets('рост полоски не отбивается', (tester) async {
      // Восстановление HP босса — не попадание, и отбивать его нечем.
      await tester.pumpWidget(bar(0.2));
      await tester.pumpAndSettle();

      await tester.pumpWidget(bar(1));
      await tester.pump(const Duration(milliseconds: 60));
      expect(shakeOffset(tester), closeTo(0, 1e-9));
    });

    testWidgets('без flashOnDecrease убыль молчит', (tester) async {
      Widget plain(double v) => _host(
            SizedBox(
              width: 200,
              child: PixelStatBar(value: v, color: const Color(0xFF00FF00)),
            ),
          );
      await tester.pumpWidget(plain(1));
      await tester.pumpWidget(plain(0.3));
      await tester.pump(const Duration(milliseconds: 60));
      expect(shakeOffset(tester), closeTo(0, 1e-9));
    });
  });

  group('чекбокс отбивает отметку', () {
    double scaleOf(WidgetTester tester) {
      final transform = tester.widget<Transform>(
        find
            .descendant(
              of: find.byType(PixelCheckIndicator),
              matching: find.byType(Transform),
            )
            .first,
      );
      return transform.transform.getMaxScaleOnAxis();
    }

    testWidgets('отметка раздувает коробочку и возвращает её', (tester) async {
      await tester.pumpWidget(_host(const PixelCheckIndicator(checked: false)));
      expect(scaleOf(tester), closeTo(1, 0.001));

      await tester.pumpWidget(_host(const PixelCheckIndicator(checked: true)));
      await tester.pump(const Duration(milliseconds: 90));
      expect(scaleOf(tester), greaterThan(1.1));

      await tester.pumpAndSettle();
      expect(scaleOf(tester), closeTo(1, 0.001));
    });

    testWidgets('снятие отметки не отбивается', (tester) async {
      // Снятие — это отмена, и праздновать её нечем.
      await tester.pumpWidget(_host(const PixelCheckIndicator(checked: true)));
      await tester.pumpAndSettle();

      await tester.pumpWidget(_host(const PixelCheckIndicator(checked: false)));
      await tester.pump(const Duration(milliseconds: 90));
      expect(scaleOf(tester), closeTo(1, 0.001));
    });
  });
}
