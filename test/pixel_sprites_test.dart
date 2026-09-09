import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/presentation/shared/pixel_sprite.dart';

/// Инварианты набора иконок интерфейса.
///
/// Проверяется не красота — её тест не увидит, — а то, что ломается
/// незаметно и всплывает потом на экране: съехавший размер сетки, опечатка
/// в символе и две одинаковые картинки под разными именами. Последнее и
/// было болезнью набора: на восьми клетках колокольчик, лампочка и корзина
/// отличались парой пикселей и в шапке читались как одно и то же.
void main() {
  /// Все иконки по именам. Собран вручную: `PixelSprites` — набор
  /// констант, и перечислить их отражением в Dart нельзя.
  const all = <String, List<String>>{
    'navHome': PixelSprites.navHome,
    'navHabits': PixelSprites.navHabits,
    'navStats': PixelSprites.navStats,
    'navSettings': PixelSprites.navSettings,
    'moodFace': PixelSprites.moodFace,
    'check': PixelSprites.check,
    'play': PixelSprites.play,
    'pause': PixelSprites.pause,
    'stop': PixelSprites.stop,
    'skip': PixelSprites.skip,
    'sliders': PixelSprites.sliders,
    'hourglass': PixelSprites.hourglass,
    'insight': PixelSprites.insight,
    'bell': PixelSprites.bell,
    'camera': PixelSprites.camera,
    'download': PixelSprites.download,
    'upload': PixelSprites.upload,
    'plus': PixelSprites.plus,
    'search': PixelSprites.search,
    'close': PixelSprites.close,
    'trash': PixelSprites.trash,
    'moon': PixelSprites.moon,
    'fullscreen': PixelSprites.fullscreen,
    'minus': PixelSprites.minus,
    'repeat': PixelSprites.repeat,
    'notch': PixelSprites.notch,
  };

  group('сетка', () {
    test('все иконки одного размера и квадратные', () {
      // Разнобой сеток означал, что одна и та же иконка в разных местах
      // экрана выглядит разной толщины.
      for (final entry in all.entries) {
        expect(entry.value.length, 12, reason: '${entry.key}: строк не 12');
        for (final row in entry.value) {
          expect(
            row.length,
            12,
            reason: '${entry.key}: строка "$row" не 12 клеток',
          );
        }
      }
    });

    test('в сетке только заливка, полутон и пустота', () {
      // Отрисовщик считает пустотой ровно '.', а всё остальное — заливкой.
      // Опечатка не упала бы, а молча превратила бы полутон в сплошной
      // пиксель и съела деталь, ради которой он и заведён.
      for (final entry in all.entries) {
        for (final row in entry.value) {
          for (final char in row.split('')) {
            expect(
              const {'x', 'o', '.'},
              contains(char),
              reason: '${entry.key}: неизвестный символ "$char"',
            );
          }
        }
      }
    });

    test('пустых иконок нет', () {
      for (final entry in all.entries) {
        expect(
          entry.value.any((row) => row.contains('x')),
          isTrue,
          reason: '${entry.key}: ни одного закрашенного пикселя',
        );
      }
    });

    test('полутон не подменяет силуэт', () {
      // Иконка, где полутона больше заливки, теряет край и на двенадцати
      // пикселях перестаёт читаться вовсе.
      for (final entry in all.entries) {
        final solid = entry.value.fold<int>(
          0,
          (sum, row) => sum + row.split('').where((c) => c == 'x').length,
        );
        final shade = entry.value.fold<int>(
          0,
          (sum, row) => sum + row.split('').where((c) => c == 'o').length,
        );
        expect(
          shade,
          lessThan(solid),
          reason: '${entry.key}: полутона ($shade) больше заливки ($solid)',
        );
      }
    });
  });

  group('различимость', () {
    test('нет двух иконок с одинаковым рисунком', () {
      final seen = <String, String>{};
      for (final entry in all.entries) {
        final signature = entry.value.join('|');
        final twin = seen[signature];
        expect(twin, isNull, reason: '${entry.key} рисуется ровно как $twin');
        seen[signature] = entry.key;
      }
    });

    test('иконки не совпадают почти полностью', () {
      // «Почти» ловит то, чего не поймает точное сравнение: две иконки,
      // отличающиеся парой клеток, в шапке читаются как одна и та же.
      //
      // Пара «вниз/вверх» — исключение и единственное: это один силуэт,
      // перевёрнутый намеренно, и узнаётся он быстрее любой другой
      // метафоры именно потому, что половина у них общая.
      const twins = {'download|upload'};
      final names = all.keys.toList();
      for (var i = 0; i < names.length; i++) {
        for (var j = i + 1; j < names.length; j++) {
          if (twins.contains('${names[i]}|${names[j]}')) continue;
          final a = all[names[i]]!.join();
          final b = all[names[j]]!.join();
          var same = 0;
          for (var k = 0; k < a.length; k++) {
            if (a[k] == b[k]) same++;
          }
          final ratio = same / a.length;
          expect(
            ratio,
            lessThan(0.95),
            reason: '${names[i]} и ${names[j]} совпадают на '
                '${(ratio * 100).round()}% клеток',
          );
        }
      }
    });
  });
}
