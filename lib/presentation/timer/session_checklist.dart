import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../data/providers/data_providers.dart';
import '../mood_checkin/mood_checkin_providers.dart';
import '../planner/planner_providers.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_radio.dart';

/// Чеклист подзадач внутри сессии.
///
/// Отмечать пункты по ходу — единственное действие в таймере, которое не
/// про таймер: оно возвращает ощущение продвижения там, где кольцо
/// показывает только, что время идёт.
///
/// Общий виджет, а не приватный класс экрана, по вполне конкретной причине:
/// сессию ведут два разных экрана — обычный таймер и экран боя, — и когда
/// чеклист жил внутри первого, у людей с включённым игровым режимом
/// подзадачи пропадали целиком. Игровой слой не имеет права ничего отнимать
/// у трекера, а самый надёжный способ этого добиться — держать общую часть
/// в одном экземпляре, а не в двух похожих.
class SessionChecklist extends ConsumerWidget {
  const SessionChecklist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskId = ref.watch(sessionDraftProvider).taskId;
    if (taskId == null) return const SizedBox.shrink();

    final subtasks = ref.watch(subtasksProvider(taskId)).valueOrNull ?? const [];
    if (subtasks.isEmpty) return const SizedBox.shrink();

    final planner = ref.watch(plannerRepositoryProvider);
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: PixelCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final subtask in subtasks)
              InkWell(
                onTap: () {
                  if (subtask.done) {
                    Haptics.tap();
                  } else {
                    Haptics.success();
                  }
                  planner.setSubtaskDone(subtask.id, !subtask.done);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      PixelCheckIndicator(checked: subtask.done, size: 16),
                      AppSpacing.wGapSm,
                      Expanded(
                        child: Text(
                          subtask.title,
                          style: context.text.caption.copyWith(
                            decoration: subtask.done
                                ? TextDecoration.lineThrough
                                : null,
                            color: subtask.done
                                ? colors.textTertiary
                                : colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
