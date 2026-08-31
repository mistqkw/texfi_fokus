import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../domain/entities/recommendation.dart';
import '../mood_checkin/mood_checkin_providers.dart';
import '../shared/enum_labels.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import 'manual_timer_screen.dart';
import 'timer_providers.dart';
import 'timer_screen.dart';

/// Показывает предложение движка с человеческим объяснением, откуда оно
/// взялось. Объяснение здесь не украшение: пользователь должен понимать,
/// что приложение опирается на его собственную историю, иначе совет
/// выглядит как случайное число.
class RecommendationScreen extends ConsumerWidget {
  const RecommendationScreen({super.key});

  void _start(BuildContext context, WidgetRef ref, Recommendation rec) {
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

  String _explanation(BuildContext context) {
    final l10n = context.l10n;
    return switch (recommendation.reason) {
      RecommendationReason.coldStart => l10n.recommendationColdStart,
      RecommendationReason.exploration => l10n.recommendationColdStart,
      RecommendationReason.learned => l10n.recommendationLearned,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final draft = ref.watch(sessionDraftProvider);
    final technique = recommendation.technique;

    return ListView(
      padding: AppSpacing.screen,
      children: [
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
        PixelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_explanation(context), style: context.text.body),
              // Уверенность показываем только когда за ней стоят реальные
              // наблюдения: процент на пустой статистике вводил бы в
              // заблуждение.
              if (recommendation.reason == RecommendationReason.learned &&
                  recommendation.sampleSize > 0) ...[
                AppSpacing.gapSm,
                Text(
                  l10n.recommendationConfidence(
                    (recommendation.confidence * 100).round(),
                  ),
                  style: context.text.caption,
                ),
              ],
              AppSpacing.gapSm,
              Text(
                '${draft.mood.label(l10n)} · ${draft.category.label(l10n)} · '
                '${draft.difficulty.label(l10n)}',
                style: context.text.caption,
              ),
            ],
          ),
        ),
        AppSpacing.gapXxl,
        PixelButton(
          label: l10n.recommendationStart,
          icon: Icons.play_arrow_rounded,
          onPressed: onStart,
        ),
        AppSpacing.gapMd,
        PixelButton(
          label: l10n.recommendationManual,
          primary: false,
          icon: Icons.tune_rounded,
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
