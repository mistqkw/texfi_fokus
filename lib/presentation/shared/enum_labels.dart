import '../../domain/entities/focus_technique.dart';
import '../../domain/entities/mood.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/task_category.dart';
import '../../l10n/app_localizations.dart';

/// Перевод доменных перечислений в подписи интерфейса. Держим в одном месте,
/// чтобы экраны не собирали switch-и по l10n каждый по-своему.
extension MoodLabel on Mood {
  String label(AppLocalizations l10n) => switch (this) {
        Mood.bad => l10n.moodBad,
        Mood.neutral => l10n.moodNeutral,
        Mood.good => l10n.moodGood,
        Mood.fullFokus => l10n.moodFullFokus,
      };
}

extension TaskCategoryLabel on TaskCategory {
  String label(AppLocalizations l10n) => switch (this) {
        TaskCategory.study => l10n.categoryStudy,
        TaskCategory.work => l10n.categoryWork,
        TaskCategory.creative => l10n.categoryCreative,
        TaskCategory.chores => l10n.categoryChores,
        TaskCategory.sport => l10n.categorySport,
        TaskCategory.other => l10n.categoryOther,
      };
}

extension TaskDifficultyLabel on TaskDifficulty {
  String label(AppLocalizations l10n) => switch (this) {
        TaskDifficulty.easy => l10n.moodDifficultyEasy,
        TaskDifficulty.medium => l10n.moodDifficultyMedium,
        TaskDifficulty.hard => l10n.moodDifficultyHard,
      };
}

extension FocusTechniqueLabel on FocusTechnique {
  String label(AppLocalizations l10n) => switch (this) {
        FocusTechnique.sprint15 => l10n.techniqueSprint15,
        FocusTechnique.pomodoro2505 => l10n.techniquePomodoro2505,
        FocusTechnique.pomodoro5010 => l10n.techniquePomodoro5010,
        FocusTechnique.deepWork90 => l10n.techniqueDeepWork90,
      };

  String description(AppLocalizations l10n) => switch (this) {
        FocusTechnique.sprint15 => l10n.techniqueSprint15Desc,
        FocusTechnique.pomodoro2505 => l10n.techniquePomodoro2505Desc,
        FocusTechnique.pomodoro5010 => l10n.techniquePomodoro5010Desc,
        FocusTechnique.deepWork90 => l10n.techniqueDeepWork90Desc,
      };
}

extension TimeOfDayBucketLabel on TimeOfDayBucket {
  String label(AppLocalizations l10n) => switch (this) {
        TimeOfDayBucket.morning => l10n.timeOfDayMorning,
        TimeOfDayBucket.afternoon => l10n.timeOfDayAfternoon,
        TimeOfDayBucket.evening => l10n.timeOfDayEvening,
        TimeOfDayBucket.night => l10n.timeOfDayNight,
      };
}

/// Короткое имя дня недели, 1 — понедельник … 7 — воскресенье.
///
/// Берём из уже переведённой строки редактора привычек, а не заводим семь
/// новых ключей на четыре языка: список там ровно тот же и в том же порядке.
String weekdayShortLabel(AppLocalizations l10n, int weekday) {
  final names = l10n.habitDaysShort.split(' ');
  final index = weekday - 1;
  if (index < 0 || index >= names.length) return '';
  return names[index];
}

/// Список подписей настроений в порядке [Mood.values] — для переключателя.
List<String> moodLabels(AppLocalizations l10n) =>
    Mood.values.map((m) => m.label(l10n)).toList();

extension InterruptionReasonLabel on InterruptionReason {
  String label(AppLocalizations l10n) => switch (this) {
        InterruptionReason.distracted => l10n.interruptionDistracted,
        InterruptionReason.wrongTask => l10n.interruptionWrongTask,
        InterruptionReason.tired => l10n.interruptionTired,
        InterruptionReason.noComment => l10n.interruptionNoComment,
      };
}
