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
      };

  String flavor(AppLocalizations l10n) => switch (this) {
        DrifterSpecies.buzz => l10n.drifterBuzzFlavor,
        DrifterSpecies.creep => l10n.drifterCreepFlavor,
        DrifterSpecies.loom => l10n.drifterLoomFlavor,
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

extension MapNodeLabel on MapNodeEntity {
  String title(AppLocalizations l10n) =>
      isBoss ? bossLabel(l10n, world) : species.label(l10n);

  String flavor(AppLocalizations l10n) =>
      isBoss ? bossFlavor(l10n, world) : species.flavor(l10n);
}

/// Подпись ступени аватара — короткое описание того, что сейчас видно на
/// экране персонажа.
String avatarStageLabel(AppLocalizations l10n, int stage) => switch (stage) {
      0 => l10n.characterStage1,
      1 => l10n.characterStage2,
      2 => l10n.characterStage3,
      _ => l10n.characterStage4,
    };
