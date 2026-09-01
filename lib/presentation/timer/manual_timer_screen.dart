import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../domain/entities/focus_technique.dart';
import '../../domain/entities/recommendation.dart';
import '../shared/enum_labels.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_radio.dart';
import '../shared/pixel_sprite.dart';
import 'timer_providers.dart';
import 'timer_screen.dart';

/// Ручная настройка таймера. Открывается из рекомендации и предзаполняется
/// её значениями — так «настроить самому» означает «поправить предложенное»,
/// а не начинать с нуля.
class ManualTimerScreen extends ConsumerStatefulWidget {
  const ManualTimerScreen({super.key, required this.initial});

  final Recommendation initial;

  @override
  ConsumerState<ManualTimerScreen> createState() => _ManualTimerScreenState();
}

class _ManualTimerScreenState extends ConsumerState<ManualTimerScreen> {
  late int _focusMinutes = widget.initial.focusMinutes;
  late int _breakMinutes = widget.initial.breakMinutes;
  late int _cycles = widget.initial.cycles;
  late FocusTechnique _technique = widget.initial.technique;
  bool _soundOnEnd = true;
  bool _autoStartNext = true;

  void _start() {
    ref.read(timerPlanProvider.notifier).state = TimerPlan(
      technique: _technique,
      focusMinutes: _focusMinutes,
      breakMinutes: _breakMinutes,
      cycles: _cycles,
      soundOnEnd: _soundOnEnd,
      autoStartNext: _autoStartNext,
      // Помечаем как «не по рекомендации»: статистика должна отличать
      // принятый совет от самостоятельной настройки.
      wasRecommended: false,
    );
    Navigator.of(context).pushReplacement(
      pixelDissolveRoute<void>(const TimerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.recommendationManualTitle),
        ),
        body: ListView(
          padding: AppSpacing.screen,
          children: [
            PixelSectionHeader(title: l10n.recommendationTitle),
            _TechniquePicker(
              selected: _technique,
              onSelected: (technique) {
                Haptics.tap();
                setState(() {
                  _technique = technique;
                  _focusMinutes = technique.focusMinutes;
                  _breakMinutes = technique.breakMinutes;
                  _cycles = technique.cycles;
                });
              },
            ),
            AppSpacing.gapXl,
            _StepperRow(
              label: l10n.recommendationFocusLength,
              value: _focusMinutes,
              suffix: l10n.commonMinutes,
              min: 5,
              max: 180,
              step: 5,
              onChanged: (value) => setState(() => _focusMinutes = value),
            ),
            AppSpacing.gapMd,
            _StepperRow(
              label: l10n.recommendationBreakLength,
              value: _breakMinutes,
              suffix: l10n.commonMinutes,
              min: 0,
              max: 60,
              step: 1,
              onChanged: (value) => setState(() => _breakMinutes = value),
            ),
            AppSpacing.gapMd,
            _StepperRow(
              label: l10n.recommendationCycles,
              value: _cycles,
              suffix: '',
              min: 1,
              max: 12,
              step: 1,
              onChanged: (value) => setState(() => _cycles = value),
            ),
            AppSpacing.gapXl,
            PixelCard(
              child: Column(
                children: [
                  PixelSwitchTile(
                    value: _soundOnEnd,
                    title: l10n.recommendationSoundOnEnd,
                    onChanged: (value) {
                      Haptics.tap();
                      setState(() => _soundOnEnd = value);
                    },
                  ),
                  PixelSwitchTile(
                    value: _autoStartNext,
                    title: l10n.recommendationAutoStart,
                    onChanged: (value) {
                      Haptics.tap();
                      setState(() => _autoStartNext = value);
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.gapXxl,
            PixelButton(
              label: l10n.commonStart,
              sprite: PixelSprites.play,
              onPressed: _start,
            ),
          ],
        ),
      ),
    );
  }
}

class _TechniquePicker extends StatelessWidget {
  const _TechniquePicker({required this.selected, required this.onSelected});

  final FocusTechnique selected;
  final ValueChanged<FocusTechnique> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return Column(
      children: [
        for (final technique in FocusTechnique.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: PixelCard(
              accent: technique == selected,
              padding: const EdgeInsets.all(AppSpacing.md),
              onTap: () => onSelected(technique),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technique.label(l10n),
                          style: context.text.title.copyWith(
                            color: technique == selected
                                ? colors.accent
                                : colors.textPrimary,
                          ),
                        ),
                        AppSpacing.gapXs,
                        Text(
                          '${technique.focusMinutes}/${technique.breakMinutes}'
                          ' × ${technique.cycles}',
                          style: context.text.caption,
                        ),
                      ],
                    ),
                  ),
                  if (technique == selected)
                    PixelSprite(
                      rows: PixelSprites.check,
                      size: 18,
                      color: colors.accent,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Плюс/минус с шагом. Слайдер тут был бы удобнее пальцем, но хуже точностью:
/// «ровно 25 минут» промахнуться нельзя.
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.suffix,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final int value;
  final String suffix;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  void _change(int delta) {
    final next = (value + delta).clamp(min, max);
    if (next == value) return;
    Haptics.dialTick();
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return PixelCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.text.title)),
          IconButton(
            onPressed: value > min ? () => _change(-step) : null,
            icon: PixelSprite(
              rows: PixelSprites.minus,
              size: 16,
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              suffix.isEmpty ? '$value' : '$value',
              textAlign: TextAlign.center,
              style: context.text.counterMedium,
            ),
          ),
          IconButton(
            onPressed: value < max ? () => _change(step) : null,
            icon: PixelSprite(
              rows: PixelSprites.plus,
              size: 16,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
