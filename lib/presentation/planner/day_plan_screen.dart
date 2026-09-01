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
import '../mood_checkin/mood_checkin_providers.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_radio.dart';
import '../shared/pixel_sprite.dart';
import 'planner_providers.dart';
import 'subtask_editor.dart';

/// План на день: две-три задачи в примерном порядке.
///
/// Экран необязательный и намеренно бедный: это не менеджер задач, а список
/// из которого потом выбирают на check-in, чтобы не придумывать задачу
/// заново в момент, когда уже собрался работать.
class DayPlanScreen extends ConsumerStatefulWidget {
  const DayPlanScreen({super.key});

  @override
  ConsumerState<DayPlanScreen> createState() => _DayPlanScreenState();
}

class _DayPlanScreenState extends ConsumerState<DayPlanScreen> {
  final _titleController = TextEditingController();

  /// Сколько задач в плане считаем разумным пределом. Мягкий: сверх него
  /// показываем подсказку, но ничего не запрещаем.
  static const int suggestedLimit = 3;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      Haptics.warning();
      return;
    }
    await ref.read(addToPlanProvider)(title: title);
    if (!mounted) return;
    Haptics.success();
    _titleController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = ref.watch(todayPlanProvider).valueOrNull ?? const [];
    final tasks = ref.watch(tasksProvider).valueOrNull ?? const [];
    final plannedIds = plan.map((e) => e.task.id).toSet();
    final suggestions =
        tasks.where((t) => !plannedIds.contains(t.id)).take(6).toList();

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.planTitle),
        ),
        body: ListView(
          padding: AppSpacing.screen,
          children: [
            Text(l10n.planIntro, style: context.text.body),
            AppSpacing.gapXl,
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(hintText: l10n.planAddHint),
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
            if (plan.length >= suggestedLimit) ...[
              AppSpacing.gapSm,
              Text(l10n.planEnough, style: context.text.caption),
            ],
            AppSpacing.gapXl,
            PixelSectionHeader(title: l10n.planToday),
            if (plan.isEmpty)
              PixelCard(
                child: Text(l10n.planEmpty, style: context.text.body),
              )
            else
              for (var i = 0; i < plan.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _PlanEntryCard(entry: plan[i], position: i + 1),
                ),
            if (suggestions.isNotEmpty) ...[
              AppSpacing.gapXl,
              PixelSectionHeader(title: l10n.planFromTasks),
              for (final task in suggestions)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _SuggestionTile(task: task),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanEntryCard extends ConsumerWidget {
  const _PlanEntryCard({required this.entry, required this.position});

  final DayPlanEntryEntity entry;
  final int position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final planner = ref.watch(plannerRepositoryProvider);
    final subtasks =
        ref.watch(subtasksProvider(entry.task.id)).valueOrNull ?? const [];

    return PixelCard(
      borderColor: entry.done ? colors.success : colors.divider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PixelCheckIndicator(checked: entry.done),
              AppSpacing.wGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$position. ${entry.task.title}',
                      style: context.text.title.copyWith(
                        decoration:
                            entry.done ? TextDecoration.lineThrough : null,
                        color: entry.done
                            ? colors.textSecondary
                            : colors.textPrimary,
                      ),
                    ),
                    if (subtasks.isNotEmpty) ...[
                      AppSpacing.gapXs,
                      Text(
                        l10n.planSubtaskCount(
                          subtasks.where((s) => s.done).length,
                          subtasks.length,
                        ),
                        style: context.text.caption,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.commonDelete,
                visualDensity: VisualDensity.compact,
                icon: PixelSprite(
                rows: PixelSprites.close,
                size: 14,
                color: colors.textTertiary,
              ),
                onPressed: () {
                  Haptics.tap();
                  planner.removeFromPlan(entry.id);
                },
              ),
            ],
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              Expanded(
                child: PixelButton(
                  label: entry.done ? l10n.planUndone : l10n.planDone,
                  primary: false,
                  onPressed: () {
                    Haptics.tap();
                    planner.setPlanEntryDone(entry.id, !entry.done);
                  },
                ),
              ),
              AppSpacing.wGapMd,
              Expanded(
                child: PixelButton(
                  label: l10n.planSubtasks,
                  primary: false,
                  onPressed: () => showSubtaskEditor(context, entry.task),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends ConsumerWidget {
  const _SuggestionTile({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PixelCard(
      raised: false,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      onTap: () {
        Haptics.tap();
        ref.read(addToPlanProvider)(task: task);
      },
      child: Row(
        children: [
          Expanded(child: Text(task.title, style: context.text.body)),
          PixelSprite(
            rows: PixelSprites.plus,
            size: 14,
            color: context.colors.accent,
          ),
        ],
      ),
    );
  }
}
