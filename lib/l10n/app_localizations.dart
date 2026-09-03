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

  /// No description provided for @moodLateNightNote.
  ///
  /// In en, this message translates to:
  /// **'The nights have been long lately. Take care of yourself.'**
  String get moodLateNightNote;

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

  /// Section label for choosing which sound plays when a focus session ends
  ///
  /// In en, this message translates to:
  /// **'Completion sound'**
  String get settingsAlarmSound;

  /// Explains that the completion sound bypasses silent mode and that tapping previews it
  ///
  /// In en, this message translates to:
  /// **'Plays through the alarm channel, so it is audible on silent. Tap to preview.'**
  String get settingsAlarmSoundHint;

  /// Name of the completion sound preset: a short two-note arcade coin blip
  ///
  /// In en, this message translates to:
  /// **'Arcade coin'**
  String get soundArcadeCoin;

  /// Name of the completion sound preset: a rising major arpeggio
  ///
  /// In en, this message translates to:
  /// **'Level up'**
  String get soundLevelUp;

  /// Name of the completion sound preset: three sharp repeated beeps
  ///
  /// In en, this message translates to:
  /// **'Alarm beep'**
  String get soundAlarmBeep;

  /// Name of the completion sound preset: a gentle descending triangle-wave chime
  ///
  /// In en, this message translates to:
  /// **'Soft chime'**
  String get soundSoftChime;

  /// Name of the completion sound preset: a descending run, like a machine switching off
  ///
  /// In en, this message translates to:
  /// **'Power down'**
  String get soundPowerDown;

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
  /// **'Couldn\'t save the file. Your data is untouched — try again.'**
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

  /// No description provided for @guardShortBreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Straight back in?'**
  String get guardShortBreakTitle;

  /// No description provided for @guardShortBreakBody.
  ///
  /// In en, this message translates to:
  /// **'You just finished a session. A real break makes the next one better.'**
  String get guardShortBreakBody;

  /// No description provided for @guardBurnoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Three in a row cut short'**
  String get guardBurnoutTitle;

  /// No description provided for @guardBurnoutBody.
  ///
  /// In en, this message translates to:
  /// **'Maybe today is a day to rest. Nothing is stopping you if you disagree.'**
  String get guardBurnoutBody;

  /// No description provided for @guardNightCapTitle.
  ///
  /// In en, this message translates to:
  /// **'It is late'**
  String get guardNightCapTitle;

  /// No description provided for @guardNightCapBody.
  ///
  /// In en, this message translates to:
  /// **'Past your night hour we keep sessions short, whatever the mood and the engine say.'**
  String get guardNightCapBody;

  /// No description provided for @guardStartAnyway.
  ///
  /// In en, this message translates to:
  /// **'Start anyway'**
  String get guardStartAnyway;

  /// No description provided for @guardTakeABreak.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get guardTakeABreak;

  /// No description provided for @settingsBurnout.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get settingsBurnout;

  /// No description provided for @settingsShortBreakWarning.
  ///
  /// In en, this message translates to:
  /// **'Short break warning'**
  String get settingsShortBreakWarning;

  /// No description provided for @settingsShortBreakSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Warn if a session starts within {count} min of the last one'**
  String settingsShortBreakSubtitle(int count);

  /// No description provided for @settingsShortBreakOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsShortBreakOff;

  /// No description provided for @settingsNightCap.
  ///
  /// In en, this message translates to:
  /// **'Night soft cap'**
  String get settingsNightCap;

  /// No description provided for @settingsNightCapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Suggest nothing longer than 25/5 late at night'**
  String get settingsNightCapSubtitle;

  /// No description provided for @settingsNightCapHour.
  ///
  /// In en, this message translates to:
  /// **'Night starts at'**
  String get settingsNightCapHour;

  /// No description provided for @habitByWeekdays.
  ///
  /// In en, this message translates to:
  /// **'On chosen weekdays'**
  String get habitByWeekdays;

  /// No description provided for @habitTimesPerWeek.
  ///
  /// In en, this message translates to:
  /// **'N times a week'**
  String get habitTimesPerWeek;

  /// No description provided for @habitTimesPerWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Times a week'**
  String get habitTimesPerWeekLabel;

  /// No description provided for @habitTimesPerWeekValue.
  ///
  /// In en, this message translates to:
  /// **'{count}× a week'**
  String habitTimesPerWeekValue(int count);

  /// No description provided for @habitRewardLabel.
  ///
  /// In en, this message translates to:
  /// **'If you keep it up'**
  String get habitRewardLabel;

  /// No description provided for @habitRewardHint.
  ///
  /// In en, this message translates to:
  /// **'A long bath, that game, a day off'**
  String get habitRewardHint;

  /// No description provided for @habitRewardExplainer.
  ///
  /// In en, this message translates to:
  /// **'Optional, and just as much your own deal as the penalty — the app only remembers it and shows it when you get there.'**
  String get habitRewardExplainer;

  /// No description provided for @habitRewardStreakDays.
  ///
  /// In en, this message translates to:
  /// **'Streak needed'**
  String get habitRewardStreakDays;

  /// No description provided for @habitRewardAfter.
  ///
  /// In en, this message translates to:
  /// **'Reward after {count} days'**
  String habitRewardAfter(int count);

  /// No description provided for @habitRewardEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned — {count} days in a row'**
  String habitRewardEarned(int count);

  /// No description provided for @habitStreakWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks in a row'**
  String habitStreakWeeks(int count);

  /// No description provided for @habitWeekProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {target} this week'**
  String habitWeekProgress(int done, int target);

  /// No description provided for @habitFreezeAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow streak freeze'**
  String get habitFreezeAllow;

  /// No description provided for @habitFreezeAllowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One skipped day every {days} days keeps the streak'**
  String habitFreezeAllowSubtitle(int days);

  /// No description provided for @habitFreezeToday.
  ///
  /// In en, this message translates to:
  /// **'Freeze'**
  String get habitFreezeToday;

  /// No description provided for @habitFreezeUndo.
  ///
  /// In en, this message translates to:
  /// **'Unfreeze'**
  String get habitFreezeUndo;

  /// No description provided for @habitFreezeHint.
  ///
  /// In en, this message translates to:
  /// **'Skip today without losing the streak'**
  String get habitFreezeHint;

  /// No description provided for @habitFreezeUndoHint.
  ///
  /// In en, this message translates to:
  /// **'Today is frozen — the streak holds'**
  String get habitFreezeUndoHint;

  /// No description provided for @habitFreezeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No freeze left yet'**
  String get habitFreezeUnavailable;

  /// No description provided for @habitFrozenToday.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get habitFrozenToday;

  /// No description provided for @statsPunishment.
  ///
  /// In en, this message translates to:
  /// **'When the penalty bit'**
  String get statsPunishment;

  /// No description provided for @statsPunishmentCount.
  ///
  /// In en, this message translates to:
  /// **'{missed} of {scheduled} days missed'**
  String statsPunishmentCount(int missed, int scheduled);

  /// No description provided for @statsPunishmentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing missed in this period.'**
  String get statsPunishmentEmpty;

  /// No description provided for @statsInterruptions.
  ///
  /// In en, this message translates to:
  /// **'Why sessions broke off'**
  String get statsInterruptions;

  /// No description provided for @statsInterruptionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No interrupted sessions in this period.'**
  String get statsInterruptionsEmpty;

  /// No description provided for @statsInterruptionUnnamed.
  ///
  /// In en, this message translates to:
  /// **'No reason given'**
  String get statsInterruptionUnnamed;

  /// No description provided for @homePlanDay.
  ///
  /// In en, this message translates to:
  /// **'Plan the day'**
  String get homePlanDay;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s plan'**
  String get planTitle;

  /// No description provided for @planIntro.
  ///
  /// In en, this message translates to:
  /// **'Two or three tasks, roughly in order. Optional — it just saves you from inventing a task when you already sat down to work.'**
  String get planIntro;

  /// No description provided for @planAddHint.
  ///
  /// In en, this message translates to:
  /// **'What are you doing today?'**
  String get planAddHint;

  /// No description provided for @planEnough.
  ///
  /// In en, this message translates to:
  /// **'Three is usually enough for one day.'**
  String get planEnough;

  /// No description provided for @planToday.
  ///
  /// In en, this message translates to:
  /// **'In the plan'**
  String get planToday;

  /// No description provided for @planEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned yet.'**
  String get planEmpty;

  /// No description provided for @planFromTasks.
  ///
  /// In en, this message translates to:
  /// **'From your tasks'**
  String get planFromTasks;

  /// No description provided for @planDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get planDone;

  /// No description provided for @planUndone.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get planUndone;

  /// No description provided for @planSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get planSubtasks;

  /// No description provided for @planSubtaskHint.
  ///
  /// In en, this message translates to:
  /// **'One step'**
  String get planSubtaskHint;

  /// No description provided for @planSubtaskCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} steps'**
  String planSubtaskCount(int done, int total);

  /// No description provided for @planSubtasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No steps yet — a session shows them as a checklist.'**
  String get planSubtasksEmpty;

  /// No description provided for @planSubtasksFull.
  ///
  /// In en, this message translates to:
  /// **'{count} steps is the limit for one session.'**
  String planSubtasksFull(int count);

  /// No description provided for @moodFromPlan.
  ///
  /// In en, this message translates to:
  /// **'From today\'s plan'**
  String get moodFromPlan;

  /// No description provided for @notificationDailyProductive.
  ///
  /// In en, this message translates to:
  /// **'Today: {sessions} sessions, {minutes} min in focus, mostly {mood}.'**
  String notificationDailyProductive(int sessions, int minutes, String mood);

  /// No description provided for @notificationDailyAllDone.
  ///
  /// In en, this message translates to:
  /// **'Everything is closed today. Well done.'**
  String get notificationDailyAllDone;

  /// No description provided for @notificationChannelTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get notificationChannelTimer;

  /// No description provided for @notificationChannelTimerDesc.
  ///
  /// In en, this message translates to:
  /// **'End of a focus block, a break or a whole session'**
  String get notificationChannelTimerDesc;

  /// No description provided for @notificationTimerFocusDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus block done'**
  String get notificationTimerFocusDoneTitle;

  /// No description provided for @notificationTimerFocusDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Cycle {cycle} of {total} is over. Break time.'**
  String notificationTimerFocusDoneBody(int cycle, int total);

  /// No description provided for @notificationTimerBreakDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Break is over'**
  String get notificationTimerBreakDoneTitle;

  /// No description provided for @notificationTimerBreakDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Back to focus when you are ready.'**
  String get notificationTimerBreakDoneBody;

  /// No description provided for @notificationTimerSessionDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get notificationTimerSessionDoneTitle;

  /// No description provided for @notificationTimerSessionDoneBody.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min planned in focus. Well held.'**
  String notificationTimerSessionDoneBody(int minutes);

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @gameSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Game mode'**
  String get gameSectionTitle;

  /// No description provided for @gameModeToggle.
  ///
  /// In en, this message translates to:
  /// **'Play instead of just tracking'**
  String get gameModeToggle;

  /// No description provided for @gameModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sessions and habits stay exactly as they are — a map, drifters and levels appear on top of them.'**
  String get gameModeSubtitle;

  /// No description provided for @gameModeOffNote.
  ///
  /// In en, this message translates to:
  /// **'Turning it off only hides the game. Your level and map progress are kept, and you will come back to the same spot.'**
  String get gameModeOffNote;

  /// No description provided for @gameReset.
  ///
  /// In en, this message translates to:
  /// **'Start the game over'**
  String get gameReset;

  /// No description provided for @gameResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clears XP and the map. Sessions and habits are not affected.'**
  String get gameResetSubtitle;

  /// No description provided for @gameResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start over? The level and the map go back to zero. Sessions, habits and statistics stay untouched.'**
  String get gameResetConfirm;

  /// No description provided for @gameResetDone.
  ///
  /// In en, this message translates to:
  /// **'The map starts from the beginning.'**
  String get gameResetDone;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @mapWorld.
  ///
  /// In en, this message translates to:
  /// **'World {world}'**
  String mapWorld(int world);

  /// No description provided for @mapAllCleared.
  ///
  /// In en, this message translates to:
  /// **'Every world is cleared. Sessions still bring XP.'**
  String get mapAllCleared;

  /// No description provided for @mapNodeLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get mapNodeLocked;

  /// No description provided for @mapNodeCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get mapNodeCleared;

  /// No description provided for @mapNodeCurrent.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get mapNodeCurrent;

  /// No description provided for @mapBossNode.
  ///
  /// In en, this message translates to:
  /// **'Boss'**
  String get mapBossNode;

  /// No description provided for @characterTitle.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get characterTitle;

  /// No description provided for @characterLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String characterLevel(int level);

  /// No description provided for @characterXp.
  ///
  /// In en, this message translates to:
  /// **'{current} / {needed} XP'**
  String characterXp(int current, int needed);

  /// No description provided for @characterToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to the next level'**
  String characterToNextLevel(int xp);

  /// No description provided for @characterDriftersDefeated.
  ///
  /// In en, this message translates to:
  /// **'Drifters defeated'**
  String get characterDriftersDefeated;

  /// No description provided for @characterBossesDefeated.
  ///
  /// In en, this message translates to:
  /// **'Bosses defeated'**
  String get characterBossesDefeated;

  /// No description provided for @characterTotalXp.
  ///
  /// In en, this message translates to:
  /// **'XP earned'**
  String get characterTotalXp;

  /// No description provided for @characterStage1.
  ///
  /// In en, this message translates to:
  /// **'Just a core'**
  String get characterStage1;

  /// No description provided for @characterStage2.
  ///
  /// In en, this message translates to:
  /// **'A shaped flame'**
  String get characterStage2;

  /// No description provided for @characterStage3.
  ///
  /// In en, this message translates to:
  /// **'A halo of sparks'**
  String get characterStage3;

  /// No description provided for @characterStage4.
  ///
  /// In en, this message translates to:
  /// **'A crown'**
  String get characterStage4;

  /// No description provided for @drifterBuzz.
  ///
  /// In en, this message translates to:
  /// **'Buzz'**
  String get drifterBuzz;

  /// No description provided for @drifterCreep.
  ///
  /// In en, this message translates to:
  /// **'Creep'**
  String get drifterCreep;

  /// No description provided for @drifterLoom.
  ///
  /// In en, this message translates to:
  /// **'Loom'**
  String get drifterLoom;

  /// No description provided for @drifterBuzzFlavor.
  ///
  /// In en, this message translates to:
  /// **'Wide wings, tiny body. Pings once and carries your attention off.'**
  String get drifterBuzzFlavor;

  /// No description provided for @drifterCreepFlavor.
  ///
  /// In en, this message translates to:
  /// **'Low and many-legged. Does not swoop — it creeps up from below.'**
  String get drifterCreepFlavor;

  /// No description provided for @drifterLoomFlavor.
  ///
  /// In en, this message translates to:
  /// **'Tall, narrow, one empty eye. Just stands there and watches.'**
  String get drifterLoomFlavor;

  /// No description provided for @bossScroll.
  ///
  /// In en, this message translates to:
  /// **'The Scroll'**
  String get bossScroll;

  /// No description provided for @bossChorus.
  ///
  /// In en, this message translates to:
  /// **'The Chorus'**
  String get bossChorus;

  /// No description provided for @bossHollow.
  ///
  /// In en, this message translates to:
  /// **'The Hollow'**
  String get bossHollow;

  /// No description provided for @bossScrollFlavor.
  ///
  /// In en, this message translates to:
  /// **'A ribbon coiled into itself. It has no end, that is the whole trick.'**
  String get bossScrollFlavor;

  /// No description provided for @bossChorusFlavor.
  ///
  /// In en, this message translates to:
  /// **'Not one creature but a cluster of heads, all talking at once.'**
  String get bossChorusFlavor;

  /// No description provided for @bossHollowFlavor.
  ///
  /// In en, this message translates to:
  /// **'A heavy frame around nothing at all. It pulls inward.'**
  String get bossHollowFlavor;

  /// No description provided for @encounterTitle.
  ///
  /// In en, this message translates to:
  /// **'Facing you'**
  String get encounterTitle;

  /// No description provided for @encounterHp.
  ///
  /// In en, this message translates to:
  /// **'{current} / {max} HP'**
  String encounterHp(int current, int max);

  /// No description provided for @encounterWounded.
  ///
  /// In en, this message translates to:
  /// **'Wounded — finish it off.'**
  String get encounterWounded;

  /// No description provided for @encounterHealed.
  ///
  /// In en, this message translates to:
  /// **'It had time to recover while you were away.'**
  String get encounterHealed;

  /// No description provided for @encounterBossHint.
  ///
  /// In en, this message translates to:
  /// **'Only sessions started in full f0kus really hurt this one.'**
  String get encounterBossHint;

  /// No description provided for @encounterBossStamina.
  ///
  /// In en, this message translates to:
  /// **'Your stamina: {current} of {total}'**
  String encounterBossStamina(int current, int total);

  /// No description provided for @encounterBossStaminaHint.
  ///
  /// In en, this message translates to:
  /// **'Each abandoned f0kus run costs one.'**
  String get encounterBossStaminaHint;

  /// No description provided for @encounterFokusMissing.
  ///
  /// In en, this message translates to:
  /// **'Pick full f0kus at check-in to fight it properly.'**
  String get encounterFokusMissing;

  /// No description provided for @gameXpGained.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String gameXpGained(int xp);

  /// No description provided for @gameLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String gameLevelUp(int level);

  /// No description provided for @gameLevelUpBody.
  ///
  /// In en, this message translates to:
  /// **'Your flame has changed.'**
  String get gameLevelUpBody;

  /// No description provided for @gameDrifterDefeated.
  ///
  /// In en, this message translates to:
  /// **'Drifter defeated'**
  String get gameDrifterDefeated;

  /// No description provided for @gameBossDefeated.
  ///
  /// In en, this message translates to:
  /// **'Boss defeated'**
  String get gameBossDefeated;

  /// No description provided for @gameBossDefeatedBody.
  ///
  /// In en, this message translates to:
  /// **'The way to the next world is open.'**
  String get gameBossDefeatedBody;

  /// No description provided for @gamePlayerDefeated.
  ///
  /// In en, this message translates to:
  /// **'The boss caught its breath'**
  String get gamePlayerDefeated;

  /// No description provided for @gamePlayerDefeatedBody.
  ///
  /// In en, this message translates to:
  /// **'It is back to full health, and so is your stamina. Come back when you are ready — nothing else was lost.'**
  String get gamePlayerDefeatedBody;

  /// No description provided for @gameContinue.
  ///
  /// In en, this message translates to:
  /// **'Onward'**
  String get gameContinue;

  /// No description provided for @settingsAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent colour'**
  String get settingsAccent;

  /// No description provided for @settingsAccentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only the accent tone changes — the rest of the palette stays as it is.'**
  String get settingsAccentSubtitle;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import from JSON'**
  String get settingsImport;

  /// No description provided for @settingsImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore an earlier export on a new device'**
  String get settingsImportSubtitle;

  /// No description provided for @settingsImportPathHint.
  ///
  /// In en, this message translates to:
  /// **'Full path to the exported .json file.'**
  String get settingsImportPathHint;

  /// No description provided for @settingsImportNoFile.
  ///
  /// In en, this message translates to:
  /// **'No file at that path'**
  String get settingsImportNoFile;

  /// No description provided for @settingsImportWarnTitle.
  ///
  /// In en, this message translates to:
  /// **'This touches your data'**
  String get settingsImportWarnTitle;

  /// No description provided for @settingsImportWarnBody.
  ///
  /// In en, this message translates to:
  /// **'Merge keeps what you already have and adds what is missing. Replace wipes the current history first — there is no undo.'**
  String get settingsImportWarnBody;

  /// No description provided for @settingsImportMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get settingsImportMerge;

  /// No description provided for @settingsImportReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace everything'**
  String get settingsImportReplace;

  /// No description provided for @settingsImportDone.
  ///
  /// In en, this message translates to:
  /// **'Imported: {habits} habits, {tasks} tasks, {sessions} sessions'**
  String settingsImportDone(int habits, int tasks, int sessions);

  /// No description provided for @settingsImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that file. Nothing was changed — check it\'s an export from this app.'**
  String get settingsImportFailed;

  /// No description provided for @timerRepeat.
  ///
  /// In en, this message translates to:
  /// **'One more like this'**
  String get timerRepeat;

  /// No description provided for @recommendationEvidenceScopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Context match'**
  String get recommendationEvidenceScopeLabel;

  /// No description provided for @recommendationEvidenceCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Sessions behind it'**
  String get recommendationEvidenceCountLabel;

  /// No description provided for @recommendationEvidenceRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Worked out'**
  String get recommendationEvidenceRateLabel;

  /// No description provided for @recommendationScopeExact.
  ///
  /// In en, this message translates to:
  /// **'exactly this one'**
  String get recommendationScopeExact;

  /// No description provided for @recommendationScopeSimilar.
  ///
  /// In en, this message translates to:
  /// **'similar work'**
  String get recommendationScopeSimilar;

  /// No description provided for @recommendationScopeBroad.
  ///
  /// In en, this message translates to:
  /// **'this mood in general'**
  String get recommendationScopeBroad;

  /// No description provided for @recommendationScopeNone.
  ///
  /// In en, this message translates to:
  /// **'no data yet'**
  String get recommendationScopeNone;

  /// No description provided for @drifterTangle.
  ///
  /// In en, this message translates to:
  /// **'Tangle'**
  String get drifterTangle;

  /// No description provided for @drifterTangleFlavor.
  ///
  /// In en, this message translates to:
  /// **'Two funnels meeting at a single thread. The longer you pull, the tighter it sits.'**
  String get drifterTangleFlavor;

  /// No description provided for @drifterMote.
  ///
  /// In en, this message translates to:
  /// **'Motes'**
  String get drifterMote;

  /// No description provided for @drifterMoteFlavor.
  ///
  /// In en, this message translates to:
  /// **'Not one thing but eight small ones around the edges. None of them weighs anything.'**
  String get drifterMoteFlavor;

  /// No description provided for @drifterHusk.
  ///
  /// In en, this message translates to:
  /// **'Husk'**
  String get drifterHusk;

  /// No description provided for @drifterHuskFlavor.
  ///
  /// In en, this message translates to:
  /// **'A closed shell with nothing left inside. Someone emptied this task a while ago.'**
  String get drifterHuskFlavor;

  /// No description provided for @drifterSiphon.
  ///
  /// In en, this message translates to:
  /// **'Siphon'**
  String get drifterSiphon;

  /// No description provided for @drifterSiphonFlavor.
  ///
  /// In en, this message translates to:
  /// **'Wide at the top, a thin trickle at the bottom. Everything goes in, almost nothing comes out.'**
  String get drifterSiphonFlavor;

  /// No description provided for @drifterKnot.
  ///
  /// In en, this message translates to:
  /// **'Knot'**
  String get drifterKnot;

  /// No description provided for @drifterKnotFlavor.
  ///
  /// In en, this message translates to:
  /// **'A post with two crossbars. Not a creature — a thing standing in the way.'**
  String get drifterKnotFlavor;

  /// No description provided for @drifterVeil.
  ///
  /// In en, this message translates to:
  /// **'Veil'**
  String get drifterVeil;

  /// No description provided for @drifterVeilFlavor.
  ///
  /// In en, this message translates to:
  /// **'A heavy drape sliding across at an angle. It does not hide the work, it dims it.'**
  String get drifterVeilFlavor;

  /// No description provided for @mapWorld1Name.
  ///
  /// In en, this message translates to:
  /// **'The Still Room'**
  String get mapWorld1Name;

  /// No description provided for @mapWorld2Name.
  ///
  /// In en, this message translates to:
  /// **'The Loud Field'**
  String get mapWorld2Name;

  /// No description provided for @mapWorld3Name.
  ///
  /// In en, this message translates to:
  /// **'The Long Hall'**
  String get mapWorld3Name;

  /// No description provided for @characterStage5.
  ///
  /// In en, this message translates to:
  /// **'A full corona'**
  String get characterStage5;

  /// No description provided for @characterStage6.
  ///
  /// In en, this message translates to:
  /// **'Almost a sun'**
  String get characterStage6;

  /// No description provided for @characterRank1.
  ///
  /// In en, this message translates to:
  /// **'A spark'**
  String get characterRank1;

  /// No description provided for @characterRank2.
  ///
  /// In en, this message translates to:
  /// **'A flicker'**
  String get characterRank2;

  /// No description provided for @characterRank3.
  ///
  /// In en, this message translates to:
  /// **'An ember'**
  String get characterRank3;

  /// No description provided for @characterRank4.
  ///
  /// In en, this message translates to:
  /// **'A steady flame'**
  String get characterRank4;

  /// No description provided for @characterRank5.
  ///
  /// In en, this message translates to:
  /// **'A torch'**
  String get characterRank5;

  /// No description provided for @characterRank6.
  ///
  /// In en, this message translates to:
  /// **'A beacon'**
  String get characterRank6;

  /// No description provided for @characterRank7.
  ///
  /// In en, this message translates to:
  /// **'A furnace'**
  String get characterRank7;

  /// No description provided for @characterRank8.
  ///
  /// In en, this message translates to:
  /// **'A small sun'**
  String get characterRank8;

  /// No description provided for @characterStagesTitle.
  ///
  /// In en, this message translates to:
  /// **'How it grows'**
  String get characterStagesTitle;

  /// No description provided for @characterStagesBody.
  ///
  /// In en, this message translates to:
  /// **'The shape changes on its own at these levels. Nothing here is hidden — this is the whole ladder.'**
  String get characterStagesBody;

  /// No description provided for @characterStageAtLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String characterStageAtLevel(int level);

  /// No description provided for @characterStageCurrent.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get characterStageCurrent;

  /// No description provided for @characterNextStage.
  ///
  /// In en, this message translates to:
  /// **'Next change at level {level}'**
  String characterNextStage(int level);

  /// No description provided for @characterFinalStage.
  ///
  /// In en, this message translates to:
  /// **'Final shape. Everything ahead is just more of it.'**
  String get characterFinalStage;

  /// No description provided for @battleTitle.
  ///
  /// In en, this message translates to:
  /// **'Encounter'**
  String get battleTitle;

  /// No description provided for @battleEnemyHp.
  ///
  /// In en, this message translates to:
  /// **'Its HP'**
  String get battleEnemyHp;

  /// No description provided for @battleProgressHint.
  ///
  /// In en, this message translates to:
  /// **'Its HP falls with your focus time. Finish the session and the damage sticks.'**
  String get battleProgressHint;

  /// No description provided for @battleVictoryTitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s down.'**
  String get battleVictoryTitle;

  /// No description provided for @battleVictoryBody.
  ///
  /// In en, this message translates to:
  /// **'You sat the session out to the end, and that was enough. Respect.'**
  String get battleVictoryBody;

  /// No description provided for @battleBossVictoryTitle.
  ///
  /// In en, this message translates to:
  /// **'The way is open.'**
  String get battleBossVictoryTitle;

  /// No description provided for @battleHeldTitle.
  ///
  /// In en, this message translates to:
  /// **'It held its ground.'**
  String get battleHeldTitle;

  /// No description provided for @battleHeldBody.
  ///
  /// In en, this message translates to:
  /// **'You stopped early, so it stopped taking damage. It is still standing, and so are you. Come back to it.'**
  String get battleHeldBody;

  /// No description provided for @battleBossResetTitle.
  ///
  /// In en, this message translates to:
  /// **'It pulled itself back together.'**
  String get battleBossResetTitle;

  /// No description provided for @battleBossResetBody.
  ///
  /// In en, this message translates to:
  /// **'Your stamina ran out, so the boss is back at full HP. The XP you earned stays — that part is yours.'**
  String get battleBossResetBody;

  /// No description provided for @battleXpLine.
  ///
  /// In en, this message translates to:
  /// **'Earned this session: +{xp} XP'**
  String battleXpLine(int xp);

  /// No description provided for @battleBossStakes.
  ///
  /// In en, this message translates to:
  /// **'Run out of stamina and it goes back to full HP.'**
  String get battleBossStakes;

  /// No description provided for @battleTimerHint.
  ///
  /// In en, this message translates to:
  /// **'Same session, same timer — it just has a face on it now.'**
  String get battleTimerHint;

  /// No description provided for @onboardingModeTitle.
  ///
  /// In en, this message translates to:
  /// **'How should it run?'**
  String get onboardingModeTitle;

  /// No description provided for @onboardingModeBody.
  ///
  /// In en, this message translates to:
  /// **'You can switch this later in Settings — nothing is locked in.'**
  String get onboardingModeBody;

  /// No description provided for @onboardingModePlain.
  ///
  /// In en, this message translates to:
  /// **'Just the tracker'**
  String get onboardingModePlain;

  /// No description provided for @onboardingModePlainBody.
  ///
  /// In en, this message translates to:
  /// **'Sessions, habits, statistics. Nothing on top of them.'**
  String get onboardingModePlainBody;

  /// No description provided for @onboardingModeGame.
  ///
  /// In en, this message translates to:
  /// **'With the game'**
  String get onboardingModeGame;

  /// No description provided for @onboardingModeGameBody.
  ///
  /// In en, this message translates to:
  /// **'The same tracker, plus a map to move along, opponents your sessions wear down, and a character that grows with them.'**
  String get onboardingModeGameBody;

  /// No description provided for @photoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoSectionTitle;

  /// No description provided for @photoAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get photoAdd;

  /// No description provided for @photoHint.
  ///
  /// In en, this message translates to:
  /// **'What you are actually working on — a notebook, a screen, a desk. Stays on this device.'**
  String get photoHint;

  /// No description provided for @photoReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get photoReplace;

  /// No description provided for @photoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get photoRemove;

  /// No description provided for @photoFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Take one'**
  String get photoFromCamera;

  /// No description provided for @photoFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get photoFromGallery;

  /// No description provided for @photoSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Where from?'**
  String get photoSourceTitle;

  /// No description provided for @photoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not attach that photo.'**
  String get photoFailed;

  /// No description provided for @photoMissing.
  ///
  /// In en, this message translates to:
  /// **'The file is gone from this device.'**
  String get photoMissing;

  /// No description provided for @photoViewerTitle.
  ///
  /// In en, this message translates to:
  /// **'Session photo'**
  String get photoViewerTitle;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent sessions'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this range yet.'**
  String get historyEmpty;

  /// No description provided for @historyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get historyDelete;

  /// No description provided for @historyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this session?'**
  String get historyDeleteTitle;

  /// No description provided for @historyDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It leaves history and stops counting toward statistics. The attached photo is deleted from the device too. There is no undo.'**
  String get historyDeleteBody;

  /// No description provided for @historyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Session deleted.'**
  String get historyDeleted;

  /// No description provided for @historyMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String historyMinutes(int minutes);

  /// No description provided for @updateSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updateSectionTitle;

  /// No description provided for @updateCheckButton.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get updateCheckButton;

  /// No description provided for @updateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get updateChecking;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You have the latest version.'**
  String get updateUpToDate;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available v{version}'**
  String updateAvailable(String version);

  /// No description provided for @updateDownloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download and install'**
  String get updateDownloadButton;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String updateDownloading(int percent);

  /// No description provided for @updateInstallExplainerTitle.
  ///
  /// In en, this message translates to:
  /// **'About to install'**
  String get updateInstallExplainerTitle;

  /// No description provided for @updateInstallExplainerBody.
  ///
  /// In en, this message translates to:
  /// **'Android will ask for permission to install from this source. That is normal for apps that do not come from Google Play — f0kus is distributed as an .apk from GitHub.'**
  String get updateInstallExplainerBody;

  /// No description provided for @updateInstallExplainerOk.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get updateInstallExplainerOk;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not download the update. Try again later.'**
  String get updateFailed;

  /// No description provided for @updateNoApk.
  ///
  /// In en, this message translates to:
  /// **'This release has no package to install yet.'**
  String get updateNoApk;

  /// No description provided for @timerQuietMode.
  ///
  /// In en, this message translates to:
  /// **'Quiet mode'**
  String get timerQuietMode;

  /// No description provided for @timerQuietModeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to return'**
  String get timerQuietModeHint;

  /// No description provided for @mapWorldIntroLabel.
  ///
  /// In en, this message translates to:
  /// **'New world'**
  String get mapWorldIntroLabel;

  /// No description provided for @mapWorld1Epigraph.
  ///
  /// In en, this message translates to:
  /// **'Nothing here is loud. That is the whole difficulty.'**
  String get mapWorld1Epigraph;

  /// No description provided for @mapWorld2Epigraph.
  ///
  /// In en, this message translates to:
  /// **'Everything here wants a turn. None of it is yours.'**
  String get mapWorld2Epigraph;

  /// No description provided for @mapWorld3Epigraph.
  ///
  /// In en, this message translates to:
  /// **'The far end is out of sight. You walk it anyway.'**
  String get mapWorld3Epigraph;

  /// TexFi f0kus polish pass 2: techniqueCustomDesc
  ///
  /// In en, this message translates to:
  /// **'Your own preset. It competes with the built-in techniques on equal terms and builds up its own stats.'**
  String get techniqueCustomDesc;

  /// TexFi f0kus polish pass 2: settingsPresetsTitle
  ///
  /// In en, this message translates to:
  /// **'My presets'**
  String get settingsPresetsTitle;

  /// TexFi f0kus polish pass 2: settingsPresetsHint
  ///
  /// In en, this message translates to:
  /// **'Four built-in techniques don\'t fit everyone. A preset you add here is offered by the engine just like the built-in ones.'**
  String get settingsPresetsHint;

  /// TexFi f0kus polish pass 2: settingsPresetsEmpty
  ///
  /// In en, this message translates to:
  /// **'No presets yet. Add one if none of the four built-in rhythms is yours.'**
  String get settingsPresetsEmpty;

  /// TexFi f0kus polish pass 2: settingsPresetAdd
  ///
  /// In en, this message translates to:
  /// **'Add preset'**
  String get settingsPresetAdd;

  /// TexFi f0kus polish pass 2: settingsPresetEdit
  ///
  /// In en, this message translates to:
  /// **'Edit preset'**
  String get settingsPresetEdit;

  /// TexFi f0kus polish pass 2: settingsPresetName
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsPresetName;

  /// TexFi f0kus polish pass 2: settingsPresetNameHint
  ///
  /// In en, this message translates to:
  /// **'For example: 35/7'**
  String get settingsPresetNameHint;

  /// TexFi f0kus polish pass 2: settingsPresetLimitReached
  ///
  /// In en, this message translates to:
  /// **'Up to 5 presets. Each one is another option the engine has to learn, and they all share the same sessions.'**
  String get settingsPresetLimitReached;

  /// TexFi f0kus polish pass 2: settingsPresetDelete
  ///
  /// In en, this message translates to:
  /// **'Delete preset'**
  String get settingsPresetDelete;

  /// TexFi f0kus polish pass 2: settingsBurnoutStreakTitle
  ///
  /// In en, this message translates to:
  /// **'Aborted sessions in a row'**
  String get settingsBurnoutStreakTitle;

  /// TexFi f0kus polish pass 2: settingsBurnoutStreakHint
  ///
  /// In en, this message translates to:
  /// **'After this many aborted sessions in a row the app suggests stopping for today. Two is a bad hour; five is a whole stubborn day.'**
  String get settingsBurnoutStreakHint;

  /// TexFi f0kus polish pass 2: settingsWeekStartTitle
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get settingsWeekStartTitle;

  /// TexFi f0kus polish pass 2: settingsWeekStartHint
  ///
  /// In en, this message translates to:
  /// **'Affects the activity calendar and everything counted by weeks.'**
  String get settingsWeekStartHint;

  /// TexFi f0kus polish pass 2: settingsWeekStartMonday
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get settingsWeekStartMonday;

  /// TexFi f0kus polish pass 2: settingsWeekStartSunday
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get settingsWeekStartSunday;

  /// TexFi f0kus polish pass 2: settingsAutoBackupTitle
  ///
  /// In en, this message translates to:
  /// **'Weekly backup'**
  String get settingsAutoBackupTitle;

  /// TexFi f0kus polish pass 2: settingsAutoBackupHint
  ///
  /// In en, this message translates to:
  /// **'Once a week, quietly save a copy of everything to the app\'s backups folder. No cloud — the file stays on this device.'**
  String get settingsAutoBackupHint;

  /// TexFi f0kus polish pass 2: settingsAutoBackupNever
  ///
  /// In en, this message translates to:
  /// **'No copy made yet'**
  String get settingsAutoBackupNever;

  /// TexFi f0kus polish pass 2: statsSummaryEmpty
  ///
  /// In en, this message translates to:
  /// **'No sessions in this period. The numbers below stay at zero until the first one.'**
  String get statsSummaryEmpty;

  /// TexFi f0kus polish pass 2: statsActivityEmpty
  ///
  /// In en, this message translates to:
  /// **'The calendar fills in as you go: one square per day, brighter with more time in focus.'**
  String get statsActivityEmpty;

  /// TexFi f0kus polish pass 2: statsHabitsEmpty
  ///
  /// In en, this message translates to:
  /// **'No habits scheduled in this period — nothing to count yet.'**
  String get statsHabitsEmpty;

  /// TexFi f0kus polish pass 2: characterStatsEmptyNew
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Numbers start moving after your first finished session.'**
  String get characterStatsEmptyNew;

  /// TexFi f0kus polish pass 2: characterStatsNoWins
  ///
  /// In en, this message translates to:
  /// **'Sessions are happening, but none has been finished yet — only a session carried to the end counts as a win.'**
  String get characterStatsNoWins;

  /// TexFi f0kus polish pass 2: mapIntroTitle
  ///
  /// In en, this message translates to:
  /// **'Where this leads'**
  String get mapIntroTitle;

  /// TexFi f0kus polish pass 2: mapIntroBody
  ///
  /// In en, this message translates to:
  /// **'Each finished session is one step along the trail. Worlds open one after another — nothing here needs to be bought or guessed.'**
  String get mapIntroBody;

  /// TexFi f0kus polish pass 2: mapPreparing
  ///
  /// In en, this message translates to:
  /// **'Laying out the trail…'**
  String get mapPreparing;

  /// TexFi f0kus polish pass 2: commonLoadError
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this. Try again — the data is on this device, so nothing is lost.'**
  String get commonLoadError;

  /// TexFi f0kus polish pass 2: homeHabitsEmptyHint
  ///
  /// In en, this message translates to:
  /// **'A habit is a daily goal plus what you owe yourself if you skip it.'**
  String get homeHabitsEmptyHint;

  /// TexFi f0kus polish pass 2: planEmptyHint
  ///
  /// In en, this message translates to:
  /// **'A plan is a short list for today, not for the whole week — three lines is already a plan.'**
  String get planEmptyHint;

  /// TexFi f0kus polish pass 2: commonUndo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// TexFi f0kus polish pass 2: habitUndone
  ///
  /// In en, this message translates to:
  /// **'Habit marked done'**
  String get habitUndone;

  /// TexFi f0kus polish pass 2: habitsSearchHint
  ///
  /// In en, this message translates to:
  /// **'Find a habit'**
  String get habitsSearchHint;

  /// TexFi f0kus polish pass 2: habitsSearchNothing
  ///
  /// In en, this message translates to:
  /// **'No habit matches that.'**
  String get habitsSearchNothing;

  /// Number of aborted sessions in a row before the burnout warning
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} session} other{{count} sessions}}'**
  String settingsBurnoutStreakValue(int count);

  /// Which task category a map world resonates with
  ///
  /// In en, this message translates to:
  /// **'Leans toward {category}'**
  String mapWorldAffinity(String category);

  /// Explains the world/category resonance without turning it into a requirement
  ///
  /// In en, this message translates to:
  /// **'Sessions in that category leave a little more here. Anything else works just as well.'**
  String get mapWorldAffinityHint;

  /// Drifter memory, first tier: a plain count of abandoned runs
  ///
  /// In en, this message translates to:
  /// **'{count} runs at this one ended early. It is still standing.'**
  String encounterMemoryNoticed(int count);

  /// Drifter memory, second tier: points at the task, not at the person
  ///
  /// In en, this message translates to:
  /// **'{count} times now. Something about this task is not what the plan says it is.'**
  String encounterMemoryDeep(int count);

  /// Result sheet note naming why the extra XP appeared
  ///
  /// In en, this message translates to:
  /// **'This world leans toward {category} — a small bonus.'**
  String resultResonance(String category);

  /// Title of the optional lore section on the character screen
  ///
  /// In en, this message translates to:
  /// **'Scraps'**
  String get loreTitle;

  /// Subtitle of the lore section
  ///
  /// In en, this message translates to:
  /// **'Each world has something written on the back of it. It turns up once the thing at the end is gone.'**
  String get loreBody;

  /// Empty state of the lore section
  ///
  /// In en, this message translates to:
  /// **'Nothing yet. The first scrap is behind the first boss.'**
  String get loreEmpty;

  /// Placeholder for a lore scrap that is not unlocked yet
  ///
  /// In en, this message translates to:
  /// **'Not found yet'**
  String get loreLocked;

  /// Label of one lore scrap
  ///
  /// In en, this message translates to:
  /// **'Scrap {number}'**
  String loreScrap(int number);

  /// Lore scrap found after the first boss
  ///
  /// In en, this message translates to:
  /// **'On the floor of the still room: \"Left the door open for a minute. Came back and the minute was gone.\"'**
  String get loreFragment1;

  /// Lore scrap found after the second boss
  ///
  /// In en, this message translates to:
  /// **'Same handwriting, out in the field: \"They do not come in from outside. They are what I put down and did not pick up.\"'**
  String get loreFragment2;

  /// Lore scrap found after the third boss
  ///
  /// In en, this message translates to:
  /// **'At the far end of the hall: \"The hall is the same room. I have been walking it since I sat down.\"'**
  String get loreFragment3;

  /// Final lore scrap, unlocked only after every world is cleared
  ///
  /// In en, this message translates to:
  /// **'The last scrap, in no handwriting at all: \"It is quiet now. It will not stay quiet. That is fine — you know the way back.\"'**
  String get loreFragment4;
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
