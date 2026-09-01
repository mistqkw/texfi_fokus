import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_l10n_ext.dart';
import '../game/game_providers.dart';
import '../game/game_sprites.dart';
import '../game/map_screen.dart';
import '../habits/habits_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../statistics/statistics_screen.dart';
import 'pixel_nav_bar.dart';
import 'pixel_sprite.dart';

/// Основной каркас с нижней навигацией. Экраны держатся живыми в
/// [IndexedStack]: переключение вкладок не должно сбрасывать прокрутку и
/// перезапускать подписки на БД.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Карта — единственная вкладка, которой может не быть. В обычном режиме
    // её не просто прячут за заглушкой: её нет в таббаре вовсе, иначе
    // «обычный трекер» перестал бы быть обычным.
    final gameOn = ref.watch(gameModeOnProvider);

    final screens = <Widget>[
      const HomeScreen(),
      const HabitsScreen(),
      if (gameOn) const MapScreen(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];

    final items = <PixelNavItem>[
      PixelNavItem(sprite: PixelSprites.navHome, label: l10n.navHome),
      PixelNavItem(sprite: PixelSprites.navHabits, label: l10n.navHabits),
      if (gameOn)
        PixelNavItem(sprite: GameSprites.nodeCurrent, label: l10n.navMap),
      PixelNavItem(sprite: PixelSprites.navStats, label: l10n.navStats),
      PixelNavItem(sprite: PixelSprites.navSettings, label: l10n.navSettings),
    ];

    // Режим могли выключить, стоя на карте: индекс за пределами списка
    // уронил бы IndexedStack.
    final index = _index.clamp(0, screens.length - 1);

    return Scaffold(
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: PixelNavBar(
        currentIndex: index,
        onSelected: (value) => setState(() => _index = value),
        items: items,
      ),
    );
  }
}
