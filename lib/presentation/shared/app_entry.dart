import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../onboarding/onboarding_screen.dart';
import '../settings/settings_providers.dart';
import 'app_shell.dart';

/// Решает, что показать при запуске: онбординг или основное приложение.
class AppEntry extends ConsumerWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingDone = ref.watch(onboardingDoneProvider);
    return onboardingDone ? const AppShell() : const OnboardingScreen();
  }
}
