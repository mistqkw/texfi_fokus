// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'TexFi f0kus';

  @override
  String get commonCancel => 'Скасувати';

  @override
  String get commonSave => 'Зберегти';

  @override
  String get commonDelete => 'Видалити';

  @override
  String get commonEdit => 'Змінити';

  @override
  String get commonNext => 'Далі';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonStart => 'Почати';

  @override
  String get commonSkip => 'Пропустити';

  @override
  String get commonAdd => 'Додати';

  @override
  String get commonClose => 'Закрити';

  @override
  String get commonMinutes => 'хв';

  @override
  String commonMinutesFull(int count) {
    return '$count хв';
  }

  @override
  String get onboardingWelcomeTitle => 'TexFi f0kus';

  @override
  String get onboardingWelcomeBody =>
      'Фокус-таймер, який вчиться того, як ти працюєш насправді, і трекер звичок, який не дає зіскочити.';

  @override
  String get onboardingMoodTitle => 'Почни з настрою';

  @override
  String get onboardingMoodBody =>
      'Перед кожною сесією перемикаєш тумблер: погано, нормально, добре, full f0kus. Застосунок підбирає техніку й тривалість під цей стан.';

  @override
  String get onboardingLearningTitle => 'Він вчиться на тобі';

  @override
  String get onboardingLearningBody =>
      'Кожна завершена або покинута сесія показує застосунку, яка техніка працює в тебе за якого настрою. Рекомендації стають точнішими.';

  @override
  String get onboardingHabitsTitle => 'Звички з наслідками';

  @override
  String get onboardingHabitsBody =>
      'Ставиш денну ціль і сам пишеш, що собі винен, якщо не виконаєш. Застосунок це запамʼятає й нагадає.';

  @override
  String get onboardingThemeTitle => 'Обери вигляд';

  @override
  String get onboardingThemeBody =>
      'Піксель-арт у темряві, тепло та сонячно на світлі.';

  @override
  String get onboardingFirstHabitTitle => 'Перша звичка';

  @override
  String get onboardingFirstHabitBody =>
      'Назви одну справу, яку хочеш робити щодня. Решту додаси пізніше.';

  @override
  String get onboardingNotificationsTitle => 'Нагадування';

  @override
  String get onboardingNotificationsBody =>
      'Дозволь TexFi f0kus нагадувати про невиконані цілі наприкінці дня.';

  @override
  String get onboardingAllowNotifications => 'Дозволити сповіщення';

  @override
  String get onboardingFinish => 'Поїхали';

  @override
  String get homeTitle => 'f0kus';

  @override
  String get homeStreakLabel => 'Стрік';

  @override
  String homeStreakValue(int days) {
    return '$days д';
  }

  @override
  String get homeTodayHabits => 'Сьогодні';

  @override
  String get homeHabitsEmpty => 'Звичок ще немає. Додай першу.';

  @override
  String get homeStartFocus => 'Почати фокус-сесію';

  @override
  String get homeFocusToday => 'Сьогодні';

  @override
  String get homeFocusWeek => 'За тиждень';

  @override
  String get homeSummaryTitle => 'У фокусі';

  @override
  String get homeAllDone => 'Усі цілі на сьогодні закриті. Повага.';

  @override
  String homePending(int count, int total) {
    return 'Залишилось цілей: $count з $total';
  }

  @override
  String get navHome => 'Головна';

  @override
  String get navHabits => 'Звички';

  @override
  String get navStats => 'Статистика';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get moodTitle => 'Як ти зараз?';

  @override
  String get moodBad => 'погано';

  @override
  String get moodNeutral => 'нормально';

  @override
  String get moodGood => 'добре';

  @override
  String get moodFullFokus => 'full f0kus';

  @override
  String get moodHint =>
      'Проведи пальцем або натисни. У кожного стану своя вібрація.';

  @override
  String get moodPickTaskTitle => 'Над чим працюєш?';

  @override
  String get moodTaskHint => 'Назва задачі';

  @override
  String get moodNewTask => 'Нова задача';

  @override
  String get moodCategory => 'Категорія';

  @override
  String get moodDifficulty => 'Складність';

  @override
  String get moodDifficultyEasy => 'Легка';

  @override
  String get moodDifficultyMedium => 'Середня';

  @override
  String get moodDifficultyHard => 'Важка';

  @override
  String get moodContinue => 'Далі';

  @override
  String get moodTaskRequired => 'Введи назву задачі';

  @override
  String get categoryStudy => 'Навчання';

  @override
  String get categoryWork => 'Робота';

  @override
  String get categoryCreative => 'Творчість';

  @override
  String get categoryChores => 'Справи';

  @override
  String get categorySport => 'Спорт';

  @override
  String get categoryOther => 'Інше';

  @override
  String get recommendationTitle => 'Рекомендуємо';

  @override
  String get recommendationColdStart =>
      'Безпечний варіант під цей настрій — застосунок ще мало знає про твої сесії.';

  @override
  String get recommendationLearned =>
      'На основі твоїх минулих сесій зі схожим настроєм і задачею.';

  @override
  String recommendationConfidence(int percent) {
    return 'Впевненість: $percent%';
  }

  @override
  String get recommendationStart => 'Почати';

  @override
  String get recommendationManual => 'Налаштувати вручну';

  @override
  String get recommendationManualTitle => 'Свій таймер';

  @override
  String get recommendationFocusLength => 'Тривалість фокусу';

  @override
  String get recommendationBreakLength => 'Тривалість перерви';

  @override
  String get recommendationCycles => 'Циклів';

  @override
  String get recommendationSoundOnEnd => 'Звук наприкінці циклу';

  @override
  String get recommendationAutoStart => 'Автостарт наступного циклу';

  @override
  String get techniqueSprint15 => 'Спринт 15';

  @override
  String get techniqueSprint15Desc =>
      '15 хвилин роботи, 5 відпочинку. Мʼякий захід, коли нічого не йде.';

  @override
  String get techniquePomodoro2505 => 'Помодоро 25/5';

  @override
  String get techniquePomodoro2505Desc =>
      'Класика. 25 хвилин роботи, 5 відпочинку, чотири цикли.';

  @override
  String get techniquePomodoro5010 => 'Помодоро 50/10';

  @override
  String get techniquePomodoro5010Desc =>
      '50 хвилин роботи, 10 відпочинку. Для задач, де потрібен розгін.';

  @override
  String get techniqueDeepWork90 => 'Глибока робота 90';

  @override
  String get techniqueDeepWork90Desc =>
      '90 хвилин без перерв. Тільки коли ти справді в потоці.';

  @override
  String get timerFocusPhase => 'ФОКУС';

  @override
  String get timerBreakPhase => 'ПЕРЕРВА';

  @override
  String get timerPause => 'Пауза';

  @override
  String get timerResume => 'Продовжити';

  @override
  String get timerStop => 'Стоп';

  @override
  String get timerSkip => 'Пропустити';

  @override
  String timerCycleOf(int current, int total) {
    return 'Цикл $current з $total';
  }

  @override
  String get timerDialHint => 'Крути диск, щоб виправити час, що лишився';

  @override
  String get timerStopConfirmTitle => 'Зупинити сесію?';

  @override
  String get timerStopConfirmBody =>
      'Вона запишеться як перервана — це теж корисні дані.';

  @override
  String get timerStopConfirmYes => 'Зупинити';

  @override
  String get timerDoneTitle => 'Сесію завершено';

  @override
  String get timerAbortedTitle => 'Сесію перервано';

  @override
  String get timerRateQuestion => 'Наскільки продуктивно вийшло?';

  @override
  String get timerRateSave => 'Зберегти';

  @override
  String get timerFullscreen => 'На весь екран';

  @override
  String get timerExitFullscreen => 'Вийти з повноекранного';

  @override
  String get habitsTitle => 'Звички';

  @override
  String get habitsEmpty => 'Звичок ще немає.';

  @override
  String get habitsEmptyHint =>
      'Звичка — це денна ціль плюс те, що ти собі винен, якщо її пропустиш.';

  @override
  String get habitsAdd => 'Нова звичка';

  @override
  String get habitEditTitle => 'Змінити звичку';

  @override
  String get habitNameLabel => 'Назва';

  @override
  String get habitNameHint => 'Читати 30 хвилин';

  @override
  String get habitNameRequired => 'Введи назву';

  @override
  String get habitFrequency => 'Частота';

  @override
  String get habitDaily => 'Щодня';

  @override
  String get habitCustomDays => 'Обрані дні';

  @override
  String get habitPunishmentLabel => 'Якщо не виконаєш';

  @override
  String get habitPunishmentHint => '50 віджимань, завтра без кави…';

  @override
  String get habitPunishmentRequired => 'Напиши, що ти собі винен';

  @override
  String get habitPunishmentExplainer =>
      'Ти пишеш сам, застосунок просто памʼятає й нагадує. Нічого не автоматизується.';

  @override
  String get habitReminderTime => 'Час нагадування';

  @override
  String get habitReminderOff => 'Вимк';

  @override
  String get habitDeleteConfirmTitle => 'Видалити звичку?';

  @override
  String get habitDeleteConfirmBody => 'Історія за нею теж видалиться.';

  @override
  String habitStreakLabel(int days) {
    return 'Стрік: $days д';
  }

  @override
  String get habitDaysShort => 'Пн Вт Ср Чт Пт Сб Нд';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsWeek => 'Тиждень';

  @override
  String get statsMonth => 'Місяць';

  @override
  String get statsActivity => 'Активність';

  @override
  String get statsActivityHint =>
      'Кожен квадрат — день. Що яскравіший, то більше часу у фокусі.';

  @override
  String get statsFocusByDay => 'Час у фокусі по днях';

  @override
  String get statsMoodBreakdown => 'Настрій і результат';

  @override
  String get statsMoodBreakdownHint =>
      'Як часто ти доводиш до кінця сесію, почату в кожному настрої.';

  @override
  String get statsByCategory => 'За категоріями задач';

  @override
  String get statsHabitSuccess => 'Виконання звичок';

  @override
  String get statsTotalFocus => 'Усього у фокусі';

  @override
  String get statsSessions => 'Сесій';

  @override
  String get statsCompletionRate => 'Завершено';

  @override
  String get statsEmpty => 'Даних поки мало. Проведи кілька сесій.';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsAppearance => 'Вигляд';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeSystem => 'Системна';

  @override
  String get settingsThemeLight => 'Світла';

  @override
  String get settingsThemeDark => 'Темна';

  @override
  String get settingsFeedback => 'Звук і вібрація';

  @override
  String get settingsSounds => 'Звуки';

  @override
  String get settingsVibration => 'Вібрація';

  @override
  String get settingsVibrationIntensity => 'Інтенсивність вібрації';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get settingsLanguageSystem => 'Системна';

  @override
  String get settingsNotifications => 'Сповіщення';

  @override
  String get settingsNotificationsEnabled => 'Нагадування про звички';

  @override
  String get settingsDailyReminderTime => 'Підсумок дня о';

  @override
  String get settingsData => 'Дані';

  @override
  String get settingsExport => 'Експорт даних у JSON';

  @override
  String settingsExportDone(String path) {
    return 'Збережено в $path';
  }

  @override
  String get settingsExportFailed => 'Не вдалося експортувати';

  @override
  String get settingsAbout => 'Про застосунок';

  @override
  String settingsVersion(String version) {
    return 'Версія $version';
  }

  @override
  String get settingsAboutBody =>
      'Частина екосистеми TexFi. Працює повністю офлайн — дані не залишають пристрій.';

  @override
  String notificationHabitTitle(String habit) {
    return 'Ціль не виконана: $habit';
  }

  @override
  String notificationHabitBody(String punishment) {
    return 'Ти обіцяв собі: $punishment';
  }

  @override
  String get notificationDailyTitle => 'Кінець дня';

  @override
  String notificationDailyBody(int count) {
    return 'Незакритих цілей: $count. Ще є час.';
  }

  @override
  String get notificationChannelHabits => 'Нагадування про звички';

  @override
  String get notificationChannelHabitsDesc =>
      'Нагадування про невиконані денні цілі';
}
