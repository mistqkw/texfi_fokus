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
import '../../domain/entities/recommendation.dart';
import '../mood_checkin/mood_checkin_providers.dart';
import '../shared/enum_labels.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_sprite.dart';
import 'manual_timer_screen.dart';
import 'session_guard_dialog.dart';
import 'session_guard_providers.dart';
import 'timer_providers.dart';
import 'timer_screen.dart';

/// Показывает предложение движка с человеческим объяснением, откуда оно
/// взялось. Объяснение здесь не украшение: пользователь должен понимать,
/// что приложение опирается на его собственную историю, иначе совет
/// выглядит как случайное число.
class RecommendationScreen extends ConsumerWidget {
  const RecommendationScreen({super.key});

  Future<void> _start(
    BuildContext context,
    WidgetRef ref,
    Recommendation rec,
  ) async {
    // Мягкая пауза перед стартом: слишком короткий перерыв или третья
    // оборванная сессия подряд. Отказ пользователя ничего не запускает.
    if (!await confirmSessionStart(context, ref)) return;
    if (!context.mounted) return;

    ref.read(timerPlanProvider.notifier).state =
        TimerPlan.fromRecommendation(rec);
    Navigator.of(context).pushReplacement(
      pixelDissolveRoute<void>(const TimerScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final recommendation = ref.watch(recommendationProvider);

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.recommendationTitle),
        ),
        body: recommendation.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Padding(
            padding: AppSpacing.screen,
            child: Text('$error', style: context.text.body),
          ),
          data: (rec) => _RecommendationBody(
            recommendation: rec,
            onStart: () => _start(context, ref, rec),
          ),
        ),
      ),
    );
  }
}

class _RecommendationBody extends ConsumerWidget {
  const _RecommendationBody({
    required this.recommendation,
    required this.onStart,
  });

  final Recommendation recommendation;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final draft = ref.watch(sessionDraftProvider);
    final technique = recommendation.technique;

    final burnout = ref.watch(burnoutStreakProvider);

