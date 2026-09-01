import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../data/providers/data_providers.dart';
import '../../domain/entities/day_plan_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_radio.dart';
import '../shared/pixel_sprite.dart';
import 'planner_providers.dart';

/// Открывает редактор чеклиста задачи.
Future<void> showSubtaskEditor(BuildContext context, TaskEntity task) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _SubtaskEditorSheet(task: task),
  );
}

class _SubtaskEditorSheet extends ConsumerStatefulWidget {
  const _SubtaskEditorSheet({required this.task});

  final TaskEntity task;

  @override
  ConsumerState<_SubtaskEditorSheet> createState() =>
      _SubtaskEditorSheetState();
}

class _SubtaskEditorSheetState extends ConsumerState<_SubtaskEditorSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      Haptics.warning();
      return;
    }
    await ref
        .read(plannerRepositoryProvider)
        .addSubtask(taskId: widget.task.id, title: title);
    if (!mounted) return;
    Haptics.tap();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final planner = ref.watch(plannerRepositoryProvider);
    final subtasks =
        ref.watch(subtasksProvider(widget.task.id)).valueOrNull ?? const [];
    final full = subtasks.length >= SubtaskEntity.maxPerTask;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.page,
          right: AppSpacing.page,
          top: AppSpacing.page,
          bottom: AppSpacing.page + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.planSubtasks, style: context.text.headline),
              AppSpacing.gapSm,
              Text(widget.task.title, style: context.text.caption),
              AppSpacing.gapLg,
              for (final subtask in subtasks)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      PixelCheckIndicator(checked: subtask.done),
                      AppSpacing.wGapMd,
                      Expanded(
                        child: Text(
                          subtask.title,
                          style: context.text.body.copyWith(
                            decoration: subtask.done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: PixelSprite(
                rows: PixelSprites.close,
                size: 14,
                color: colors.textTertiary,
              ),
                        onPressed: () {
                          Haptics.tap();
                          planner.deleteSubtask(subtask.id);
                        },
                      ),
                    ],
                  ),
                ),
              if (subtasks.isEmpty)
                Text(l10n.planSubtasksEmpty, style: context.text.body),
              AppSpacing.gapLg,
              if (full)
                Text(
                  l10n.planSubtasksFull(SubtaskEntity.maxPerTask),
                  style: context.text.caption.copyWith(color: colors.warning),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.done,
                        decoration:
                            InputDecoration(hintText: l10n.planSubtaskHint),
                        onSubmitted: (_) => _add(),
                      ),
                    ),
                    AppSpacing.wGapMd,
                    PixelButton(
                      label: l10n.commonAdd,
                      expand: false,
                      sprite: PixelSprites.plus,
                      onPressed: _add,
                    ),
                  ],
                ),
              AppSpacing.gapXl,
              PixelButton(
                label: l10n.commonDone,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
