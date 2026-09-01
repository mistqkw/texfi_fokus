import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../domain/entities/game_entities.dart';
import '../../domain/entities/game_rules.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_sprite.dart';
import 'character_screen.dart';
import 'encounter_card.dart';
import 'game_labels.dart';
import 'game_providers.dart';
import 'game_sprites.dart';
import 'game_widgets.dart';
import 'world_intro_overlay.dart';

/// Карта продвижения: путь из миров, в конце каждого — босс.
///
/// Рисуется своим [CustomPainter], а не готовым пакетом игровых карт: любой
/// такой пакет притащил бы собственный визуальный язык, и карта перестала бы
/// выглядеть частью этого приложения — ровно та же причина, по которой
/// иконки здесь свои, а не Material.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  /// Показывает заставку мира, если в этот мир человек попал впервые.
  ///
  /// Проверка живёт на карте, а не в конце боя: в новый мир попадают именно
  /// возвращением на карту, и заставка должна встретить там, где видно, что
  /// изменилось. Показ идёт после кадра — открывать маршрут прямо из
  /// `build` нельзя.
  void _maybeIntroduceWorld() {
    final node = ref.read(currentNodeProvider);
    if (node == null) return;

    // Первый мир не представляем: он не «открылся», в нём начали.
    if (node.world <= 1) return;

    if (!ref.read(worldIntroProvider.notifier).markSeen(node.world)) return;
    WorldIntroOverlay.show(context, node.world);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final worlds = ref.watch(worldsProvider);
    final progress = ref.watch(playerProgressProvider).valueOrNull;

    // Мир мог смениться, пока экран был закрыт боем: слушаем текущий узел,
    // а не сравниваем в build.
    ref.listen(currentNodeProvider, (previous, next) {
      if (previous?.world == next?.world) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeIntroduceWorld();
      });
    });

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.mapTitle),
          actions: [
            // Персонаж живёт за кнопкой в шапке, а не пятой вкладкой: шесть
            // вкладок внизу перестают читаться, а сюда заходят реже.
            IconButton(
              tooltip: l10n.characterTitle,
              onPressed: () {
                Haptics.tap();
                Navigator.of(context).push(
                  pixelDissolveRoute<void>(const CharacterScreen()),
                );
              },
              icon: PixelSprite(
                rows: GameSprites.avatarFlame,
                color: context.colors.accent,
                size: 22,
              ),
            ),
          ],
        ),
        body: worlds.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: AppSpacing.screen,
                children: [
                  if (progress != null) _LevelStrip(progress: progress),
                  AppSpacing.gapLg,
                  for (final world in worlds) _WorldSection(nodes: world),
                  if (ref.watch(currentNodeProvider) == null) ...[
                    AppSpacing.gapLg,
                    PixelCard(
                      child: Text(
                        l10n.mapAllCleared,
                        style: context.text.body,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Полоска уровня наверху карты — чтобы не ходить на экран персонажа ради
/// одной цифры.
class _LevelStrip extends StatelessWidget {
  const _LevelStrip({required this.progress});

  final PlayerProgressEntity progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final breakdown = GameRules.levelXpBreakdown(progress.totalXp);

    return PixelCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          PixelCreature(
            rows: GameSprites.avatar(progress.avatarStage),
            color: colors.accent,
            size: 36,
            animate: false,
          ),
          AppSpacing.wGapMd,
          Expanded(
            child: PixelStatRow(
              label: l10n.characterLevel(progress.level),
              value: progress.levelProgress,
              color: colors.accent,
              trailing: l10n.characterXp(breakdown.current, breakdown.needed),
            ),
          ),
        ],
      ),
    );
  }
}

/// Один мир: заголовок и тропа с узлами.
class _WorldSection extends StatelessWidget {
  const _WorldSection({required this.nodes});

  final List<MapNodeEntity> nodes;

  /// Вертикальный шаг между узлами. Достаточно, чтобы спрайт, подпись и
  /// кусок тропы между ними не наезжали друг на друга.
  static const double _step = 116;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final world = nodes.first.world;

