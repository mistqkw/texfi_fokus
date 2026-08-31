import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../mood_checkin/mood_checkin_providers.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/timer_dial.dart';
import 'timer_providers.dart';

/// Экран таймера. Центральный элемент — крутилка: она и показывает прогресс,
/// и позволяет подкрутить оставшееся время, не выходя из сессии.
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  /// Полноэкранный минималистичный режим: остаются только цифры и кольцо.
  bool _fullscreen = false;

  bool _finishHandled = false;

  Future<void> _confirmStop() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.timerStopConfirmTitle),
        content: Text(l10n.timerStopConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.timerStopConfirmYes),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    ref.read(timerControllerProvider.notifier).stop();
  }

  /// Сессия закончилась — спрашиваем оценку и сохраняем. Оценка
  /// необязательна: если пользователь просто закроет лист, сигналом для
  /// обучения останется сам факт «дошёл / не дошёл».
  Future<void> _handleFinish(TimerState state) async {
    if (_finishHandled) return;
    _finishHandled = true;

    final l10n = context.l10n;
    final rating = await showModalBottomSheet<int>(
      context: context,
      isDismissible: true,
      builder: (context) => _RatingSheet(
        title: state.completedFully
            ? l10n.timerDoneTitle
            : l10n.timerAbortedTitle,
      ),
    );

    await ref.read(saveSessionProvider)(state: state, rating: rating);
    if (!mounted) return;
    ref.read(sessionDraftProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final state = ref.watch(timerControllerProvider);
    final controller = ref.read(timerControllerProvider.notifier);

    ref.listen<TimerState>(timerControllerProvider, (previous, next) {
      if (next.finished && !(previous?.finished ?? false)) {
        _handleFinish(next);
      }
    });

    final isFocus = state.phase == TimerPhase.focus;
    final phaseColor = isFocus ? colors.accent : colors.success;

    return PopScope(
      // Уход назад посреди сессии — это тоже прерывание, и оно должно
      // попасть в статистику, а не потеряться.
      canPop: state.finished,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !state.finished) _confirmStop();
      },
      child: PixelBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _fullscreen
              ? null
              : AppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _confirmStop,
                  ),
                  title: Text(
                    l10n.timerCycleOf(
                      state.cycleIndex + 1,
                      state.plan.cycles,
                    ),
                    style: context.text.sectionTitle,
                  ),
                  actions: [
                    IconButton(
                      tooltip: l10n.timerFullscreen,
                      icon: const Icon(Icons.fullscreen),
                      onPressed: () {
                        Haptics.tap();
                        setState(() => _fullscreen = true);
                      },
                    ),
                  ],
                ),
          body: SafeArea(
            child: GestureDetector(
              onDoubleTap: () {
                Haptics.tap();
                setState(() => _fullscreen = !_fullscreen);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: TimerDial(
                          progress: state.progress,
                          remaining: state.remaining,
                          accentColor: phaseColor,
                          enabled: !state.finished,
                          label: isFocus
                              ? l10n.timerFocusPhase
                              : l10n.timerBreakPhase,
                          onAdjustMinutes: controller.adjustMinutes,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: AppMotion.normal,
                      opacity: _fullscreen ? 0.35 : 1,
                      child: Column(
                        children: [
                          Text(
                            l10n.timerDialHint,
                            textAlign: TextAlign.center,
                            style: context.text.caption,
                          ),
                          AppSpacing.gapLg,
                          Row(
                            children: [
                              Expanded(
                                child: PixelButton(
                                  label: state.running
                                      ? l10n.timerPause
                                      : l10n.timerResume,
                                  icon: state.running
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  onPressed:
                                      state.finished ? null : controller.toggle,
                                ),
                              ),
                              AppSpacing.wGapMd,
                              Expanded(
                                child: PixelButton(
                                  label: l10n.timerSkip,
                                  primary: false,
                                  icon: Icons.skip_next_rounded,
                                  onPressed: state.finished
                                      ? null
                                      : controller.skipPhase,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapMd,
                          PixelButton(
                            label: l10n.timerStop,
                            danger: true,
                            icon: Icons.stop_rounded,
                            onPressed: state.finished ? null : _confirmStop,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Оценка продуктивности 1–5 — второй, более честный сигнал для обучения:
/// «досидел» и «поработал» это не одно и то же.
class _RatingSheet extends StatelessWidget {
  const _RatingSheet({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: context.text.headline),
            AppSpacing.gapMd,
            Text(l10n.timerRateQuestion, style: context.text.body),
            AppSpacing.gapLg,
            Row(
              children: [
                for (var rating = 1; rating <= 5; rating++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: () {
                          Haptics.success();
                          Navigator.of(context).pop(rating);
                        },
                        child: Container(
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant,
                            border: Border.all(color: colors.divider, width: 2),
                          ),
                          child: Text(
                            '$rating',
                            style: context.text.counterMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.gapLg,
            PixelButton(
              label: l10n.commonSkip,
              primary: false,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
