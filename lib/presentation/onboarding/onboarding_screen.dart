import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../data/providers/data_providers.dart';
import '../settings/settings_providers.dart';
import '../shared/notification_sync.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import 'onboarding_providers.dart';

/// Первый запуск: объясняем идею, даём выбрать тему, заводим первую привычку
/// и спрашиваем разрешение на уведомления. Порядок важен — разрешение
/// запрашивается последним, когда уже понятно, зачем оно.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _habitController = TextEditingController();
  final TextEditingController _punishmentController = TextEditingController();

  int _page = 0;
  static const int _pageCount = 6;

  @override
  void dispose() {
    _pageController.dispose();
    _habitController.dispose();
    _punishmentController.dispose();
    super.dispose();
  }

  void _next() {
    Haptics.tap();
    if (_page >= _pageCount - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: AppMotion.normal,
      curve: AppMotion.standard,
    );
  }

  Future<void> _finish() async {
    final l10n = context.l10n;
    await ref.read(createFirstHabitProvider)(
      name: _habitController.text,
      punishment: _punishmentController.text,
    );
    await syncNotifications(ref, l10n);
    await ref.read(onboardingDoneProvider.notifier).complete();
    Haptics.sessionComplete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _page = page),
                  children: [
                    _IntroPage(
                      title: l10n.onboardingWelcomeTitle,
                      body: l10n.onboardingWelcomeBody,
                      sprite: _OnboardingSprite.logo,
                    ),
                    _IntroPage(
                      title: l10n.onboardingMoodTitle,
                      body: l10n.onboardingMoodBody,
                      sprite: _OnboardingSprite.mood,
                    ),
                    _IntroPage(
                      title: l10n.onboardingLearningTitle,
                      body: l10n.onboardingLearningBody,
                      sprite: _OnboardingSprite.chart,
                    ),
                    _IntroPage(
                      title: l10n.onboardingHabitsTitle,
                      body: l10n.onboardingHabitsBody,
                      sprite: _OnboardingSprite.check,
                    ),
                    const _ThemePage(),
                    _FirstHabitPage(
                      habitController: _habitController,
                      punishmentController: _punishmentController,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: Column(
                  children: [
                    _PageDots(count: _pageCount, active: _page),
                    AppSpacing.gapLg,
                    PixelButton(
                      label: _page >= _pageCount - 1
                          ? l10n.onboardingFinish
                          : l10n.commonNext,
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Простые пиксельные спрайты вместо иллюстраций: тот же язык, что и у
/// иконки приложения, и ничего не нужно тащить в assets.
enum _OnboardingSprite { logo, mood, chart, check }

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.title,
    required this.body,
    required this.sprite,
  });

  final String title;
  final String body;
  final _OnboardingSprite sprite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _SpritePainter(
                rows: _spriteRows(sprite),
                color: context.colors.accent,
              ),
              size: const Size(140, 140),
            ),
          ).animate().fadeIn(duration: AppMotion.slow).scaleXY(
                begin: 0.9,
                end: 1,
                duration: AppMotion.slow,
                curve: AppMotion.snap,
              ),
          AppSpacing.gapXxl,
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.text.headline,
          ),
          AppSpacing.gapLg,
          Text(
            body,
            textAlign: TextAlign.center,
            style: context.text.bodyLarge,
          ),
        ],
      ),
    );
  }
}

List<String> _spriteRows(_OnboardingSprite sprite) => switch (sprite) {
      // Песочные часы — тот же мотив, что и в иконке приложения.
      _OnboardingSprite.logo => const [
          'xxxxxxxx',
          '.x....x.',
          '..x..x..',
          '...xx...',
          '...xx...',
          '..x..x..',
          '.x....x.',
          'xxxxxxxx',
        ],
      _OnboardingSprite.mood => const [
          '........',
          '.xx..xx.',
          '.xx..xx.',
          '........',
          '.x....x.',
          '..xxxx..',
          '........',
          '........',
        ],
      _OnboardingSprite.chart => const [
          '........',
          '......xx',
          '......xx',
          '...xx.xx',
          '...xx.xx',
          'xx.xx.xx',
          'xx.xx.xx',
          'xxxxxxxx',
        ],
      _OnboardingSprite.check => const [
          '........',
          '.......x',
          '......xx',
          'x....xx.',
          'xx..xx..',
          '.xxxx...',
          '..xx....',
          '........',
        ],
    };