    return ListView(
      padding: AppSpacing.screen,
      children: [
        // Серия прерываний — не запрет, а повод посмотреть на день целиком,
        // поэтому это баннер над рекомендацией, а не заслонка перед ней.
        if (burnout) ...[
          _WarningBanner(
            title: l10n.guardBurnoutTitle,
            body: l10n.guardBurnoutBody,
          ),
          AppSpacing.gapLg,
        ],
        if (recommendation.cappedForNight) ...[
          _WarningBanner(
            title: l10n.guardNightCapTitle,
            body: l10n.guardNightCapBody,
          ),
          AppSpacing.gapLg,
        ],
        PixelCard(
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                technique.label(l10n),
                style: context.text.headline.copyWith(color: colors.accent),
              ),
              AppSpacing.gapMd,
              Text(technique.description(l10n), style: context.text.body),
              AppSpacing.gapLg,
              Row(
                children: [
                  _PlanFigure(
                    value: '${recommendation.focusMinutes}',
                    caption: l10n.recommendationFocusLength,
                  ),
                  AppSpacing.wGapLg,
                  _PlanFigure(
                    value: '${recommendation.breakMinutes}',
                    caption: l10n.recommendationBreakLength,
                  ),
                  AppSpacing.wGapLg,
                  _PlanFigure(
                    value: '${recommendation.cycles}',
                    caption: l10n.recommendationCycles,
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.gapLg,
        _WhyCard(recommendation: recommendation),
        AppSpacing.gapSm,
        Text(
          '${draft.mood.label(l10n)} · ${draft.category.label(l10n)} · '
          '${draft.difficulty.label(l10n)}',
          style: context.text.caption,
        ),
        AppSpacing.gapXxl,
        PixelButton(
          label: l10n.recommendationStart,
          sprite: PixelSprites.play,
          onPressed: onStart,
        ),
        AppSpacing.gapMd,
        PixelButton(
          label: l10n.recommendationManual,
          primary: false,
          sprite: PixelSprites.sliders,
          onPressed: () {
            Haptics.tap();
            Navigator.of(context).push(
              pixelDissolveRoute<void>(
                ManualTimerScreen(initial: recommendation),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// «Почему именно это» — карточка с конкретной выкладкой.
///
/// Общая фраза «основано на вашей истории» ничего не стоит: её можно писать
/// и на пустой базе. Поэтому здесь всегда видно, на скольких сессиях и
/// насколько похожих держится совет — и отдельная плашка, персональный это
/// выбор или дефолт.
class _WhyCard extends StatelessWidget {
  const _WhyCard({required this.recommendation});

  final Recommendation recommendation;

  /// Основная фраза объяснения — по тому, насколько узко совпал контекст.
  String _headline(BuildContext context) {
    final l10n = context.l10n;
    final evidence = recommendation.evidence;
    final percent = (evidence.successRate * 100).round();

    if (recommendation.reason == RecommendationReason.coldStart) {
      return l10n.recommendationColdStart;
    }
    if (!evidence.hasData) {
      return l10n.recommendationEvidenceNone;
    }
    return switch (evidence.scope) {
      EvidenceScope.exact =>
        l10n.recommendationEvidenceExact(evidence.matchedSessions, percent),
      EvidenceScope.similar =>
        l10n.recommendationEvidenceSimilar(evidence.matchedSessions, percent),
      EvidenceScope.broad =>
        l10n.recommendationEvidenceBroad(evidence.matchedSessions, percent),
      EvidenceScope.none => l10n.recommendationEvidenceNone,
    };
  }

  /// Насколько плотно набрана статистика — 0..3 закрашенных блока.
  int get _strength {
    if (recommendation.reason == RecommendationReason.coldStart) return 0;
    final evidence = recommendation.evidence;
    if (!evidence.hasData) return 0;
    final narrow = evidence.scope == EvidenceScope.exact ||
        evidence.scope == EvidenceScope.similar;
    if (evidence.matchedSessions >= 8 && narrow) return 3;
    if (evidence.matchedSessions >= 3) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final evidence = recommendation.evidence;
    final personalized =
        recommendation.reason == RecommendationReason.learned && evidence.hasData;

    return PixelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.recommendationWhyTitle,
                  style: context.text.sectionTitle,
                ),
              ),
              _SourceBadge(
                label: personalized
                    ? l10n.recommendationBadgePersonal
                    : l10n.recommendationBadgeDefault,
                accent: personalized,
              ),
            ],
          ),
          AppSpacing.gapMd,
          Text(_headline(context), style: context.text.body),

          // Исследование объясняем отдельной строкой: пользователь имеет
          // право знать, что сейчас ему предложили не «лучшее известное»,
          // а проверку гипотезы.
          if (recommendation.reason == RecommendationReason.exploration) ...[
            AppSpacing.gapSm,
            Text(
              l10n.recommendationExploring,
              style: context.text.caption.copyWith(color: colors.warning),
            ),
          ],

          AppSpacing.gapMd,
          Row(
            children: [
              _EvidenceMeter(filled: _strength),
              AppSpacing.wGapMd,
              Expanded(
                child: Text(
                  recommendation.reason == RecommendationReason.coldStart
                      ? l10n.recommendationColdStartProgress(
                          evidence.sessionsUntilPersonalized,
                        )
                      : l10n.recommendationHistorySize(evidence.totalSessions),
                  style: context.text.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Плашка с предупреждением — ночной кап или серия прерываний. Рамка цветом
/// предупреждения, тот же язык, что у «наказания» на карточке привычки.
class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PixelCard(
      borderColor: colors.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PixelSprite(
                rows: PixelSprites.hourglass,
                size: 14,
                color: colors.warning,
              ),
              AppSpacing.wGapSm,
              Expanded(
                child: Text(
                  title,
                  style: context.text.chartLabel.copyWith(
                    color: colors.warning,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapSm,
          Text(body, style: context.text.body),
        ],
      ),
    );
  }
}

/// Три пиксельных блока: грубая, но честная шкала «сколько под этим данных».
class _EvidenceMeter extends StatelessWidget {
  const _EvidenceMeter({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: i < filled ? colors.accent : Colors.transparent,
                border: Border.all(
                  color: i < filled ? colors.accent : colors.divider,
                  width: AppRadius.pixelBorder,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Плашка «персональный выбор» / «дефолт». Маленькая, но снимает главный
/// вопрос к любому советчику: это про меня или про всех?
class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.label, required this.accent});

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = accent ? colors.accent : colors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: AppRadius.pixelBorder),
      ),
      child: Text(
        label,
        style: context.text.chartLabel.copyWith(color: color),
      ),
    );
  }
}

class _PlanFigure extends StatelessWidget {
  const _PlanFigure({required this.value, required this.caption});

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: context.text.counterMedium),
          AppSpacing.gapXs,
          Text(caption, style: context.text.caption),
        ],
      ),
    );
  }
}
