import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
    Locale('ru'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TexFi f0kus'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get commonStart;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get commonMinutes;

  /// No description provided for @commonMinutesFull.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String commonMinutesFull(int count);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'TexFi f0kus'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A focus timer that learns how you actually work — and a habit tracker that does not let you off the hook.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with your mood'**
  String get onboardingMoodTitle;

  /// No description provided for @onboardingMoodBody.
  ///
  /// In en, this message translates to:
  /// **'Before every session you flip a switch: bad, normal, good, full f0kus. The app picks a technique and a length that fit that state.'**
  String get onboardingMoodBody;

  /// No description provided for @onboardingLearningTitle.
  ///
  /// In en, this message translates to:
  /// **'It learns from you'**
  String get onboardingLearningTitle;

  /// No description provided for @onboardingLearningBody.
  ///
  /// In en, this message translates to:
  /// **'Every finished or abandoned session teaches the app which technique works for you in which mood. Recommendations get sharper over time.'**
  String get onboardingLearningBody;

  /// No description provided for @onboardingHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits with consequences'**
  String get onboardingHabitsTitle;

  /// No description provided for @onboardingHabitsBody.
  ///
  /// In en, this message translates to:
  /// **'Set a daily goal and write down what you owe yourself if you miss it. The app remembers it and reminds you.'**
  String get onboardingHabitsBody;

  /// No description provided for @onboardingThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your look'**
  String get onboardingThemeTitle;

  /// No description provided for @onboardingThemeBody.
  ///
  /// In en, this message translates to:
  /// **'Pixel-art in the dark, warm and sunny in the light.'**
  String get onboardingThemeBody;

  /// No description provided for @onboardingFirstHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first habit'**
  String get onboardingFirstHabitTitle;

  /// No description provided for @onboardingFirstHabitBody.
  ///
  /// In en, this message translates to:
  /// **'Name one thing you want to do every day. You can add more later.'**
  String get onboardingFirstHabitBody;

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Let TexFi f0kus notify you about unfinished goals at the end of the day.'**
  String get onboardingNotificationsBody;

  /// No description provided for @onboardingAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get onboardingAllowNotifications;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get onboardingFinish;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'f0kus'**
  String get homeTitle;

  /// No description provided for @homeStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get homeStreakLabel;

  /// No description provided for @homeStreakBasis.
  ///
  /// In en, this message translates to:
  /// **'from habits'**
  String get homeStreakBasis;

  /// No description provided for @homeStreakValue.
  ///
  /// In en, this message translates to:
  /// **'{days} d'**
  String homeStreakValue(int days);

  /// No description provided for @homeTodayHabits.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeTodayHabits;

  /// No description provided for @homeHabitsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Add your first one.'**
  String get homeHabitsEmpty;

  /// No description provided for @homeStartFocus.
  ///
  /// In en, this message translates to:
  /// **'Start focus session'**
  String get homeStartFocus;

  /// No description provided for @homeFocusToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeFocusToday;

  /// No description provided for @homeFocusWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get homeFocusWeek;

  /// No description provided for @homeSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'In focus'**
  String get homeSummaryTitle;

  /// No description provided for @homeAllDone.
  ///
  /// In en, this message translates to:
  /// **'All goals done today. Respect.'**
  String get homeAllDone;

  /// No description provided for @homePending.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} goals left'**
  String homePending(int count, int total);

  /// No description provided for @insightTitle.
  ///
  /// In en, this message translates to:
  /// **'Pattern spotted'**
  String get insightTitle;

  /// No description provided for @insightBestMood.
  ///
  /// In en, this message translates to:
  /// **'Sessions you start in “{mood}” finish {percent}% of the time — your strongest state.'**
  String insightBestMood(String mood, int percent);

  /// No description provided for @insightBestWeekday.
  ///
  /// In en, this message translates to:
  /// **'{day} is your deepest focus day — {minutes} min on average.'**
  String insightBestWeekday(String day, int minutes);

  /// No description provided for @insightBestTime.
  ///
  /// In en, this message translates to:
  /// **'{time} is when you follow through: {percent}% of those sessions land.'**
  String insightBestTime(String time, int percent);

  /// No description provided for @insightBestTechnique.
  ///
  /// In en, this message translates to:
  /// **'{technique} works for you more than anything else — {percent}% of those sessions land.'**
  String insightBestTechnique(String technique, int percent);

  /// No description provided for @insightBasis.
  ///
  /// In en, this message translates to:
  /// **'From {count} sessions over the last 30 days.'**
  String insightBasis(int count);

  /// No description provided for @timeOfDayMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get timeOfDayMorning;

  /// No description provided for @timeOfDayAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get timeOfDayAfternoon;

  /// No description provided for @timeOfDayEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get timeOfDayEvening;

  /// No description provided for @timeOfDayNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get timeOfDayNight;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get navHabits;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @moodTitle.
  ///
  /// In en, this message translates to:
  /// **'How are you right now?'**
  String get moodTitle;

  /// No description provided for @moodBad.
  ///
  /// In en, this message translates to:
  /// **'bad'**
  String get moodBad;

  /// No description provided for @moodNeutral.
  ///
  /// In en, this message translates to:
  /// **'normal'**
  String get moodNeutral;

  /// No description provided for @moodGood.
  ///
  /// In en, this message translates to:
  /// **'good'**
  String get moodGood;

  /// No description provided for @moodFullFokus.
  ///
  /// In en, this message translates to:
  /// **'full f0kus'**
  String get moodFullFokus;

  /// No description provided for @moodHint.
  ///
  /// In en, this message translates to:
  /// **'Slide or tap to switch. Each state has its own vibration.'**
  String get moodHint;

  /// No description provided for @moodPickTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you working on?'**
  String get moodPickTaskTitle;

  /// No description provided for @moodTaskHint.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get moodTaskHint;

  /// No description provided for @moodNewTask.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get moodNewTask;

  /// No description provided for @moodCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get moodCategory;

  /// No description provided for @moodDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get moodDifficulty;

  /// No description provided for @moodDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get moodDifficultyEasy;

  /// No description provided for @moodDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get moodDifficultyMedium;

  /// No description provided for @moodDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get moodDifficultyHard;

  /// No description provided for @moodContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get moodContinue;

  /// No description provided for @moodTaskRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a task name'**
  String get moodTaskRequired;

  /// No description provided for @categoryStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get categoryStudy;

  /// No description provided for @categoryWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get categoryWork;

  /// No description provided for @categoryCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get categoryCreative;

  /// No description provided for @categoryChores.
  ///
  /// In en, this message translates to:
  /// **'Chores'**
  String get categoryChores;

  /// No description provided for @categorySport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get categorySport;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @recommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendationTitle;

  /// No description provided for @recommendationColdStart.
  ///
  /// In en, this message translates to:
  /// **'A safe default for this mood — the app has not seen enough of your sessions yet.'**
  String get recommendationColdStart;

  /// No description provided for @recommendationColdStartProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} more sessions and the picks become yours.'**
  String recommendationColdStartProgress(int count);

  /// No description provided for @recommendationWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this'**
  String get recommendationWhyTitle;

  /// No description provided for @recommendationBadgePersonal.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL'**
  String get recommendationBadgePersonal;

  /// No description provided for @recommendationBadgeDefault.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get recommendationBadgeDefault;

  /// No description provided for @recommendationEvidenceExact.
  ///
  /// In en, this message translates to:
  /// **'In this exact setup you ran {count} sessions with it — {percent}% of them worked out.'**
  String recommendationEvidenceExact(int count, int percent);

  /// No description provided for @recommendationEvidenceSimilar.
  ///
  /// In en, this message translates to:
  /// **'With a similar mood and task you ran {count} sessions with it — {percent}% of them worked out.'**
  String recommendationEvidenceSimilar(int count, int percent);

  /// No description provided for @recommendationEvidenceBroad.
  ///
  /// In en, this message translates to:
  /// **'In this mood you ran {count} sessions with it — {percent}% of them worked out.'**
  String recommendationEvidenceBroad(int count, int percent);

  /// No description provided for @recommendationEvidenceNone.
  ///
  /// In en, this message translates to:
  /// **'No history for this one yet — the app is checking whether it fits you.'**
  String get recommendationEvidenceNone;

  /// No description provided for @recommendationExploring.
  ///
  /// In en, this message translates to:
  /// **'A deliberate try-out, not your best known option. However it goes, it sharpens the next pick.'**
  String get recommendationExploring;

  /// No description provided for @recommendationHistorySize.
  ///
  /// In en, this message translates to:
  /// **'Learned from {count} sessions in total.'**
  String recommendationHistorySize(int count);

  /// No description provided for @recommendationStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get recommendationStart;

  /// No description provided for @recommendationManual.
  ///
  /// In en, this message translates to:
  /// **'Set up manually'**
  String get recommendationManual;

  /// No description provided for @recommendationManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom timer'**
  String get recommendationManualTitle;

  /// No description provided for @recommendationFocusLength.
  ///
  /// In en, this message translates to:
  /// **'Focus length'**
  String get recommendationFocusLength;

  /// No description provided for @recommendationBreakLength.
  ///
  /// In en, this message translates to:
  /// **'Break length'**
  String get recommendationBreakLength;

  /// No description provided for @recommendationCycles.
  ///
  /// In en, this message translates to:
  /// **'Cycles'**
  String get recommendationCycles;

  /// No description provided for @recommendationSoundOnEnd.
  ///
  /// In en, this message translates to:
  /// **'Sound when a cycle ends'**
  String get recommendationSoundOnEnd;

  /// No description provided for @recommendationAutoStart.
  ///
  /// In en, this message translates to:
  /// **'Auto-start the next cycle'**
  String get recommendationAutoStart;

  /// No description provided for @techniqueSprint15.
  ///
  /// In en, this message translates to:
  /// **'Sprint 15'**
  String get techniqueSprint15;

  /// No description provided for @techniqueSprint15Desc.
  ///
  /// In en, this message translates to:
  /// **'15 min of work, 5 min off. Gentle start when nothing works.'**
  String get techniqueSprint15Desc;

  /// No description provided for @techniquePomodoro2505.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro 25/5'**
  String get techniquePomodoro2505;

  /// No description provided for @techniquePomodoro2505Desc.
  ///
  /// In en, this message translates to:
  /// **'The classic. 25 min of work, 5 min off, four cycles.'**
  String get techniquePomodoro2505Desc;

  /// No description provided for @techniquePomodoro5010.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro 50/10'**
  String get techniquePomodoro5010;

  /// No description provided for @techniquePomodoro5010Desc.
  ///
  /// In en, this message translates to:
  /// **'50 min of work, 10 min off. For tasks that need momentum.'**
  String get techniquePomodoro5010Desc;

  /// No description provided for @techniqueDeepWork90.
  ///
  /// In en, this message translates to:
  /// **'Deep work 90'**
  String get techniqueDeepWork90;

  /// No description provided for @techniqueDeepWork90Desc.
  ///
  /// In en, this message translates to:
  /// **'90 min without interruptions. Only when you are truly on.'**
  String get techniqueDeepWork90Desc;

  /// No description provided for @timerFocusPhase.
  ///
  /// In en, this message translates to:
  /// **'FOCUS'**
  String get timerFocusPhase;

  /// No description provided for @timerBreakPhase.
  ///
  /// In en, this message translates to:
  /// **'BREAK'**
  String get timerBreakPhase;

  /// No description provided for @timerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timerPause;

  /// No description provided for @timerResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get timerResume;

  /// No description provided for @timerStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get timerStop;

  /// No description provided for @timerSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get timerSkip;

  /// No description provided for @timerCycleOf.
  ///
  /// In en, this message translates to:
  /// **'Cycle {current} of {total}'**
  String timerCycleOf(int current, int total);

  /// No description provided for @timerDialHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the dial to adjust the remaining time'**
  String get timerDialHint;

  /// No description provided for @timerStopConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop the session?'**
  String get timerStopConfirmTitle;

  /// No description provided for @timerStopConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It will be logged as interrupted — that is also useful data.'**
  String get timerStopConfirmBody;

  /// No description provided for @timerStopConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get timerStopConfirmYes;

  /// No description provided for @timerDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Session finished'**
  String get timerDoneTitle;

  /// No description provided for @timerAbortedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session interrupted'**
  String get timerAbortedTitle;

  /// No description provided for @timerRateQuestion.
  ///
  /// In en, this message translates to:
  /// **'How productive was it?'**
  String get timerRateQuestion;

  /// No description provided for @timerRateSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get timerRateSave;

  /// No description provided for @timerFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get timerFullscreen;

  /// No description provided for @timerExitFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Exit fullscreen'**
  String get timerExitFullscreen;

  /// No description provided for @habitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitsTitle;

  /// No description provided for @habitsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No habits yet.'**
  String get habitsEmpty;

  /// No description provided for @habitsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'A habit is a daily goal plus what you owe yourself if you skip it.'**
  String get habitsEmptyHint;

  /// No description provided for @habitsAdd.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get habitsAdd;

  /// No description provided for @habitEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get habitEditTitle;

  /// No description provided for @habitNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get habitNameLabel;

  /// No description provided for @habitNameHint.
  ///
  /// In en, this message translates to:
  /// **'Read for 30 minutes'**
  String get habitNameHint;

  /// No description provided for @habitNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get habitNameRequired;

  /// No description provided for @habitFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get habitFrequency;

  /// No description provided for @habitDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get habitDaily;

  /// No description provided for @habitCustomDays.
  ///
  /// In en, this message translates to:
  /// **'Selected days'**
  String get habitCustomDays;

  /// No description provided for @habitPunishmentLabel.
  ///
  /// In en, this message translates to:
  /// **'If you miss it'**
  String get habitPunishmentLabel;

  /// No description provided for @habitPunishmentHint.
  ///
  /// In en, this message translates to:
  /// **'50 push-ups, no coffee tomorrow…'**
  String get habitPunishmentHint;

  /// No description provided for @habitPunishmentRequired.
  ///
  /// In en, this message translates to:
  /// **'Write down what you owe yourself'**
  String get habitPunishmentRequired;

  /// No description provided for @habitPunishmentExplainer.
  ///
  /// In en, this message translates to:
  /// **'You write it, the app just remembers it and reminds you. Nothing is automated.'**
  String get habitPunishmentExplainer;

  /// No description provided for @habitReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get habitReminderTime;

  /// No description provided for @habitReminderOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get habitReminderOff;

  /// No description provided for @habitDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete habit?'**
  String get habitDeleteConfirmTitle;

  /// No description provided for @habitDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Its history will be removed too.'**
  String get habitDeleteConfirmBody;

  /// No description provided for @habitStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak: {days} d'**
  String habitStreakLabel(int days);

  /// No description provided for @habitDaysShort.
  ///
  /// In en, this message translates to:
  /// **'Mon Tue Wed Thu Fri Sat Sun'**
  String get habitDaysShort;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @statsWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get statsWeek;

  /// No description provided for @statsMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get statsMonth;

  /// No description provided for @statsActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get statsActivity;

  /// No description provided for @statsActivityHint.
  ///
  /// In en, this message translates to:
  /// **'Every square is a day. The brighter it is, the more time in focus.'**
  String get statsActivityHint;

  /// No description provided for @statsFocusByDay.
  ///
  /// In en, this message translates to:
  /// **'Focus time by day'**
  String get statsFocusByDay;

  /// No description provided for @statsMoodBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Mood and results'**
  String get statsMoodBreakdown;

  /// No description provided for @statsMoodBreakdownHint.
  ///
  /// In en, this message translates to:
  /// **'How often you finish a session started in each mood.'**
  String get statsMoodBreakdownHint;

  /// No description provided for @statsByCategory.
  ///
  /// In en, this message translates to:
  /// **'By task category'**
  String get statsByCategory;

  /// No description provided for @statsHabitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Habit success'**
  String get statsHabitSuccess;

  /// No description provided for @statsTotalFocus.
  ///
  /// In en, this message translates to:
  /// **'Total in focus'**
  String get statsTotalFocus;

  /// No description provided for @statsSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get statsSessions;

  /// No description provided for @statsCompletionRate.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get statsCompletionRate;

  /// No description provided for @statsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet. Run a couple of sessions.'**
  String get statsEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsFeedback.
  ///
  /// In en, this message translates to:
  /// **'Sound and vibration'**
  String get settingsFeedback;

  /// No description provided for @settingsSounds.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get settingsSounds;

  /// No description provided for @settingsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// No description provided for @settingsVibrationIntensity.
  ///
  /// In en, this message translates to:
  /// **'Vibration intensity'**
  String get settingsVibrationIntensity;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Habit reminders'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsDailyReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Daily summary at'**
  String get settingsDailyReminderTime;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export data to JSON'**
  String get settingsExport;

  /// No description provided for @settingsExportDone.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String settingsExportDone(String path);

  /// No description provided for @settingsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get settingsExportFailed;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'Part of the TexFi ecosystem. Works fully offline — your data never leaves the device.'**
  String get settingsAboutBody;

  /// No description provided for @notificationHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal not done: {habit}'**
  String notificationHabitTitle(String habit);

  /// No description provided for @notificationHabitBody.
  ///
  /// In en, this message translates to:
  /// **'You promised yourself: {punishment}'**
  String notificationHabitBody(String punishment);

  /// No description provided for @notificationDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'End of the day'**
  String get notificationDailyTitle;

  /// No description provided for @notificationDailyBody.
  ///
  /// In en, this message translates to:
  /// **'{count} goals are still unfinished. Still time.'**
  String notificationDailyBody(int count);

  /// No description provided for @notificationChannelHabits.
  ///
  /// In en, this message translates to:
  /// **'Habit reminders'**
  String get notificationChannelHabits;

  /// No description provided for @notificationChannelHabitsDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders about unfinished daily goals'**
  String get notificationChannelHabitsDesc;

  /// No description provided for @interruptionQuestion.
  ///
  /// In en, this message translates to:
  /// **'What pulled you out?'**
  String get interruptionQuestion;

  /// No description provided for @interruptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional — it helps the app read your patterns.'**
  String get interruptionOptional;

  /// No description provided for @interruptionDistracted.
  ///
  /// In en, this message translates to:
  /// **'Got distracted'**
  String get interruptionDistracted;

  /// No description provided for @interruptionWrongTask.
  ///
  /// In en, this message translates to:
  /// **'Wrong task'**
  String get interruptionWrongTask;

  /// No description provided for @interruptionTired.
  ///
  /// In en, this message translates to:
  /// **'Too tired'**
  String get interruptionTired;

  /// No description provided for @interruptionNoComment.
  ///
  /// In en, this message translates to:
  /// **'Rather not say'**
  String get interruptionNoComment;

  /// No description provided for @sessionNoteQuestion.
  ///
  /// In en, this message translates to:
  /// **'How did it go?'**
  String get sessionNoteQuestion;

  /// No description provided for @sessionNoteHint.
  ///
  /// In en, this message translates to:
  /// **'A few words or a sticker'**
  String get sessionNoteHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl', 'ru', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
