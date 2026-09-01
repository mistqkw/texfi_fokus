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
import '../game/game_sprites.dart';
import '../settings/settings_providers.dart';
import '../shared/notification_sync.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_radio.dart';
import '../shared/pixel_sprite.dart';
import 'onboarding_providers.dart';

/// Первый запуск: объясняем идею, даём выбрать тему, заводим первую привычку,
/// спрашиваем разрешение на уведомления и в конце — как приложение вообще
/// должно работать. Порядок важен: разрешение запрашивается тогда, когда уже
/// понятно, зачем оно, а выбор режима стоит последним, когда человек успел
/// увидеть, что такое обычный трекер, и ему есть с чем сравнивать.
///
/// Экран целиком показывается только тем, кто онбординг ещё не проходил:
/// `onboardingDoneProvider` держит флаг в настройках, и у людей, обновившихся
/// с прошлой версии, он давно выставлен. Новый шаг поэтому не всплывёт у них
/// задним числом — переключатель режима им остаётся там же, где и был, в
/// настройках.
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
  static const int _pageCount = 7;

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

    // Игровой режим включается ровно так же, как из настроек, — тем же
    // вызовом того же репозитория. Отдельного пути «включить на онбординге»
    // нет: два способа завести партию неминуемо разошлись бы в деталях.
    if (ref.read(onboardingGameModeProvider)) {
      await ref.read(gameRepositoryProvider).setEnabled(true);
    }

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
                    const _ModePage(),
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
          PixelSprite(
            rows: _spriteRows(sprite),
            color: context.colors.accent,
            size: 140,
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

/// Спрайты онбординга берутся из общего каталога [PixelSprites] — того же,
/// что питает нижнюю навигацию и кнопки. Своей копии сетки и своего
/// painter'а у экрана больше нет.
List<String> _spriteRows(_OnboardingSprite sprite) => switch (sprite) {
      _OnboardingSprite.logo => PixelSprites.hourglass,
      _OnboardingSprite.mood => PixelSprites.moodFace,
      _OnboardingSprite.chart => PixelSprites.navStats,
      _OnboardingSprite.check => PixelSprites.check,
    };

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
                child: Row(
                  children: [
                    PixelRadioIndicator(selected: mode == selected),
                    AppSpacing.wGapMd,
                    Expanded(
                      child: Text(
                        switch (mode) {
                          ThemeMode.system => l10n.settingsThemeSystem,
                          ThemeMode.light => l10n.settingsThemeLight,
                          ThemeMode.dark => l10n.settingsThemeDark,
                        },
                        style: context.text.title,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Выбор режима: обычный трекер или трекер с игрой.
///
/// Описание игрового варианта нарочно ориентирующее, а не завлекающее: карта,
/// противники, рост персонажа — этого достаточно, чтобы понять, что
/// включаешь. Имена существ, боссы и всё остальное человек встретит сам; в
/// анонсе они были бы спойлером к единственному, что в этом слое есть, —
/// к встрече с ними.
class _ModePage extends ConsumerWidget {
  const _ModePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final gameOn = ref.watch(onboardingGameModeProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.xl,
      ),
      children: [
        Text(
          l10n.onboardingModeTitle,
          textAlign: TextAlign.center,
          style: context.text.headline,
        ),
        AppSpacing.gapLg,
        Text(
          l10n.onboardingModeBody,
          textAlign: TextAlign.center,
          style: context.text.body,
        ),
        AppSpacing.gapXxl,
        _ModeOption(
          title: l10n.onboardingModePlain,
          body: l10n.onboardingModePlainBody,
          sprite: PixelSprites.hourglass,
          selected: !gameOn,
          onTap: () =>
              ref.read(onboardingGameModeProvider.notifier).state = false,
        ),
        AppSpacing.gapMd,
        _ModeOption(
          title: l10n.onboardingModeGame,
          body: l10n.onboardingModeGameBody,
          sprite: GameSprites.avatarFlame,
          selected: gameOn,
          onTap: () =>
              ref.read(onboardingGameModeProvider.notifier).state = true,
        ),
      ],
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.title,
    required this.body,
    required this.sprite,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String body;
  final List<String> sprite;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PixelCard(
      accent: selected,
      onTap: () {
        Haptics.tap();
        onTap();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PixelRadioIndicator(selected: selected),
          AppSpacing.wGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.title),
                AppSpacing.gapXs,
                Text(
                  body,
                  style: context.text.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.wGapMd,
          PixelSprite(
            rows: sprite,
            size: 28,
            color: selected ? colors.accent : colors.textTertiary,
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
              PixelSprite(
                rows: PixelSprites.check,
                color: context.colors.success,
                size: 18,
              ),
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
            sprite: PixelSprites.bell,
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
