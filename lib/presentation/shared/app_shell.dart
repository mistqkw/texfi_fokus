import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../habits/habits_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../statistics/statistics_screen.dart';

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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          if (index == _index) return;
          Haptics.tap();
          setState(() => _index = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.check_box_outlined),
            label: l10n.navHabits,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_rounded),
            label: l10n.navStats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
