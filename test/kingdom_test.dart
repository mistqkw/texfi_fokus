import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/domain/entities/game_rules.dart';
import 'package:texfi_fokus/l10n/app_localizations.dart';
import 'package:texfi_fokus/l10n/app_localizations_en.dart';
import 'package:texfi_fokus/presentation/game/game_labels.dart';

/// Королевства — способ перестать читать карту как список уровней.
///
/// Проверяется разбиение, а не оформление: каждый мир обязан попасть ровно
/// в одно королевство, королевства обязаны покрывать карту целиком и не
/// пересекаться. Ошибка здесь не падает и не видна на глаз — она выглядит
/// как мир, пропавший с карты, или как заголовок, вставший посреди пары.
void main() {
  final AppLocalizations l10n = AppLocalizationsEn();

  group('разбиение', () {
    test('каждый мир попадает ровно в одно королевство', () {
      final seen = <int>[];
      for (var kingdom = 1; kingdom <= GameRules.kingdomCount; kingdom++) {
        seen.addAll(GameRules.worldsOfKingdom(kingdom));
      }
      expect(
        seen,
        [for (var world = 1; world <= GameRules.worldCount; world++) world],
        reason: 'королевства обязаны покрывать карту целиком и по порядку',
      );
    });

    test('kingdomOf согласован с worldsOfKingdom', () {
      // Две функции про одно и то же — самый дешёвый способ однажды
      // разъехаться. Здесь они сверяются друг с другом.
      for (var world = 1; world <= GameRules.worldCount; world++) {
        expect(
          GameRules.worldsOfKingdom(GameRules.kingdomOf(world)),
          contains(world),
        );
      }
    });

    test('королевства не пересекаются', () {
      final seen = <int>{};
      for (var kingdom = 1; kingdom <= GameRules.kingdomCount; kingdom++) {
        for (final world in GameRules.worldsOfKingdom(kingdom)) {
          expect(seen.add(world), isTrue, reason: 'мир $world попал дважды');
        }
      }
    });

    test('неполное последнее королевство не ломает разбиение', () {
      // Миров может стать нечётное число, и тогда последнее королевство
      // короче. Это нормально: карта рисует то, что есть. Ненормально —
      // если оно окажется пустым или вылезет за край.
      for (var kingdom = 1; kingdom <= GameRules.kingdomCount; kingdom++) {
        final worlds = GameRules.worldsOfKingdom(kingdom);
        expect(worlds, isNotEmpty);
        expect(worlds.length, lessThanOrEqualTo(GameRules.worldsPerKingdom));
        expect(worlds.last, lessThanOrEqualTo(GameRules.worldCount));
      }
    });

    test('за краем карты королевство пустое, а не с чужими мирами', () {
      expect(GameRules.worldsOfKingdom(GameRules.kingdomCount + 1), isEmpty);
    });
  });

  group('счёт узлов', () {
    test('всего узлов — миры на узлы в мире', () {
      expect(
        GameRules.totalNodes,
        GameRules.worldCount * GameRules.nodesPerWorld,
      );
    });

    test('карта выросла вдвое против трёх миров', () {
      // Не украшение проверки: «карту сделать больше» было требованием, и
      // здесь оно записано числом, а не намерением.
      expect(GameRules.worldCount, greaterThanOrEqualTo(6));
      expect(GameRules.totalNodes, greaterThanOrEqualTo(24));
    });
  });

  group('подписи', () {
    test('у каждого королевства своё имя и свой эпиграф', () {
      final names = <String>{};
      final epigraphs = <String>{};
      for (var kingdom = 1; kingdom <= GameRules.kingdomCount; kingdom++) {
        names.add(kingdomName(l10n, kingdom));
        final epigraph = kingdomEpigraph(l10n, kingdom);
        expect(epigraph, isNotNull, reason: 'королевству $kingdom нет эпиграфа');
        epigraphs.add(epigraph!);
      }
      expect(names, hasLength(GameRules.kingdomCount));
      expect(epigraphs, hasLength(GameRules.kingdomCount));
    });

    test('ненаписанное королевство не присваивает себе чужое имя', () {
      // Та же цена `_ =>`, что и у миров: дописав королевство и забыв про
      // строки, автор получил бы имя предыдущего.
      final unwritten = GameRules.kingdomCount + 1;
      expect(
        kingdomName(l10n, unwritten),
        isNot(kingdomName(l10n, GameRules.kingdomCount)),
      );
      expect(kingdomEpigraph(l10n, unwritten), isNull);
    });
  });
}