    // Мир, до которого ещё не дошли, не показывает своё содержимое: смысл
    // карты в том, что впереди неизвестность, а не оглавление.
    final revealed = nodes.any((n) => n.status != MapNodeStatus.locked);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Номер остался, но ушёл в подпись: он отвечает «где я в
                  // списке», а имя — «куда я попал». Второе для карты важнее.
                  Text(
                    l10n.mapWorld(world),
                    style: context.text.chartLabel.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  Text(
                    worldName(l10n, world),
                    style: context.text.sectionTitle.copyWith(
                      color:
                          revealed ? colors.textPrimary : colors.textTertiary,
                    ),
                  ),
                ],
              ),
              AppSpacing.wGapSm,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Container(height: 2, color: colors.divider),
                ),
              ),
            ],
          ),
          AppSpacing.gapLg,
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final points = <Offset>[
                for (var i = 0; i < nodes.length; i++)
                  Offset(
                    // Зигзаг: узлы уходят то влево, то вправо, а босс в
                    // конце встаёт по центру — он не «ещё одна остановка».
                    nodes[i].isBoss
                        ? width / 2
                        : (i.isEven ? width * 0.28 : width * 0.72),
                    _step * i + _step / 2,
                  ),
              ];

              return SizedBox(
                height: _step * nodes.length,
                child: Stack(
                  children: [
                    Positioned.fill(
                      // Тропа гаснет за последним пройденным узлом: дорога
                      // впереди ещё не протоптана. Прирост дорисовывается
                      // постепенно — новый отрезок появляется клетка за
                      // клеткой, а не возникает целиком, пока экран был
                      // закрыт боем. Это единственное, что связывает
                      // «победил» с «на карте стало на шаг больше».
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          end: nodes
                              .where(
                                (n) => n.status == MapNodeStatus.completed,
                              )
                              .length
                              .toDouble(),
                        ),
                        // Задержка отдана узлу: сначала с него спадает
                        // замок, и только потом от него идёт дорога.
                        duration: AppMotion.slow,
                        curve: AppMotion.standard,
                        builder: (context, cleared, _) => CustomPaint(
                          painter: _TrailPainter(
                            points: points,
                            clearedUpTo: cleared,
                            activeColor: colors.accent,
                            idleColor: colors.divider,
                          ),
                        ),
                      ),
                    ),
                    for (var i = 0; i < nodes.length; i++)
                      Positioned(
                        left: points[i].dx - 52,
                        top: points[i].dy - 46,
                        width: 104,
                        child: _MapNodeTile(node: nodes[i]),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Тропа между узлами: пунктир из квадратных клеток.
///
/// Сплошная линия здесь читалась бы как обычный `Divider`; квадраты с
/// зазором — та же логика, что у [PixelStatBar]: дорога состоит из шагов.
class _TrailPainter extends CustomPainter {
  const _TrailPainter({
    required this.points,
    required this.clearedUpTo,
    required this.activeColor,
    required this.idleColor,
  });

  final List<Offset> points;

  /// Сколько узлов уже пройдено — до них тропа горит акцентом.
  ///
  /// Дробное: `2.4` значит «два отрезка пройдены целиком, третий прорисован
  /// на 40%». Дробь существует только на время анимации прироста.
  final double clearedUpTo;

  final Color activeColor;
  final Color idleColor;

  static const double _dot = 5;
  static const double _gap = 11;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < points.length - 1; i++) {
      final from = points[i];
      final to = points[i + 1];

      // Доля отрезка, уже «протоптанная» акцентом: 1 — целиком, 0 — нет.
      final walkedFraction = (clearedUpTo - i).clamp(0.0, 1.0);

      final delta = to - from;
      final length = delta.distance;
      if (length <= 0) continue;
      final stepCount = (length / (_dot + _gap)).floor().clamp(1, 60);

      for (var s = 0; s <= stepCount; s++) {
        final t = s / stepCount;
        final paint = Paint()
          ..color = t <= walkedFraction ? activeColor : idleColor;
        final p = from + delta * t;
        // Клетки кладутся по целым координатам: пунктир на дробных
        // координатах размывается и перестаёт быть пиксельным.
        canvas.drawRect(
          Rect.fromLTWH(
            (p.dx - _dot / 2).roundToDouble(),
            (p.dy - _dot / 2).roundToDouble(),
            _dot,
            _dot,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) =>
      old.points != points ||
      old.clearedUpTo != clearedUpTo ||
      old.activeColor != activeColor;
}

/// Узел на тропе.
class _MapNodeTile extends ConsumerStatefulWidget {
  const _MapNodeTile({required this.node});

  final MapNodeEntity node;

  @override
  ConsumerState<_MapNodeTile> createState() => _MapNodeTileState();
}

class _MapNodeTileState extends ConsumerState<_MapNodeTile>
    with SingleTickerProviderStateMixin {
  /// Снятие замка: 0 — узел ещё закрыт, 1 — открыт и горит.
  ///
  /// Замок, исчезнувший за то время, пока экран был закрыт боем, не
  /// показывает, что он вообще был. Здесь узел открывается на глазах:
  /// значок замка гаснет, рамка и спрайт разгораются из приглушённого
  /// цвета в активный, и только после этого от узла уходит тропа
  /// (см. задержку в [_TrailPainter]).
  late final AnimationController _unlock = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
    // Узел, уже открытый к моменту первой отрисовки, никакой анимации не
    // играет: карта при открытии обязана быть просто картой.
    value: widget.node.status == MapNodeStatus.locked ? 0 : 1,
  );

  @override
  void didUpdateWidget(_MapNodeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final was = oldWidget.node.status == MapNodeStatus.locked;
    final now = widget.node.status == MapNodeStatus.locked;
    if (was && !now) {
      _unlock.forward(from: 0);
    } else if (!was && now) {
      _unlock.value = 0;
    }
  }

  @override
  void dispose() {
    _unlock.dispose();
    super.dispose();
  }

  void _open(BuildContext context) {
    Haptics.tap();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _NodeSheet(node: widget.node),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final node = widget.node;

    final locked = node.status == MapNodeStatus.locked;
    final cleared = node.status == MapNodeStatus.completed;

    // Три состояния читаются в первую очередь цветом и яркостью, и только
    // во вторую — значком: пройденный узел приглушён, текущий горит.
    final tone = switch (node.status) {
      MapNodeStatus.current => node.isBoss ? colors.danger : colors.accent,
      MapNodeStatus.completed => colors.textTertiary,
      MapNodeStatus.locked => colors.divider,
    };

    final sprite = locked
        ? GameSprites.nodeLocked
        : (node.isBoss
            ? GameSprites.boss(node.world)
            : GameSprites.drifter(node.species));

    final label = locked
        ? l10n.mapNodeLocked
        : (cleared ? l10n.mapNodeCleared : node.title(l10n));

    return GestureDetector(
      onTap: locked ? null : () => _open(context),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _unlock,
        builder: (context, _) {
          final t = _unlock.value;

          // Пока идёт снятие замка, узел показывает ещё замок, но уже
          // разгорается: сначала цвет, потом смена значка. Порядок обратный
          // выглядел бы как подмена картинки, а не как открытие.
          final showLock = locked || t < 0.5;
          final lit = Color.lerp(colors.divider, tone, t) ?? tone;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(
                    color: lit,
                    width: node.status == MapNodeStatus.current
                        ? AppRadius.pixelBorder * 2
                        : AppRadius.pixelBorder,
                  ),
                ),
                alignment: Alignment.center,
                child: PixelCreature(
                  rows: showLock ? GameSprites.nodeLocked : sprite,
                  color: lit,
                  size: showLock ? 28 : 52,
                  // Дёргаться должен только текущий противник: два десятка
                  // мерцающих узлов превратили бы карту в рябь.
                  animate: node.status == MapNodeStatus.current,
                ),
              ),
              AppSpacing.gapXs,
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.text.chartLabel.copyWith(color: lit),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Подробности узла: кто это, сколько у него осталось и что нужно, чтобы его
/// закрыть.
class _NodeSheet extends StatelessWidget {
  const _NodeSheet({required this.node});

  final MapNodeEntity node;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              node.status == MapNodeStatus.completed
                  ? l10n.mapNodeCleared
                  : l10n.mapNodeCurrent,
              style: context.text.chartLabel,
            ),
            AppSpacing.gapSm,
            EncounterCard(node: node),
          ],
        ),
      ),
    );
  }
}
