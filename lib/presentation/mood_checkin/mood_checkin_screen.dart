import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_colors_ext.dart';
import '../../core/theme/app_l10n_ext.dart';
import '../../core/theme/app_page_transitions.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles_ext.dart';
import '../../domain/entities/task_category.dart';
import '../../domain/entities/task_entity.dart';
import '../planner/planner_providers.dart';
import '../shared/enum_labels.dart';
import '../shared/mood_switcher.dart';
import '../shared/pixel_background.dart';
import '../shared/pixel_button.dart';
import '../shared/pixel_card.dart';
import '../shared/pixel_sprite.dart';
import '../timer/recommendation_screen.dart';
import 'mood_checkin_providers.dart';
import 'session_photo_field.dart';

/// Check-in перед сессией: настроение, затем задача. Два шага на одном
/// экране — переключатель наверху остаётся виден, когда выбираешь задачу,
/// чтобы связь «настроение → рекомендация» читалась.
class MoodCheckinScreen extends ConsumerStatefulWidget {
  const MoodCheckinScreen({super.key});

  @override
  ConsumerState<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends ConsumerState<MoodCheckinScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool _showTaskError = false;

  @override
  void initState() {
    super.initState();
    // Черновик от предыдущего запуска не должен подставляться молча.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionDraftProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final notifier = ref.read(sessionDraftProvider.notifier);
    final draft = ref.read(sessionDraftProvider);

    if (!draft.isValid) {
      setState(() => _showTaskError = true);
      Haptics.warning();
      return;
    }

    await notifier.recordMood();
    await notifier.persistTask();
    if (!mounted) return;

    Navigator.of(context).push(
      pixelDissolveRoute<void>(const RecommendationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = ref.watch(sessionDraftProvider);
    final tasks = ref.watch(tasksProvider);
    final plan = ref.watch(todayPlanProvider).valueOrNull ?? const [];

    // Строка про длинные ночи: в обычном случае провайдер отдаёт `false`, и
    // экран об этой ветке ничего не знает. Отметка о показе ставится в тот
    // же кадр, в котором строка появилась, — второго раза не будет.
    final lateNight = ref.watch(lateNightNoteProvider).valueOrNull ?? false;
    if (lateNight) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(markLateNightNoteShownProvider)();
      });
    }

    return PixelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.moodTitle),
        ),
        body: ListView(
          padding: AppSpacing.screen,
          children: [
            MoodSwitcher(
              value: draft.mood,
              labels: moodLabels(l10n),
              onChanged: ref.read(sessionDraftProvider.notifier).setMood,
              note: lateNight ? l10n.moodLateNightNote : null,
              unstoppable: draft.unstoppable,
              onUnstoppable:
                  ref.read(sessionDraftProvider.notifier).setUnstoppable,
            ),
            AppSpacing.gapSm,
            Text(
              l10n.moodHint,
              textAlign: TextAlign.center,
              style: context.text.caption,
            ),
            AppSpacing.gapXxl,
            // План на сегодня идёт до поля ввода: если человек утром уже
            // решил, чем займётся, придумывать задачу заново не нужно.
            if (plan.isNotEmpty) ...[
              PixelSectionHeader(title: l10n.moodFromPlan),
              for (final entry in plan)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: PixelCard(
                    raised: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    borderColor: draft.taskId == entry.task.id
                        ? context.colors.accent
                        : null,
                    onTap: () {
                      Haptics.tap();
                      _titleController.text = entry.task.title;
                      ref
                          .read(sessionDraftProvider.notifier)
                          .selectTask(entry.task);
                      if (_showTaskError) {
                        setState(() => _showTaskError = false);
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.task.title,
                            style: context.text.body.copyWith(
                              decoration: entry.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (draft.taskId == entry.task.id)
                          PixelSprite(
                            rows: PixelSprites.check,
                            size: 14,
                            color: context.colors.accent,
                          ),
                      ],
                    ),
                  ),
                ),
              AppSpacing.gapXl,
            ],
            PixelSectionHeader(title: l10n.moodPickTaskTitle),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.moodTaskHint,
                errorText: _showTaskError ? l10n.moodTaskRequired : null,
              ),
              onChanged: (value) {
                ref.read(sessionDraftProvider.notifier).setTitle(value);
                if (_showTaskError && value.trim().isNotEmpty) {
                  setState(() => _showTaskError = false);
                }
              },
            ),
            AppSpacing.gapLg,
            tasks.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (items) => _RecentTasks(
                tasks: items,
                selectedId: draft.taskId,
                onSelected: (task) {
                  Haptics.tap();
                  _titleController.text = task.title;
                  ref.read(sessionDraftProvider.notifier).selectTask(task);
                  if (_showTaskError) setState(() => _showTaskError = false);
                },
              ),
            ),
            AppSpacing.gapXl,
            Text(l10n.moodCategory, style: context.text.label),
            AppSpacing.gapSm,
            _CategoryChips(
              selected: draft.category,
              onSelected: (category) {
                Haptics.tap();
                ref.read(sessionDraftProvider.notifier).setCategory(category);
              },
            ),
            AppSpacing.gapXl,
            Text(l10n.moodDifficulty, style: context.text.label),
            AppSpacing.gapSm,
            _DifficultySelector(
              selected: draft.difficulty,
              onSelected: (difficulty) {
                Haptics.tap();
                ref
                    .read(sessionDraftProvider.notifier)
                    .setDifficulty(difficulty);
              },
            ),
            AppSpacing.gapXl,
            // Фото идёт последним из необязательного: оно ни на
            // рекомендацию, ни на игровой слой не влияет, и вставлять его
            // между задачей и сложностью значило бы разрывать то, что
            // действительно нужно заполнить.
            const SessionPhotoField(),
            AppSpacing.gapXxl,
            PixelButton(label: l10n.moodContinue, onPressed: _continue),
          ],
        ),
      ),
    );
  }
}

/// Недавние задачи — самый частый путь: пользователь обычно возвращается к
/// тому же делу, а не заводит новое.
class _RecentTasks extends StatelessWidget {
  const _RecentTasks({
    required this.tasks,
    required this.selectedId,
    required this.onSelected,
  });

  final List<TaskEntity> tasks;
  final String? selectedId;
  final ValueChanged<TaskEntity> onSelected;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();
    final visible = tasks.take(8).toList();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final task in visible)
          _PixelChip(
            label: task.title,
            selected: task.id == selectedId,
            onTap: () => onSelected(task),
          ),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final TaskCategory selected;
  final ValueChanged<TaskCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final category in TaskCategory.values)
          _PixelChip(
            label: category.label(l10n),
            selected: category == selected,
            onTap: () => onSelected(category),
          ),
      ],
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({required this.selected, required this.onSelected});

  final TaskDifficulty selected;
  final ValueChanged<TaskDifficulty> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        for (final difficulty in TaskDifficulty.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _PixelChip(
                label: difficulty.label(l10n),
                selected: difficulty == selected,
                onTap: () => onSelected(difficulty),
                expand: true,
              ),
            ),
          ),
      ],
    );
  }
}

/// Квадратный «чип» — тот же блочный язык, что у кнопок.
class _PixelChip extends StatelessWidget {
  const _PixelChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.expand = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colors.accent.withValues(alpha: 0.18)
              : colors.surfaceVariant,
          borderRadius: AppRadius.controlSmallAll,
          border: Border.all(
            color: selected ? colors.accent : colors.divider,
            width: AppRadius.pixelBorder,
          ),
        ),
        child: Text(
          label,
          textAlign: expand ? TextAlign.center : TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: context.text.label.copyWith(
            color: selected ? colors.accent : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
