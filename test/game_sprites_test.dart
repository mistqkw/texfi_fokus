import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/domain/entities/game_rules.dart';
import 'package:texfi_fokus/presentation/game/game_sprites.dart';

/// Требование к спрайтам игрового слоя было сформулировано как дизайнерское,
/// а не техническое: каждый дрифер и особенно каждый босс должен быть
/// отдельным существом, а не тем же силуэтом в другом цвете.
///
/// Цвет тестом не поймать — он задаётся на месте отрисовки. Зато можно
/// поймать ровно ту ошибку, против которой требование и написано: два узла
/// с одинаковой сеткой. Здесь это проверяется буквально.
void main() {
  const drifters = <String, List<String>>{
    'buzz': GameSprites.drifterBuzz,
    'creep': GameSprites.drifterCreep,
    'loom': GameSprites.drifterLoom,
  };

  const bosses = <String, List<String>>{
    'scroll': GameSprites.bossScroll,
    'chorus': GameSprites.bossChorus,
    'hollow': GameSprites.bossHollow,
  };

  const avatars = <String, List<String>>{
    'spark': GameSprites.avatarSpark,
    'flame': GameSprites.avatarFlame,
    'aura': GameSprites.avatarAura,
    'crown': GameSprites.avatarCrown,
  };

  const decor = <String, List<String>>{
    'nodeCleared': GameSprites.nodeCleared,
    'nodeLocked': GameSprites.nodeLocked,
    'nodeCurrent': GameSprites.nodeCurrent,
  };

  final all = <String, List<String>>{
    ...drifters,
    ...bosses,
    ...avatars,
    ...decor,
  };

  /// Сколько закрашенных клеток в сетке — грубая мера «массы» силуэта.
  int filled(List<String> rows) =>
      rows.fold(0, (sum, row) => sum + row.split('').where((c) => c != '.').length);

  group('сетки', () {
    test('каждый спрайт квадратный и непустой', () {
      for (final entry in all.entries) {
        final rows = entry.value;
        expect(rows, isNotEmpty, reason: entry.key);
        for (final row in rows) {
          expect(
            row.length,
            rows.length,
            reason: '${entry.key}: строка «$row» не равна высоте сетки',
          );
        }
        expect(
          rows.any((row) => row.contains('x')),
          isTrue,
          reason: '${entry.key}: пустой спрайт — это дырка в интерфейсе',
        );
      }
    });

    test('существа крупнее иконок', () {
      // На 8×8 силуэт схлопывается в пятно, и все существа поневоле
      // становятся одинаковыми — ровно то, чего требование запрещает.
      for (final entry in {...drifters, ...avatars}.entries) {
        expect(entry.value.length, 12, reason: entry.key);
      }
      for (final entry in bosses.entries) {
        expect(entry.value.length, 16, reason: entry.key);
      }
    });
  });

  group('визуальное разнообразие', () {
    test('ни один спрайт не повторяет другой', () {
      final seen = <String, String>{};
      for (final entry in all.entries) {
        final key = entry.value.join('/');
        expect(
          seen.containsKey(key),
          isFalse,
          reason: '${entry.key} — та же сетка, что у ${seen[key]}',
        );
        seen[key] = entry.key;
      }
    });

    test('силуэты различаются формой, а не парой клеток', () {
      // Прямая проверка требования «не тот же спрайт в другом цвете»:
      // сколько клеток кадра у двух существ заполнены по-разному. Пара,
      // совпадающая на девять десятых, — это перекраска с лишним шагом,
      // сколько бы отдельных пикселей в ней ни поправили.
      double difference(List<String> a, List<String> b) {
        var differing = 0;
        for (var y = 0; y < a.length; y++) {
          for (var x = 0; x < a[y].length; x++) {
            if ((a[y][x] != '.') != (b[y][x] != '.')) differing++;
          }
        }
        return differing / (a.length * a.length);
      }

      void allPairsDiffer(Map<String, List<String>> group) {
        final names = group.keys.toList();
        for (var i = 0; i < names.length; i++) {
          for (var j = i + 1; j < names.length; j++) {
            final d = difference(group[names[i]]!, group[names[j]]!);
            expect(
              d,
              greaterThan(0.3),
              reason: '${names[i]} и ${names[j]} слишком похожи: '
                  '${(d * 100).round()}% кадра различается',
            );
          }
        }
      }

      allPairsDiffer(drifters);
      allPairsDiffer(bosses);
    });

    test('дриферы занимают разные пропорции кадра', () {
      // Гудок широкий, Ползун низкий, Морок высокий и узкий: это должно
      // читаться по строкам и столбцам, а не только по деталям.
      int widestRow(List<String> rows) => rows
          .map((r) => r.split('').where((c) => c != '.').length)
          .reduce((a, b) => a > b ? a : b);

      int occupiedRows(List<String> rows) =>
          rows.where((r) => r.contains('x')).length;

      // Морок — самый высокий: он занимает все строки кадра.
      expect(occupiedRows(GameSprites.drifterLoom), 12);
      // Гудок пониже, Ползун и вовсе жмётся к нижнему краю.
      expect(occupiedRows(GameSprites.drifterBuzz), lessThan(12));
      expect(
        occupiedRows(GameSprites.drifterCreep),
        lessThan(occupiedRows(GameSprites.drifterBuzz)),
      );
      // И при этом оба шире узкого Морока.
      expect(
        widestRow(GameSprites.drifterBuzz),
        greaterThan(widestRow(GameSprites.drifterLoom)),
      );
      expect(
        widestRow(GameSprites.drifterCreep),
        greaterThan(widestRow(GameSprites.drifterLoom)),
      );
    });

    test('у каждого реализованного мира свой босс', () {
      final used = <String>{};
      for (var world = 1; world <= GameRules.worldCount; world++) {
        final sprite = GameSprites.boss(world).join('/');
        expect(
          used.add(sprite),
          isTrue,
          reason: 'мир $world переиспользует спрайт чужого босса',
        );
      }
      expect(used, hasLength(GameRules.worldCount));
    });

    test('босс заметно крупнее обычного дрифера', () {
      final biggestDrifter =
          drifters.values.map(filled).reduce((a, b) => a > b ? a : b);
      for (final entry in bosses.entries) {
        expect(
          filled(entry.value),
          greaterThan(biggestDrifter),
          reason: '${entry.key} не выглядит боссом',
        );
      }
    });
  });

  group('соответствие домену', () {
    test('у каждого вида дрифера есть свой спрайт', () {
      final used = <String>{};
      for (final species in DrifterSpecies.values) {
        expect(used.add(GameSprites.drifter(species).join('/')), isTrue);
      }
      expect(used, hasLength(DrifterSpecies.values.length));
    });

    test('у каждой ступени аватара свой вид, и он растёт', () {
      final used = <String>{};
      var previous = 0;
      for (var stage = 0; stage < 4; stage++) {
        final sprite = GameSprites.avatar(stage);
        expect(used.add(sprite.join('/')), isTrue, reason: 'ступень $stage');
        // Огонёк должен именно расти: каждая ступень заметнее предыдущей.
        final mass = filled(sprite);
        expect(mass, greaterThan(previous), reason: 'ступень $stage');
        previous = mass;
      }
    });
  });
}