class _SpritePainter extends CustomPainter {
  const _SpritePainter({required this.rows, required this.color});

  final List<String> rows;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.shortestSide / rows.length;
    final paint = Paint()..color = color;
    for (var y = 0; y < rows.length; y++) {
      for (var x = 0; x < rows[y].length; x++) {
        if (rows[y][x] != 'x') continue;
        canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SpritePainter oldDelegate) =>
      oldDelegate.rows != rows || oldDelegate.color != color;
}

class _ThemePage extends ConsumerWidget {
  const _ThemePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(themeModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.onboardingThemeTitle,
            textAlign: TextAlign.center,
            style: context.text.headline,
          ),
          AppSpacing.gapLg,
          Text(
            l10n.onboardingThemeBody,
            textAlign: TextAlign.center,
            style: context.text.bodyLarge,
          ),
          AppSpacing.gapXxl,
          for (final mode in ThemeMode.values)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: PixelCard(
                accent: mode == selected,
                onTap: () {
                  Haptics.tap();
                  ref.read(themeModeProvider.notifier).set(mode);
                },
                child: Text(
                  switch (mode) {
                    ThemeMode.system => l10n.settingsThemeSystem,
                    ThemeMode.light => l10n.settingsThemeLight,
                    ThemeMode.dark => l10n.settingsThemeDark,
                  },
                  style: context.text.title,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FirstHabitPage extends ConsumerWidget {
  const _FirstHabitPage({
    required this.habitController,
    required this.punishmentController,
  });

  final TextEditingController habitController;
  final TextEditingController punishmentController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final granted = ref.watch(onboardingNotificationsGrantedProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.xl,
      ),
      children: [
        Text(
          l10n.onboardingFirstHabitTitle,
          textAlign: TextAlign.center,
          style: context.text.headline,
        ),
        AppSpacing.gapMd,
        Text(
          l10n.onboardingFirstHabitBody,
          textAlign: TextAlign.center,
          style: context.text.body,
        ),
        AppSpacing.gapXl,
        TextField(
          controller: habitController,
          decoration: InputDecoration(
            labelText: l10n.habitNameLabel,
            hintText: l10n.habitNameHint,
          ),
        ),
        AppSpacing.gapLg,
        TextField(
          controller: punishmentController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: l10n.habitPunishmentLabel,
            hintText: l10n.habitPunishmentHint,
          ),
        ),
        AppSpacing.gapSm,
        Text(l10n.habitPunishmentExplainer, style: context.text.caption),
        AppSpacing.gapXxl,
        PixelSectionHeader(title: l10n.onboardingNotificationsTitle),
        Text(l10n.onboardingNotificationsBody, style: context.text.body),
        AppSpacing.gapLg,
        if (granted)
          Row(
            children: [
              Icon(Icons.check, color: context.colors.success, size: 18),
              AppSpacing.wGapSm,
              Text(
                l10n.onboardingAllowNotifications,
                style: context.text.label,
              ),
            ],
          )
        else
          PixelButton(
            label: l10n.onboardingAllowNotifications,
            primary: false,
            icon: Icons.notifications_none,
            onPressed: () async {
              Haptics.tap();
              final ok = await ref
                  .read(notificationServiceProvider)
                  .requestPermission();
              ref.read(onboardingNotificationsGrantedProvider.notifier).state =
                  ok;
            },
          ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppMotion.fast,
            width: i == active ? 20 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i == active ? colors.accent : colors.surfaceVariant,
              borderRadius: AppRadius.controlTinyAll,
            ),
          ),
      ],
    );
  }
}
