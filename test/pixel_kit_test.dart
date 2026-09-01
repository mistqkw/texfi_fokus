import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/core/theme/app_theme.dart';
import 'package:texfi_fokus/presentation/shared/pixel_card.dart';
import 'package:texfi_fokus/presentation/shared/pixel_nav_bar.dart';
import 'package:texfi_fokus/presentation/shared/pixel_radio.dart';
import 'package:texfi_fokus/presentation/shared/pixel_shadow.dart';
import 'package:texfi_fokus/presentation/shared/pixel_sprite.dart';

/// Тесты пиксельного набора виджетов. Проверяют не «красиво ли получилось»,
/// а то, что элемент действительно собран из своих деталей: спрайт вместо
/// Material-иконки, квадратный индикатор вместо `Radio`, сплошная тень
/// вместо её отсутствия. Именно эти подмены и разъезжались по экранам.
Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.build(brightness: Brightness.dark),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('PixelSprite', () {
    test('каждый спрайт каталога — квадратная сетка', () {
      const sprites = <String, List<String>>{
        'navHome': PixelSprites.navHome,
        'navHabits': PixelSprites.navHabits,
        'navStats': PixelSprites.navStats,
        'navSettings': PixelSprites.navSettings,
        'check': PixelSprites.check,
        'play': PixelSprites.play,
        'pause': PixelSprites.pause,
        'stop': PixelSprites.stop,
        'skip': PixelSprites.skip,
        'sliders': PixelSprites.sliders,
        'plus': PixelSprites.plus,
        'minus': PixelSprites.minus,
        'bell': PixelSprites.bell,
        'download': PixelSprites.download,
        'repeat': PixelSprites.repeat,
        'insight': PixelSprites.insight,
        'moodFace': PixelSprites.moodFace,
        'hourglass': PixelSprites.hourglass,
      };

      for (final entry in sprites.entries) {
        final rows = entry.value;
        expect(rows, isNotEmpty, reason: entry.key);
        for (final row in rows) {
          expect(
            row.length,
            rows.length,
            reason: '${entry.key}: строка «$row» не равна высоте сетки',
          );
        }
        // Пустой спрайт нарисовался бы дыркой в интерфейсе.
        expect(
          rows.any((row) => row.contains('x')),
          isTrue,
          reason: entry.key,
        );
      }
    });

    testWidgets('рисуется в заданный размер', (tester) async {
      await tester.pumpWidget(
        _host(
          const PixelSprite(
            rows: PixelSprites.navHome,
            color: Colors.white,
            size: 32,
          ),
        ),
      );
      expect(tester.getSize(find.byType(PixelSprite)), const Size(32, 32));
    });
  });

  group('PixelNavBar', () {
    testWidgets('все вкладки — спрайты, ни одной Material-иконки',
        (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        _host(
          PixelNavBar(
            currentIndex: 0,
            onSelected: (index) => selected = index,
            items: const [
              PixelNavItem(sprite: PixelSprites.navHome, label: 'Home'),
              PixelNavItem(sprite: PixelSprites.navHabits, label: 'Habits'),
              PixelNavItem(sprite: PixelSprites.navStats, label: 'Stats'),
              PixelNavItem(sprite: PixelSprites.navSettings, label: 'Settings'),
            ],
          ),
        ),
      );

      expect(find.byType(PixelSprite), findsNWidgets(4));
      expect(find.byType(Icon), findsNothing);

      await tester.tap(find.text('Stats'));
      expect(selected, 2);
    });
  });

  group('PixelCard', () {
    testWidgets('по умолчанию отбрасывает сплошную тень', (tester) async {
      await tester.pumpWidget(_host(const PixelCard(child: Text('x'))));
      expect(find.byType(PixelShadowBox), findsOneWidget);
    });

    testWidgets('вложенная карточка тень не рисует', (tester) async {
      await tester.pumpWidget(
        _host(const PixelCard(raised: false, child: Text('x'))),
      );
      expect(find.byType(PixelShadowBox), findsNothing);
    });
  });

  group('Пиксельные контролы', () {
    testWidgets('radio переключается и не использует Material Radio',
        (tester) async {
      var value = 'a';
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in ['a', 'b'])
                  PixelRadioTile<String>(
                    title: option,
                    value: option,
                    groupValue: value,
                    onChanged: (next) => setState(() => value = next),
                  ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Radio<String>), findsNothing);
      expect(find.byType(PixelRadioIndicator), findsNWidgets(2));

      await tester.tap(find.text('b'));
      await tester.pump();
      expect(value, 'b');
    });

    testWidgets('переключатель квадратный, а не Material Switch',
        (tester) async {
      var value = false;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) => PixelSwitchTile(
              title: 'Звук',
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsNothing);
      expect(find.byType(PixelToggleIndicator), findsOneWidget);

      await tester.tap(find.text('Звук'));
      await tester.pump();
      expect(value, isTrue);
    });

    testWidgets('чекбокс показывает спрайт-галочку только когда отмечен',
        (tester) async {
      await tester.pumpWidget(_host(const PixelCheckIndicator(checked: false)));
      expect(find.byType(PixelSprite), findsNothing);

      await tester.pumpWidget(_host(const PixelCheckIndicator(checked: true)));
      expect(find.byType(PixelSprite), findsOneWidget);
    });
  });
}
