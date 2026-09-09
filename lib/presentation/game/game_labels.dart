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
        DrifterSpecies.echo => l10n.drifterEcho,
        DrifterSpecies.ledger => l10n.drifterLedger,
        DrifterSpecies.pendulum => l10n.drifterPendulum,
        DrifterSpecies.mirror => l10n.drifterMirror,
        DrifterSpecies.bloom => l10n.drifterBloom,
        DrifterSpecies.thorn => l10n.drifterThorn,
        DrifterSpecies.ember => l10n.drifterEmber,
        DrifterSpecies.weight => l10n.drifterWeight,
        DrifterSpecies.door => l10n.drifterDoor,
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
        DrifterSpecies.echo => l10n.drifterEchoFlavor,
        DrifterSpecies.ledger => l10n.drifterLedgerFlavor,
        DrifterSpecies.pendulum => l10n.drifterPendulumFlavor,
        DrifterSpecies.mirror => l10n.drifterMirrorFlavor,
        DrifterSpecies.bloom => l10n.drifterBloomFlavor,
        DrifterSpecies.thorn => l10n.drifterThornFlavor,
        DrifterSpecies.ember => l10n.drifterEmberFlavor,
        DrifterSpecies.weight => l10n.drifterWeightFlavor,
        DrifterSpecies.door => l10n.drifterDoorFlavor,
      };
}

/// Босс определяется миром, а не отдельным перечислением: у каждого мира он
/// ровно один, и заводить под это enum значило бы держать два списка в
/// согласии вручную.
///
/// Мир, которому ещё не написали своего босса, получает нейтральное «босс»,
/// а не имя чужого. `_ =>` с последним из написанных был бы удобнее ровно до
/// того дня, когда кто-нибудь добавит четвёртый мир в `GameRules.worlds`: с
/// этого момента его босс молча звался бы Пустотой, и заметить это можно
/// было бы только глазами, на экране.
String bossLabel(AppLocalizations l10n, int world) => switch (world) {
      1 => l10n.bossScroll,
      2 => l10n.bossChorus,
      3 => l10n.bossHollow,
      4 => l10n.bossCarousel,
      5 => l10n.bossReflection,
      6 => l10n.bossLast,
      _ => l10n.mapBossNode,
    };

/// Описание босса. null — миру ещё не написали своего; интерфейс в этом
/// случае показывает узел без описания, а не чужое.
String? bossFlavor(AppLocalizations l10n, int world) => switch (world) {
      1 => l10n.bossScrollFlavor,
      2 => l10n.bossChorusFlavor,
      3 => l10n.bossHollowFlavor,
      4 => l10n.bossCarouselFlavor,
      5 => l10n.bossReflectionFlavor,
      6 => l10n.bossLastFlavor,
      _ => null,
    };

/// Имя мира.
///
/// Номер сам по себе ничего не обещает: «Мир 2» — это порядковый указатель,
/// а не место. Короткое имя стоит ровно столько же места на экране и при этом
/// задаёт тон тому, что внутри, — тем же способом, каким описание задаёт тон
/// каждому дриферу.
/// Мир без написанного имени называется своим номером — честное «Мир 4»
/// вместо чужого «Длинный зал».
String worldName(AppLocalizations l10n, int world) => switch (world) {
      1 => l10n.mapWorld1Name,
      2 => l10n.mapWorld2Name,
      3 => l10n.mapWorld3Name,
      4 => l10n.mapWorld4Name,
      5 => l10n.mapWorld5Name,
      6 => l10n.mapWorld6Name,
      _ => l10n.mapWorld(world),
    };

extension MapNodeLabel on MapNodeEntity {
  String title(AppLocalizations l10n) =>
      isBoss ? bossLabel(l10n, world) : species.label(l10n);

  /// null — описания нет: так бывает только у босса ещё не написанного мира.
  String? flavor(AppLocalizations l10n) =>
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

/// Имя королевства.
///
/// Королевство — единственное на карте, что говорит не про существо и не
/// про место, а про способ проиграть. «Порог» — два мира, в которых
/// теряется начало; «Долгий путь» — два, в которых кончается запас; «Своё»
/// — два, где мешать больше некому. Из-за этого имена и нужны: без них
/// шесть миров подряд читаются как шесть уровней, а не как три пары.
///
/// Королевство без написанного имени называется своим номером — тем же
/// честным способом, что и мир.
String kingdomName(AppLocalizations l10n, int kingdom) => switch (kingdom) {
      1 => l10n.mapKingdom1Name,
      2 => l10n.mapKingdom2Name,
      3 => l10n.mapKingdom3Name,
      _ => l10n.mapKingdomLabel(kingdom),
    };

/// Эпиграф королевства. null — ещё не написан; заголовок в этом случае
/// показывается без строки под ним, а не с чужой.
String? kingdomEpigraph(AppLocalizations l10n, int kingdom) =>
    switch (kingdom) {
      1 => l10n.mapKingdom1Epigraph,
      2 => l10n.mapKingdom2Epigraph,
      3 => l10n.mapKingdom3Epigraph,
      _ => null,
    };
