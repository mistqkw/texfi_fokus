import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/presentation/shared/quiet_timer_view.dart';

/// Тихий режим обязан быть именно монохромным и именно тихим: если в нём
/// остаётся акцентный цвет или спрайт врага, он не решает задачу, ради
/// которой его включают.
void main() {
  Widget wrap(Widget child) => MaterialApp(home: child);

  testWidgets('показывает только крупные цифры и подсказку', (tester) async {
    await tester.pumpWidget(wrap(
      QuietTimerView(
        remaining: const Duration(minutes: 24, seconds: 5),
        hint: 'Коснитесь экрана, чтобы вернуться',
        onExit: () {},
      ),
    ));

    expect(find.text('24:05'), findsOneWidget);
    expect(find.text('Коснитесь экрана, чтобы вернуться'), findsOneWidget);
  });

  testWidgets('фон чёрный, а текст — серый, без акцентов', (tester) async {
    await tester.pumpWidget(wrap(
      QuietTimerView(
        remaining: const Duration(minutes: 5),
        hint: 'подсказка',
        onExit: () {},
      ),
    ));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.black);

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      final color = text.style?.color;
      expect(color, isNotNull);
      // Монохром: у серого все три канала равны. Синий акцент или оранжевый
      // HP-бар этой проверки не прошли бы.
      expect(color!.r, color.g);
      expect(color.g, color.b);
    }
  });

  testWidgets('тап по экрану выходит из режима', (tester) async {
    var exits = 0;
    await tester.pumpWidget(wrap(
      QuietTimerView(
        remaining: const Duration(minutes: 5),
        hint: 'подсказка',
        onExit: () => exits++,
      ),
    ));

    // Тап именно по пустому месту: выход не должен требовать попадания в
    // кнопку — в приглушённом виде её и не видно толком.
    await tester.tapAt(const Offset(20, 20));
    await tester.pump();
    expect(exits, 1);
  });

  testWidgets('часы за час и больше не ломают вёрстку', (tester) async {
    await tester.pumpWidget(wrap(
      QuietTimerView(
        remaining: const Duration(hours: 1, minutes: 2, seconds: 3),
        hint: 'подсказка',
        onExit: () {},
      ),
    ));
    expect(find.text('1:02:03'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
