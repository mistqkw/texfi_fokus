import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_l10n_ext.dart';
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

  static const List<Widget> _screens = [
    HomeScreen(),
    HabitsScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: PixelNavBar(
        currentIndex: _index,
        onSelected: (index) => setState(() => _index = index),
        items: [
          PixelNavItem(sprite: PixelSprites.navHome, label: l10n.navHome),
          PixelNavItem(sprite: PixelSprites.navHabits, label: l10n.navHabits),
          PixelNavItem(sprite: PixelSprites.navStats, label: l10n.navStats),
          PixelNavItem(
            sprite: PixelSprites.navSettings,
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
