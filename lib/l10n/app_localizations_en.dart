// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TexFi f0kus';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonStart => 'Start';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonClose => 'Close';

  @override
  String get commonMinutes => 'min';

  @override
  String commonMinutesFull(int count) {
    return '$count min';
  }

  @override
  String get onboardingWelcomeTitle => 'TexFi f0kus';

  @override
  String get onboardingWelcomeBody =>
      'A focus timer that learns how you actually work — and a habit tracker that does not let you off the hook.';

  @override
  String get onboardingMoodTitle => 'Start with your mood';

  @override
  String get onboardingMoodBody =>
      'Before every session you flip a switch: bad, normal, good, full f0kus. The app picks a technique and a length that fit that state.';

  @override
  String get onboardingLearningTitle => 'It learns from you';

  @override
  String get onboardingLearningBody =>
      'Every finished or abandoned session teaches the app which technique works for you in which mood. Recommendations get sharper over time.';

  @override
  String get onboardingHabitsTitle => 'Habits with consequences';

  @override
  String get onboardingHabitsBody =>
      'Set a daily goal and write down what you owe yourself if you miss it. The app remembers it and reminds you.';

  @override
  String get onboardingThemeTitle => 'Pick your look';

  @override
  String get onboardingThemeBody =>
      'Pixel-art in the dark, warm and sunny in the light.';

  @override
  String get onboardingFirstHabitTitle => 'Your first habit';

  @override
  String get onboardingFirstHabitBody =>
      'Name one thing you want to do every day. You can add more later.';

  @override
  String get onboardingNotificationsTitle => 'Reminders';

  @override
  String get onboardingNotificationsBody =>
      'Let TexFi f0kus notify you about unfinished goals at the end of the day.';

  @override
  String get onboardingAllowNotifications => 'Allow notifications';

  @override
  String get onboardingFinish => 'Let\'s go';

  @override
  String get homeTitle => 'f0kus';

  @override
  String get homeStreakLabel => 'Streak';

  @override
  String get homeStreakBasis => 'from habits';

  @override
  String homeStreakValue(int days) {
    return '$days d';
  }

  @override
  String get homeTodayHabits => 'Today';

  @override
  String get homeHabitsEmpty => 'No habits yet. Add your first one.';

  @override
  String get homeStartFocus => 'Start focus session';

  @override
  String get homeFocusToday => 'Today';

  @override
  String get homeFocusWeek => 'This week';

  @override
  String get homeSummaryTitle => 'In focus';

  @override
  String get homeAllDone => 'All goals done today. Respect.';

  @override
  String homePending(int count, int total) {
    return '$count of $total goals left';
  }

  @override
  String get insightTitle => 'Pattern spotted';

  @override
  String insightBestMood(String mood, int percent) {
    return 'Sessions you start in “$mood” finish $percent% of the time — your strongest state.';
  }

  @override
  String insightBestWeekday(String day, int minutes) {
    return '$day is your deepest focus day — $minutes min on average.';
  }

  @override
  String insightBestTime(String time, int percent) {
    return '$time is when you follow through: $percent% of those sessions land.';
  }

  @override
  String insightBestTechnique(String technique, int percent) {
    return '$technique works for you more than anything else — $percent% of those sessions land.';
  }

  @override
  String insightBasis(int count) {
    return 'From $count sessions over the last 30 days.';
  }

  @override
  String get timeOfDayMorning => 'Morning';

  @override
  String get timeOfDayAfternoon => 'Afternoon';

  @override
  String get timeOfDayEvening => 'Evening';

  @override
  String get timeOfDayNight => 'Night';

  @override
  String get navHome => 'Home';

  @override
  String get navHabits => 'Habits';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String get moodTitle => 'How are you right now?';

  @override
  String get moodBad => 'bad';

  @override
  String get moodNeutral => 'normal';

  @override
  String get moodGood => 'good';

  @override
  String get moodFullFokus => 'full f0kus';

  @override
  String get moodHint =>
      'Slide or tap to switch. Each state has its own vibration.';

  @override
  String get moodPickTaskTitle => 'What are you working on?';

  @override
  String get moodTaskHint => 'Task name';

  @override
  String get moodNewTask => 'New task';

  @override
  String get moodCategory => 'Category';

  @override
  String get moodDifficulty => 'Difficulty';

  @override
  String get moodDifficultyEasy => 'Easy';

  @override
  String get moodDifficultyMedium => 'Medium';

  @override
  String get moodDifficultyHard => 'Hard';

  @override
  String get moodContinue => 'Continue';

  @override
  String get moodTaskRequired => 'Enter a task name';

  @override
  String get categoryStudy => 'Study';

  @override
  String get categoryWork => 'Work';

  @override
  String get categoryCreative => 'Creative';

  @override
  String get categoryChores => 'Chores';

  @override
  String get categorySport => 'Sport';

  @override
  String get categoryOther => 'Other';

  @override
  String get recommendationTitle => 'Recommended for you';

  @override
  String get recommendationColdStart =>
      'A safe default for this mood — the app has not seen enough of your sessions yet.';

  @override
  String recommendationColdStartProgress(int count) {
    return '$count more sessions and the picks become yours.';
  }

  @override
  String get recommendationWhyTitle => 'Why this';

  @override
  String get recommendationBadgePersonal => 'PERSONAL';

  @override
  String get recommendationBadgeDefault => 'DEFAULT';

  @override
  String recommendationEvidenceExact(int count, int percent) {
    return 'In this exact setup you ran $count sessions with it — $percent% of them worked out.';
  }

  @override
  String recommendationEvidenceSimilar(int count, int percent) {
    return 'With a similar mood and task you ran $count sessions with it — $percent% of them worked out.';
  }

  @override
  String recommendationEvidenceBroad(int count, int percent) {
    return 'In this mood you ran $count sessions with it — $percent% of them worked out.';
  }

  @override
  String get recommendationEvidenceNone =>
      'No history for this one yet — the app is checking whether it fits you.';

  @override
  String get recommendationExploring =>
      'A deliberate try-out, not your best known option. However it goes, it sharpens the next pick.';

  @override
  String recommendationHistorySize(int count) {
    return 'Learned from $count sessions in total.';
  }

  @override
  String get recommendationStart => 'Start';

  @override
  String get recommendationManual => 'Set up manually';

  @override
  String get recommendationManualTitle => 'Custom timer';

  @override
  String get recommendationFocusLength => 'Focus length';

  @override
  String get recommendationBreakLength => 'Break length';

  @override
  String get recommendationCycles => 'Cycles';

  @override
  String get recommendationSoundOnEnd => 'Sound when a cycle ends';

  @override
  String get recommendationAutoStart => 'Auto-start the next cycle';

  @override
  String get techniqueSprint15 => 'Sprint 15';

  @override
  String get techniqueSprint15Desc =>
      '15 min of work, 5 min off. Gentle start when nothing works.';

  @override
  String get techniquePomodoro2505 => 'Pomodoro 25/5';

  @override
  String get techniquePomodoro2505Desc =>
      'The classic. 25 min of work, 5 min off, four cycles.';

  @override
  String get techniquePomodoro5010 => 'Pomodoro 50/10';

  @override
  String get techniquePomodoro5010Desc =>
      '50 min of work, 10 min off. For tasks that need momentum.';

  @override
  String get techniqueDeepWork90 => 'Deep work 90';

  @override
  String get techniqueDeepWork90Desc =>
      '90 min without interruptions. Only when you are truly on.';

  @override
  String get timerFocusPhase => 'FOCUS';

  @override
  String get timerBreakPhase => 'BREAK';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerResume => 'Resume';

  @override
  String get timerStop => 'Stop';

  @override
  String get timerSkip => 'Skip';

  @override
  String timerCycleOf(int current, int total) {
    return 'Cycle $current of $total';
  }

  @override
  String get timerDialHint => 'Drag the dial to adjust the remaining time';

  @override
  String get timerStopConfirmTitle => 'Stop the session?';

  @override
  String get timerStopConfirmBody =>
      'It will be logged as interrupted — that is also useful data.';

  @override
  String get timerStopConfirmYes => 'Stop';

  @override
  String get timerDoneTitle => 'Session finished';

  @override
  String get timerAbortedTitle => 'Session interrupted';

  @override
  String get timerRateQuestion => 'How productive was it?';

  @override
  String get timerRateSave => 'Save';

  @override
  String get timerFullscreen => 'Fullscreen';

  @override
  String get timerExitFullscreen => 'Exit fullscreen';

  @override
  String get habitsTitle => 'Habits';

  @override
  String get habitsEmpty => 'No habits yet.';

  @override
  String get habitsEmptyHint =>
      'A habit is a daily goal plus what you owe yourself if you skip it.';

  @override
  String get habitsAdd => 'New habit';

  @override
  String get habitEditTitle => 'Edit habit';

  @override
  String get habitNameLabel => 'Name';

  @override
  String get habitNameHint => 'Read for 30 minutes';

  @override
  String get habitNameRequired => 'Enter a name';

  @override
  String get habitFrequency => 'Frequency';

  @override
  String get habitDaily => 'Every day';

  @override
  String get habitCustomDays => 'Selected days';

  @override
  String get habitPunishmentLabel => 'If you miss it';

  @override
  String get habitPunishmentHint => '50 push-ups, no coffee tomorrow…';

  @override
  String get habitPunishmentRequired => 'Write down what you owe yourself';

  @override
  String get habitPunishmentExplainer =>
      'You write it, the app just remembers it and reminds you. Nothing is automated.';

  @override
  String get habitReminderTime => 'Reminder time';

  @override
  String get habitReminderOff => 'Off';

  @override
  String get habitDeleteConfirmTitle => 'Delete habit?';

  @override
  String get habitDeleteConfirmBody => 'Its history will be removed too.';

  @override
  String habitStreakLabel(int days) {
    return 'Streak: $days d';
  }

  @override
  String get habitDaysShort => 'Mon Tue Wed Thu Fri Sat Sun';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsWeek => 'Week';

  @override
  String get statsMonth => 'Month';

  @override
  String get statsActivity => 'Activity';

  @override
  String get statsActivityHint =>
      'Every square is a day. The brighter it is, the more time in focus.';

  @override
  String get statsFocusByDay => 'Focus time by day';

  @override
  String get statsMoodBreakdown => 'Mood and results';

  @override
  String get statsMoodBreakdownHint =>
      'How often you finish a session started in each mood.';

  @override
  String get statsByCategory => 'By task category';

  @override
  String get statsHabitSuccess => 'Habit success';

  @override
  String get statsTotalFocus => 'Total in focus';

  @override
  String get statsSessions => 'Sessions';

  @override
  String get statsCompletionRate => 'Finished';

  @override
  String get statsEmpty => 'Not enough data yet. Run a couple of sessions.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsFeedback => 'Sound and vibration';

  @override
  String get settingsSounds => 'Sounds';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsVibrationIntensity => 'Vibration intensity';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsEnabled => 'Habit reminders';

  @override
  String get settingsDailyReminderTime => 'Daily summary at';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsExport => 'Export data to JSON';

  @override
  String settingsExportDone(String path) {
    return 'Saved to $path';
  }

  @override
  String get settingsExportFailed => 'Export failed';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsAboutBody =>
      'Part of the TexFi ecosystem. Works fully offline — your data never leaves the device.';

  @override
  String notificationHabitTitle(String habit) {
    return 'Goal not done: $habit';
  }

  @override
  String notificationHabitBody(String punishment) {
    return 'You promised yourself: $punishment';
  }

  @override
  String get notificationDailyTitle => 'End of the day';

  @override
  String notificationDailyBody(int count) {
    return '$count goals are still unfinished. Still time.';
  }

  @override
  String get notificationChannelHabits => 'Habit reminders';

  @override
  String get notificationChannelHabitsDesc =>
      'Reminders about unfinished daily goals';

  @override
  String get interruptionQuestion => 'What pulled you out?';

  @override
  String get interruptionOptional =>
      'Optional — it helps the app read your patterns.';

  @override
  String get interruptionDistracted => 'Got distracted';

  @override
  String get interruptionWrongTask => 'Wrong task';

  @override
  String get interruptionTired => 'Too tired';

  @override
  String get interruptionNoComment => 'Rather not say';

  @override
  String get sessionNoteQuestion => 'How did it go?';

  @override
  String get sessionNoteHint => 'A few words or a sticker';

  @override
  String get guardShortBreakTitle => 'Straight back in?';

  @override
  String get guardShortBreakBody =>
      'You just finished a session. A real break makes the next one better.';

  @override
  String get guardBurnoutTitle => 'Three in a row cut short';

  @override
  String get guardBurnoutBody =>
      'Maybe today is a day to rest. Nothing is stopping you if you disagree.';

  @override
  String get guardNightCapTitle => 'It is late';

  @override
  String get guardNightCapBody =>
      'Past your night hour we keep sessions short, whatever the mood and the engine say.';

  @override
  String get guardStartAnyway => 'Start anyway';

  @override
  String get guardTakeABreak => 'Not now';

  @override
  String get settingsBurnout => 'Pace';

  @override
  String get settingsShortBreakWarning => 'Short break warning';

  @override
  String settingsShortBreakSubtitle(int count) {
    return 'Warn if a session starts within $count min of the last one';
  }

  @override
  String get settingsShortBreakOff => 'Off';

  @override
  String get settingsNightCap => 'Night soft cap';

  @override
  String get settingsNightCapSubtitle =>
      'Suggest nothing longer than 25/5 late at night';

  @override
  String get settingsNightCapHour => 'Night starts at';

  @override
  String get habitByWeekdays => 'On chosen weekdays';

  @override
  String get habitTimesPerWeek => 'N times a week';

  @override
  String get habitTimesPerWeekLabel => 'Times a week';

  @override
  String habitTimesPerWeekValue(int count) {
    return '$count× a week';
  }

  @override
  String get habitRewardLabel => 'If you keep it up';

  @override
  String get habitRewardHint => 'A long bath, that game, a day off';

  @override
  String get habitRewardExplainer =>
      'Optional, and just as much your own deal as the penalty — the app only remembers it and shows it when you get there.';

  @override
  String get habitRewardStreakDays => 'Streak needed';

  @override
  String habitRewardAfter(int count) {
    return 'Reward after $count days';
  }

  @override
  String habitRewardEarned(int count) {
    return 'Earned — $count days in a row';
  }

  @override
  String habitStreakWeeks(int count) {
    return '$count weeks in a row';
  }

  @override
  String habitWeekProgress(int done, int target) {
    return '$done of $target this week';
  }

  @override
  String get habitFreezeAllow => 'Allow streak freeze';

  @override
  String habitFreezeAllowSubtitle(int days) {
    return 'One skipped day every $days days keeps the streak';
  }

  @override
  String get habitFreezeToday => 'Freeze';

  @override
  String get habitFreezeUndo => 'Unfreeze';

  @override
  String get habitFreezeHint => 'Skip today without losing the streak';

  @override
  String get habitFreezeUndoHint => 'Today is frozen — the streak holds';

  @override
  String get habitFreezeUnavailable => 'No freeze left yet';

  @override
  String get habitFrozenToday => 'Frozen';

  @override
  String get statsPunishment => 'When the penalty bit';

  @override
  String statsPunishmentCount(int missed, int scheduled) {
    return '$missed of $scheduled days missed';
  }

  @override
  String get statsPunishmentEmpty => 'Nothing missed in this period.';

  @override
  String get statsInterruptions => 'Why sessions broke off';

  @override
  String get statsInterruptionsEmpty =>
      'No interrupted sessions in this period.';

  @override
  String get statsInterruptionUnnamed => 'No reason given';

  @override
  String get homePlanDay => 'Plan the day';

  @override
  String get planTitle => 'Today\'s plan';

  @override
  String get planIntro =>
      'Two or three tasks, roughly in order. Optional — it just saves you from inventing a task when you already sat down to work.';

  @override
  String get planAddHint => 'What are you doing today?';

  @override
  String get planEnough => 'Three is usually enough for one day.';

  @override
  String get planToday => 'In the plan';

  @override
  String get planEmpty => 'Nothing planned yet.';

  @override
  String get planFromTasks => 'From your tasks';

  @override
  String get planDone => 'Mark done';

  @override
  String get planUndone => 'Undo';

  @override
  String get planSubtasks => 'Checklist';

  @override
  String get planSubtaskHint => 'One step';

  @override
  String planSubtaskCount(int done, int total) {
    return '$done of $total steps';
  }

  @override
  String get planSubtasksEmpty =>
      'No steps yet — a session shows them as a checklist.';

  @override
  String planSubtasksFull(int count) {
    return '$count steps is the limit for one session.';
  }

  @override
  String get moodFromPlan => 'From today\'s plan';

  @override
  String notificationDailyProductive(int sessions, int minutes, String mood) {
    return 'Today: $sessions sessions, $minutes min in focus, mostly $mood.';
  }

  @override
  String get notificationDailyAllDone =>
      'Everything is closed today. Well done.';

  @override
  String get notificationChannelTimer => 'Timer';

  @override
  String get notificationChannelTimerDesc =>
      'End of a focus block, a break or a whole session';

  @override
  String get notificationTimerFocusDoneTitle => 'Focus block done';

  @override
  String notificationTimerFocusDoneBody(int cycle, int total) {
    return 'Cycle $cycle of $total is over. Break time.';
  }

  @override
  String get notificationTimerBreakDoneTitle => 'Break is over';

  @override
  String get notificationTimerBreakDoneBody =>
      'Back to focus when you are ready.';

  @override
  String get notificationTimerSessionDoneTitle => 'Session complete';

  @override
  String notificationTimerSessionDoneBody(int minutes) {
    return '$minutes min planned in focus. Well held.';
  }

  @override
  String get navMap => 'Map';

  @override
  String get gameSectionTitle => 'Game mode';

  @override
  String get gameModeToggle => 'Play instead of just tracking';

  @override
  String get gameModeSubtitle =>
      'Sessions and habits stay exactly as they are — a map, drifters and levels appear on top of them.';

  @override
  String get gameModeOffNote =>
      'Turning it off only hides the game. Your level and map progress are kept, and you will come back to the same spot.';

  @override
  String get gameReset => 'Start the game over';

  @override
  String get gameResetSubtitle =>
      'Clears XP and the map. Sessions and habits are not affected.';

  @override
  String get gameResetConfirm =>
      'Start over? The level and the map go back to zero. Sessions, habits and statistics stay untouched.';

  @override
  String get gameResetDone => 'The map starts from the beginning.';

  @override
  String get mapTitle => 'Map';

  @override
  String mapWorld(int world) {
    return 'World $world';
  }

  @override
  String get mapAllCleared =>
      'Every world is cleared. Sessions still bring XP.';

  @override
  String get mapNodeLocked => 'Locked';

  @override
  String get mapNodeCleared => 'Cleared';

  @override
  String get mapNodeCurrent => 'You are here';

  @override
  String get mapBossNode => 'Boss';

  @override
  String get characterTitle => 'Character';

  @override
  String characterLevel(int level) {
    return 'Level $level';
  }

  @override
  String characterXp(int current, int needed) {
    return '$current / $needed XP';
  }

  @override
  String characterToNextLevel(int xp) {
    return '$xp XP to the next level';
  }

  @override
  String get characterDriftersDefeated => 'Drifters defeated';

  @override
  String get characterBossesDefeated => 'Bosses defeated';

  @override
  String get characterTotalXp => 'XP earned';

  @override
  String get characterStage1 => 'Just a core';

  @override
  String get characterStage2 => 'A shaped flame';

  @override
  String get characterStage3 => 'A halo of sparks';

  @override
  String get characterStage4 => 'A crown';

  @override
  String get drifterBuzz => 'Buzz';

  @override
  String get drifterCreep => 'Creep';

  @override
  String get drifterLoom => 'Loom';

  @override
  String get drifterBuzzFlavor =>
      'Wide wings, tiny body. Pings once and carries your attention off.';

  @override
  String get drifterCreepFlavor =>
      'Low and many-legged. Does not swoop — it creeps up from below.';

  @override
  String get drifterLoomFlavor =>
      'Tall, narrow, one empty eye. Just stands there and watches.';

  @override
  String get bossScroll => 'The Scroll';

  @override
  String get bossChorus => 'The Chorus';

  @override
  String get bossHollow => 'The Hollow';

  @override
  String get bossScrollFlavor =>
      'A ribbon coiled into itself. It has no end, that is the whole trick.';

  @override
  String get bossChorusFlavor =>
      'Not one creature but a cluster of heads, all talking at once.';

  @override
  String get bossHollowFlavor =>
      'A heavy frame around nothing at all. It pulls inward.';

  @override
  String get encounterTitle => 'Facing you';

  @override
  String encounterHp(int current, int max) {
    return '$current / $max HP';
  }

  @override
  String get encounterWounded => 'Wounded — finish it off.';

  @override
  String get encounterHealed => 'It had time to recover while you were away.';

  @override
  String get encounterBossHint =>
      'Only sessions started in full f0kus really hurt this one.';

  @override
  String encounterBossStamina(int current, int total) {
    return 'Your stamina: $current of $total';
  }

  @override
  String get encounterBossStaminaHint => 'Each abandoned f0kus run costs one.';

  @override
  String get encounterFokusMissing =>
      'Pick full f0kus at check-in to fight it properly.';

  @override
  String gameXpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String gameLevelUp(int level) {
    return 'Level $level';
  }

  @override
  String get gameLevelUpBody => 'Your flame has changed.';

  @override
  String get gameDrifterDefeated => 'Drifter defeated';

  @override
  String get gameBossDefeated => 'Boss defeated';

  @override
  String get gameBossDefeatedBody => 'The way to the next world is open.';

  @override
  String get gamePlayerDefeated => 'The boss caught its breath';

  @override
  String get gamePlayerDefeatedBody =>
      'It is back to full health, and so is your stamina. Come back when you are ready — nothing else was lost.';

  @override
  String get gameContinue => 'Onward';

  @override
  String get settingsAccent => 'Accent colour';

  @override
  String get settingsAccentSubtitle =>
      'Only the accent tone changes — the rest of the palette stays as it is.';

  @override
  String get settingsImport => 'Import from JSON';

  @override
  String get settingsImportSubtitle =>
      'Restore an earlier export on a new device';

  @override
  String get settingsImportPathHint => 'Full path to the exported .json file.';

  @override
  String get settingsImportNoFile => 'No file at that path';

  @override
  String get settingsImportWarnTitle => 'This touches your data';

  @override
  String get settingsImportWarnBody =>
      'Merge keeps what you already have and adds what is missing. Replace wipes the current history first — there is no undo.';

  @override
  String get settingsImportMerge => 'Merge';

  @override
  String get settingsImportReplace => 'Replace everything';

  @override
  String settingsImportDone(int habits, int tasks, int sessions) {
    return 'Imported: $habits habits, $tasks tasks, $sessions sessions';
  }

  @override
  String get settingsImportFailed => 'Import failed';

  @override
  String get timerRepeat => 'One more like this';

  @override
  String get recommendationEvidenceScopeLabel => 'Context match';

  @override
  String get recommendationEvidenceCountLabel => 'Sessions behind it';

  @override
  String get recommendationEvidenceRateLabel => 'Worked out';

  @override
  String get recommendationScopeExact => 'exactly this one';

  @override
  String get recommendationScopeSimilar => 'similar work';

  @override
  String get recommendationScopeBroad => 'this mood in general';

  @override
  String get recommendationScopeNone => 'no data yet';

  @override
  String get drifterTangle => 'Tangle';

  @override
  String get drifterTangleFlavor =>
      'Two funnels meeting at a single thread. The longer you pull, the tighter it sits.';

  @override
  String get drifterMote => 'Motes';

  @override
  String get drifterMoteFlavor =>
      'Not one thing but eight small ones around the edges. None of them weighs anything.';

  @override
  String get drifterHusk => 'Husk';

  @override
  String get drifterHuskFlavor =>
      'A closed shell with nothing left inside. Someone emptied this task a while ago.';

  @override
  String get drifterSiphon => 'Siphon';

  @override
  String get drifterSiphonFlavor =>
      'Wide at the top, a thin trickle at the bottom. Everything goes in, almost nothing comes out.';

  @override
  String get drifterKnot => 'Knot';

  @override
  String get drifterKnotFlavor =>
      'A post with two crossbars. Not a creature — a thing standing in the way.';

  @override
  String get drifterVeil => 'Veil';

  @override
  String get drifterVeilFlavor =>
      'A heavy drape sliding across at an angle. It does not hide the work, it dims it.';

  @override
  String get mapWorld1Name => 'The Still Room';

  @override
  String get mapWorld2Name => 'The Loud Field';

  @override
  String get mapWorld3Name => 'The Long Hall';

  @override
  String get characterStage5 => 'A full corona';

  @override
  String get characterStage6 => 'Almost a sun';

  @override
  String get characterRank1 => 'A spark';

  @override
  String get characterRank2 => 'A flicker';

  @override
  String get characterRank3 => 'An ember';

  @override
  String get characterRank4 => 'A steady flame';

  @override
  String get characterRank5 => 'A torch';

  @override
  String get characterRank6 => 'A beacon';

  @override
  String get characterRank7 => 'A furnace';

  @override
  String get characterRank8 => 'A small sun';

  @override
  String get characterStagesTitle => 'How it grows';

  @override
  String get characterStagesBody =>
      'The shape changes on its own at these levels. Nothing here is hidden — this is the whole ladder.';

  @override
  String characterStageAtLevel(int level) {
    return 'Level $level';
  }

  @override
  String get characterStageCurrent => 'You are here';

  @override
  String characterNextStage(int level) {
    return 'Next change at level $level';
  }

  @override
  String get characterFinalStage =>
      'Final shape. Everything ahead is just more of it.';

  @override
  String get battleTitle => 'Encounter';

  @override
  String get battleEnemyHp => 'Its HP';

  @override
  String get battleProgressHint =>
      'Its HP falls with your focus time. Finish the session and the damage sticks.';

  @override
  String get battleVictoryTitle => 'It\'s down.';

  @override
  String get battleVictoryBody =>
      'You sat the session out to the end, and that was enough. Respect.';

  @override
  String get battleBossVictoryTitle => 'The way is open.';

  @override
  String get battleHeldTitle => 'It held its ground.';

  @override
  String get battleHeldBody =>
      'You stopped early, so it stopped taking damage. It is still standing, and so are you. Come back to it.';

  @override
  String get battleBossResetTitle => 'It pulled itself back together.';

  @override
  String get battleBossResetBody =>
      'Your stamina ran out, so the boss is back at full HP. The XP you earned stays — that part is yours.';

  @override
  String battleXpLine(int xp) {
    return 'Earned this session: +$xp XP';
  }

  @override
  String get battleBossStakes =>
      'Run out of stamina and it goes back to full HP.';

  @override
  String get battleTimerHint =>
      'Same session, same timer — it just has a face on it now.';

  @override
  String get onboardingModeTitle => 'How should it run?';

  @override
  String get onboardingModeBody =>
      'You can switch this later in Settings — nothing is locked in.';

  @override
  String get onboardingModePlain => 'Just the tracker';

  @override
  String get onboardingModePlainBody =>
      'Sessions, habits, statistics. Nothing on top of them.';

  @override
  String get onboardingModeGame => 'With the game';

  @override
  String get onboardingModeGameBody =>
      'The same tracker, plus a map to move along, opponents your sessions wear down, and a character that grows with them.';

  @override
  String get photoSectionTitle => 'Photo';

  @override
  String get photoAdd => 'Add a photo';

  @override
  String get photoHint =>
      'What you are actually working on — a notebook, a screen, a desk. Stays on this device.';

  @override
  String get photoReplace => 'Replace';

  @override
  String get photoRemove => 'Remove';

  @override
  String get photoFromCamera => 'Take one';

  @override
  String get photoFromGallery => 'Pick from gallery';

  @override
  String get photoSourceTitle => 'Where from?';

  @override
  String get photoFailed => 'Could not attach that photo.';

  @override
  String get photoMissing => 'The file is gone from this device.';

  @override
  String get photoViewerTitle => 'Session photo';

  @override
  String get historyTitle => 'Recent sessions';

  @override
  String get historyEmpty => 'Nothing in this range yet.';

  @override
  String get historyDelete => 'Delete';

  @override
  String get historyDeleteTitle => 'Delete this session?';

  @override
  String get historyDeleteBody =>
      'It leaves history and stops counting toward statistics. The attached photo is deleted from the device too. There is no undo.';

  @override
  String get historyDeleted => 'Session deleted.';

  @override
  String historyMinutes(int minutes) {
    return '$minutes min';
  }
}
