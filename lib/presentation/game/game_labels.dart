import '../../domain/entities/game_entities.dart';
import '../../domain/entities/game_rules.dart';
import '../../l10n/app_localizations.dart';

/// Имена и описания игровых существ. Тем же приёмом, что и `enum_labels.dart`:
/// сущности домена ничего не знают о языке, а перевод живёт рядом с
/// интерфейсом.
extension DrifterSpeciesLabel on DrifterSpecies {
  String label(AppLocalizations l10n) => switch (this) {
        DrifterSpecies.buzz => l10n.drifterBuzz,
        DrifterSpecies.creep => l10n.drifterCreep,
        DrifterSpecies.loom => l10n.drifterLoom,
        DrifterSpecies.tangle => l10n.drifterTangle,
        DrifterSpecies.mote => l10n.drifterMote,
        DrifterSpecies.husk => l10n.drifterHusk,
        DrifterSpecies.siphon => l10n.drifterSiphon,
        DrifterSpecies.knot => l10n.drifterKnot,
        DrifterSpecies.veil => l10n.drifterVeil,
      };

  String flavor(AppLocalizations l10n) => switch (this) {
        DrifterSpecies.buzz => l10n.drifterBuzzFlavor,
        DrifterSpecies.creep => l10n.drifterCreepFlavor,
        DrifterSpecies.loom => l10n.drifterLoomFlavor,
        DrifterSpecies.tangle => l10n.drifterTangleFlavor,
        DrifterSpecies.mote => l10n.drifterMoteFlavor,
        DrifterSpecies.husk => l10n.drifterHuskFlavor,
        DrifterSpecies.siphon => l10n.drifterSiphonFlavor,
        DrifterSpecies.knot => l10n.drifterKnotFlavor,
        DrifterSpecies.veil => l10n.drifterVeilFlavor,
      };
}

/// Босс определяется миром, а не отдельным перечислением: у каждого мира он
/// ровно один, и заводить под это enum значило бы держать два списка в
/// согласии вручную.
String bossLabel(AppLocalizations l10n, int world) => switch (world) {
      1 => l10n.bossScroll,
      2 => l10n.bossChorus,
      _ => l10n.bossHollow,
    };

String bossFlavor(AppLocalizations l10n, int world) => switch (world) {
      1 => l10n.bossScrollFlavor,
      2 => l10n.bossChorusFlavor,
      _ => l10n.bossHollowFlavor,
    };

/// Имя мира.
///
/// Номер сам по себе ничего не обещает: «Мир 2» — это порядковый указатель,
/// а не место. Короткое имя стоит ровно столько же места на экране и при этом
/// задаёт тон тому, что внутри, — тем же способом, каким описание задаёт тон
/// каждому дриферу.
String worldName(AppLocalizations l10n, int world) => switch (world) {
      1 => l10n.mapWorld1Name,
      2 => l10n.mapWorld2Name,
      _ => l10n.mapWorld3Name,
    };

extension MapNodeLabel on MapNodeEntity {
  String title(AppLocalizations l10n) =>
      isBoss ? bossLabel(l10n, world) : species.label(l10n);

  String flavor(AppLocalizations l10n) =>
      isBoss ? bossFlavor(l10n, world) : species.flavor(l10n);
}

/// Подпись ступени аватара — короткое описание того, что видно на картинке.
String avatarStageLabel(AppLocalizations l10n, int stage) => switch (stage) {
      0 => l10n.characterStage1,
      1 => l10n.characterStage2,
      2 => l10n.characterStage3,
      3 => l10n.characterStage4,
      4 => l10n.characterStage5,
      _ => l10n.characterStage6,
    };

/// Звание по индексу ступени. Это то, как персонаж называется, а не то, как
/// он выглядит: званий больше, чем ступеней вида, и меняются они чаще.
String rankLabel(AppLocalizations l10n, int rank) => switch (rank) {
      0 => l10n.characterRank1,
      1 => l10n.characterRank2,
      2 => l10n.characterRank3,
      3 => l10n.characterRank4,
      4 => l10n.characterRank5,
      5 => l10n.characterRank6,
      6 => l10n.characterRank7,
      _ => l10n.characterRank8,
    };
