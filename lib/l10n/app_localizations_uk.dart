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
  String get homeStreakBasis => 'за звичками';

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
  String get insightTitle => 'Помічено';

  @override
  String insightBestMood(String mood, int percent) {
    return 'Сесії, розпочаті в стані «$mood», доходять до кінця у $percent% випадків — це твій сильний стан.';
  }

  @override
  String insightBestWeekday(String day, int minutes) {
    return '$day — твій найглибший день: у середньому $minutes хв у фокусі.';
  }

  @override
  String insightBestTime(String time, int percent) {
    return '$time — час, коли ти доводиш до кінця: $percent% таких сесій закриваються.';
  }

  @override
  String insightBestTechnique(String technique, int percent) {
    return '«$technique» працює в тебе краще за інше — $percent% таких сесій закриваються.';
  }

  @override
  String insightBasis(int count) {
    return 'За $count сесіями за останні 30 днів.';
  }

  @override
  String get timeOfDayMorning => 'Ранок';

  @override
  String get timeOfDayAfternoon => 'День';

  @override
  String get timeOfDayEvening => 'Вечір';

  @override
  String get timeOfDayNight => 'Ніч';

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
  String recommendationColdStartProgress(int count) {
    return 'Ще $count сесій — і поради стануть твоїми.';
  }

  @override
  String get recommendationWhyTitle => 'Чому саме це';

  @override
  String get recommendationBadgePersonal => 'ОСОБИСТЕ';

  @override
  String get recommendationBadgeDefault => 'ДЕФОЛТ';

  @override
  String recommendationEvidenceExact(int count, int percent) {
    return 'Саме в такому контексті ти провів із нею $count сесій — $percent% із них вдалися.';
  }

  @override
  String recommendationEvidenceSimilar(int count, int percent) {
    return 'На схожому настрої та задачі ти провів із нею $count сесій — $percent% із них вдалися.';
  }

  @override
  String recommendationEvidenceBroad(int count, int percent) {
    return 'На цьому настрої ти провів із нею $count сесій — $percent% із них вдалися.';
  }

  @override
  String get recommendationEvidenceNone =>
      'Історії по ній ще немає — застосунок перевіряє, чи вона тобі підходить.';

  @override
  String get recommendationExploring =>
      'Це свідома перевірка, а не найкращий відомий варіант. Хай там як, наступний вибір стане точнішим.';

  @override
  String recommendationHistorySize(int count) {
    return 'Усього в навчанні $count сесій.';
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
  String get settingsAlarmSound => 'Звук завершення';

  @override
  String get settingsAlarmSoundHint =>
      'Лунає каналом будильника, тому чутно в беззвучному режимі. Торкніться, щоб прослухати.';

  @override
  String get soundArcadeCoin => 'Монетка';

  @override
  String get soundLevelUp => 'Новий рівень';

  @override
  String get soundAlarmBeep => 'Сигнал будильника';

  @override
  String get soundSoftChime => 'М\'який передзвін';

  @override
  String get soundPowerDown => 'Вимкнення';

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

  @override
  String get interruptionQuestion => 'Що збило?';

  @override
  String get interruptionOptional =>
      'Необов\'язково — допомагає застосунку зрозуміти твої закономірності.';

  @override
  String get interruptionDistracted => 'Відволікся';

  @override
  String get interruptionWrongTask => 'Завдання виявилось не те';

  @override
  String get interruptionTired => 'Втомився';

  @override
  String get interruptionNoComment => 'Не хочу казати';

  @override
  String get sessionNoteQuestion => 'Як пройшло?';

  @override
  String get sessionNoteHint => 'Кілька слів або стікер';

  @override
  String get guardShortBreakTitle => 'Одразу далі?';

  @override
  String get guardShortBreakBody =>
      'Ти щойно завершив сесію. Справжня перерва зробить наступну кращою.';

  @override
  String get guardBurnoutTitle => 'Три перервані поспіль';

  @override
  String get guardBurnoutBody =>
      'Можливо, сьогодні варто відпочити. Якщо не згоден — ніщо не заважає почати.';

  @override
  String get guardNightCapTitle => 'Пізно';

  @override
  String get guardNightCapBody =>
      'Після нічної години пропонуємо коротше — незалежно від настрою та рекомендації рушія.';

  @override
  String get guardStartAnyway => 'Усе одно почати';

  @override
  String get guardTakeABreak => 'Не зараз';

  @override
  String get settingsBurnout => 'Темп';

  @override
  String get settingsShortBreakWarning => 'Попереджати про коротку перерву';

  @override
  String settingsShortBreakSubtitle(int count) {
    return 'Попереджати, якщо старт раніше ніж за $count хв після попередньої сесії';
  }

  @override
  String get settingsShortBreakOff => 'Вимкнено';

  @override
  String get settingsNightCap => 'Нічний софт-кеп';

  @override
  String get settingsNightCapSubtitle => 'Уночі не пропонувати довше за 25/5';

  @override
  String get settingsNightCapHour => 'Ніч починається о';

  @override
  String get habitByWeekdays => 'У вибрані дні';

  @override
  String get habitTimesPerWeek => 'N разів на тиждень';

  @override
  String get habitTimesPerWeekLabel => 'Разів на тиждень';

  @override
  String habitTimesPerWeekValue(int count) {
    return '$count× на тиждень';
  }

  @override
  String get habitRewardLabel => 'Якщо витримаєш';

  @override
  String get habitRewardHint => 'Довга ванна, та сама гра, вихідний';

  @override
  String get habitRewardExplainer =>
      'Необов\'язково і так само твоя домовленість із собою, як і покарання, — застосунок лише запам\'ятає й покаже, коли дійдеш.';

  @override
  String get habitRewardStreakDays => 'Потрібна серія';

  @override
  String habitRewardAfter(int count) {
    return 'Нагорода за $count днів';
  }

  @override
  String habitRewardEarned(int count) {
    return 'Заслужено — $count днів поспіль';
  }

  @override
  String habitStreakWeeks(int count) {
    return '$count тижнів поспіль';
  }

  @override
  String habitWeekProgress(int done, int target) {
    return '$done із $target цього тижня';
  }

  @override
  String get habitFreezeAllow => 'Дозволити заморозку серії';

  @override
  String habitFreezeAllowSubtitle(int days) {
    return 'Один пропуск раз на $days днів зберігає серію';
  }

  @override
  String get habitFreezeToday => 'Заморозити';

  @override
  String get habitFreezeUndo => 'Розморозити';

  @override
  String get habitFreezeHint => 'Пропустити сьогодні, не втрачаючи серію';

  @override
  String get habitFreezeUndoHint => 'Сьогодні заморожено — серія тримається';

  @override
  String get habitFreezeUnavailable => 'Заморозка поки недоступна';

  @override
  String get habitFrozenToday => 'Заморожено';

  @override
  String get statsPunishment => 'Коли покарання спрацювало';

  @override
  String statsPunishmentCount(int missed, int scheduled) {
    return '$missed із $scheduled днів пропущено';
  }

  @override
  String get statsPunishmentEmpty => 'За період нічого не пропущено.';

  @override
  String get statsInterruptions => 'Чому сесії обривались';

  @override
  String get statsInterruptionsEmpty => 'За період перерваних сесій не було.';

  @override
  String get statsInterruptionUnnamed => 'Причину не названо';

  @override
  String get homePlanDay => 'Спланувати день';

  @override
  String get planTitle => 'План на сьогодні';

  @override
  String get planIntro =>
      'Дві-три задачі, приблизно по порядку. Необов\'язково — просто щоб не вигадувати задачу тоді, коли вже сів працювати.';

  @override
  String get planAddHint => 'Чим займешся сьогодні?';

  @override
  String get planEnough => 'Трьох на день зазвичай досить.';

  @override
  String get planToday => 'У плані';

  @override
  String get planEmpty => 'Поки нічого не заплановано.';

  @override
  String get planFromTasks => 'З твоїх задач';

  @override
  String get planDone => 'Відмітити';

  @override
  String get planUndone => 'Зняти відмітку';

  @override
  String get planSubtasks => 'Чекліст';

  @override
  String get planSubtaskHint => 'Один крок';

  @override
  String planSubtaskCount(int done, int total) {
    return '$done із $total кроків';
  }

  @override
  String get planSubtasksEmpty =>
      'Кроків поки немає — у сесії вони показуються чеклістом.';

  @override
  String planSubtasksFull(int count) {
    return '$count кроків — межа для однієї сесії.';
  }

  @override
  String get moodFromPlan => 'Із плану на сьогодні';

  @override
  String notificationDailyProductive(int sessions, int minutes, String mood) {
    return 'Сьогодні: $sessions сесії, $minutes хв у фокусі, найчастіше — $mood.';
  }

  @override
  String get notificationDailyAllDone => 'Сьогодні все закрито. Добре.';

  @override
  String get notificationChannelTimer => 'Таймер';

  @override
  String get notificationChannelTimerDesc =>
      'Кінець відрізка фокуса, перерви або всієї сесії';

  @override
  String get notificationTimerFocusDoneTitle => 'Відрізок фокуса завершено';

  @override
  String notificationTimerFocusDoneBody(int cycle, int total) {
    return 'Цикл $cycle з $total позаду. Час на перерву.';
  }

  @override
  String get notificationTimerBreakDoneTitle => 'Перерва скінчилася';

  @override
  String get notificationTimerBreakDoneBody =>
      'Повертайся у фокус, коли будеш готовий.';

  @override
  String get notificationTimerSessionDoneTitle => 'Сесію завершено';

  @override
  String notificationTimerSessionDoneBody(int minutes) {
    return '$minutes хв фокуса за планом. Добре тримався.';
  }

  @override
  String get navMap => 'Карта';

  @override
  String get gameSectionTitle => 'Ігровий режим';

  @override
  String get gameModeToggle => 'Грати, а не лише відмічати';

  @override
  String get gameModeSubtitle =>
      'Сесії та звички лишаються такими самими — понад ними з\'являються карта, дрифери та рівні.';

  @override
  String get gameModeOffNote =>
      'Вимкнення лише ховає гру. Рівень і поступ картою зберігаються, і ти повернешся на те саме місце.';

  @override
  String get gameReset => 'Почати гру спочатку';

  @override
  String get gameResetSubtitle =>
      'Обнуляє досвід і карту. Сесій і звичок не торкається.';

  @override
  String get gameResetConfirm =>
      'Почати спочатку? Рівень і карта обнуляться. Сесії, звички та статистика лишаться недоторканими.';

  @override
  String get gameResetDone => 'Карта починається спочатку.';

  @override
  String get mapTitle => 'Карта';

  @override
  String mapWorld(int world) {
    return 'Світ $world';
  }

  @override
  String get mapAllCleared =>
      'Усі світи пройдено. Досвід за сесії й далі нараховується.';

  @override
  String get mapNodeLocked => 'Закритий';

  @override
  String get mapNodeCleared => 'Пройдений';

  @override
  String get mapNodeCurrent => 'Ти тут';

  @override
  String get mapBossNode => 'Бос';

  @override
  String get characterTitle => 'Персонаж';

  @override
  String characterLevel(int level) {
    return 'Рівень $level';
  }

  @override
  String characterXp(int current, int needed) {
    return '$current / $needed XP';
  }

  @override
  String characterToNextLevel(int xp) {
    return '$xp XP до наступного рівня';
  }

  @override
  String get characterDriftersDefeated => 'Дриферів здолано';

  @override
  String get characterBossesDefeated => 'Босів здолано';

  @override
  String get characterTotalXp => 'Досвіду зароблено';

  @override
  String get characterStage1 => 'Лише ядро';

  @override
  String get characterStage2 => 'Вогник набув форми';

  @override
  String get characterStage3 => 'Ореол з іскор';

  @override
  String get characterStage4 => 'Корона';

  @override
  String get drifterBuzz => 'Гудок';

  @override
  String get drifterCreep => 'Повзун';

  @override
  String get drifterLoom => 'Морок';

  @override
  String get drifterBuzzFlavor =>
      'Розмах крил більший за тіло. Дзенькне раз — і уваги немає.';

  @override
  String get drifterCreepFlavor =>
      'Низький і багатоногий. Не налітає, а підбирається знизу.';

  @override
  String get drifterLoomFlavor =>
      'Високий, вузький, з одним порожнім оком. Просто стоїть і дивиться.';

  @override
  String get bossScroll => 'Стрічка';

  @override
  String get bossChorus => 'Хор';

  @override
  String get bossHollow => 'Порожнеча';

  @override
  String get bossScrollFlavor =>
      'Стрічка, згорнута сама в себе. У неї немає кінця — у цьому весь фокус.';

  @override
  String get bossChorusFlavor =>
      'Не одна істота, а гроно голів, і говорять вони разом.';

  @override
  String get bossHollowFlavor => 'Важка рама навколо нічого. Тягне всередину.';

  @override
  String get encounterTitle => 'Проти тебе';

  @override
  String encounterHp(int current, int max) {
    return '$current / $max HP';
  }

  @override
  String get encounterWounded => 'Поранений — доверши.';

  @override
  String get encounterHealed => 'Поки тебе не було, він устиг відновитися.';

  @override
  String get encounterBossHint =>
      'По-справжньому його пробивають лише сесії, розпочаті у full f0kus.';

  @override
  String encounterBossStamina(int current, int total) {
    return 'Твоя витривалість: $current з $total';
  }

  @override
  String get encounterBossStaminaHint =>
      'Кожен покинутий f0kus-захід коштує одного очка.';

  @override
  String get encounterFokusMissing =>
      'Обери full f0kus на чекіні, щоб битися на повну.';

  @override
  String gameXpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String gameLevelUp(int level) {
    return 'Рівень $level';
  }

  @override
  String get gameLevelUpBody => 'Твій вогник змінився.';

  @override
  String get gameDrifterDefeated => 'Дрифера здолано';

  @override
  String get gameBossDefeated => 'Боса здолано';

  @override
  String get gameBossDefeatedBody => 'Дорога до наступного світу відкрита.';

  @override
  String get gamePlayerDefeated => 'Бос оговтався';

  @override
  String get gamePlayerDefeatedBody =>
      'Він знову сповнений сил, і твоя витривалість теж. Спробуй ще раз, коли будеш готовий, — більше нічого не втрачено.';

  @override
  String get gameContinue => 'Далі';

  @override
  String get settingsAccent => 'Акцентний колір';

  @override
  String get settingsAccentSubtitle =>
      'Змінюється лише акцентний тон — решта палітри лишається тією самою.';

  @override
  String get settingsImport => 'Імпорт із JSON';

  @override
  String get settingsImportSubtitle =>
      'Відновити вивантаження на новому пристрої';

  @override
  String get settingsImportPathHint =>
      'Повний шлях до вивантаженого .json-файлу.';

  @override
  String get settingsImportNoFile => 'За цим шляхом файлу немає';

  @override
  String get settingsImportWarnTitle => 'Це зачепить твої дані';

  @override
  String get settingsImportWarnBody =>
      'Злиття залишить те, що вже є, і додасть відсутнє. Заміна спершу зітре поточну історію — скасувати буде неможливо.';

  @override
  String get settingsImportMerge => 'Злити';

  @override
  String get settingsImportReplace => 'Замінити все';

  @override
  String settingsImportDone(int habits, int tasks, int sessions) {
    return 'Імпортовано: звичок — $habits, задач — $tasks, сесій — $sessions';
  }

  @override
  String get settingsImportFailed => 'Імпорт не вдався';

  @override
  String get timerRepeat => 'Ще одну таку саму';

  @override
  String get recommendationEvidenceScopeLabel => 'Збіг контексту';

  @override
  String get recommendationEvidenceCountLabel => 'Сесій в основі';

  @override
  String get recommendationEvidenceRateLabel => 'Спрацьовувало';

  @override
  String get recommendationScopeExact => 'саме цей';

  @override
  String get recommendationScopeSimilar => 'схожа робота';

  @override
  String get recommendationScopeBroad => 'цей настрій загалом';

  @override
  String get recommendationScopeNone => 'даних поки немає';

  @override
  String get drifterTangle => 'Клубок';

  @override
  String get drifterTangleFlavor =>
      'Дві лійки, що сходяться в одній нитці. Що довше тягнеш, то тугіше сидить.';

  @override
  String get drifterMote => 'Мошва';

  @override
  String get drifterMoteFlavor =>
      'Не одна істота, а вісім дрібних по краях. Кожна окремо не важить нічого.';

  @override
  String get drifterHusk => 'Шкаралупа';

  @override
  String get drifterHuskFlavor =>
      'Замкнена оболонка, всередині порожньо. Це завдання хтось давно випатрав.';

  @override
  String get drifterSiphon => 'Лійка';

  @override
  String get drifterSiphonFlavor =>
      'Широка згори, тонкий струмочок унизу. Входить усе, виходить майже нічого.';

  @override
  String get drifterKnot => 'Вузол';

  @override
  String get drifterKnotFlavor =>
      'Стовп із двома перекладинами. Не істота — просто те, що стоїть упоперек.';

  @override
  String get drifterVeil => 'Запона';

  @override
  String get drifterVeilFlavor =>
      'Важка завіса навскіс через увесь кадр. Не ховає роботу, а приглушує.';

  @override
  String get mapWorld1Name => 'Тиха кімната';

  @override
  String get mapWorld2Name => 'Гучне поле';

  @override
  String get mapWorld3Name => 'Довга зала';

  @override
  String get characterStage5 => 'Повна корона';

  @override
  String get characterStage6 => 'Майже сонце';

  @override
  String get characterRank1 => 'Іскра';

  @override
  String get characterRank2 => 'Проблиск';

  @override
  String get characterRank3 => 'Жарина';

  @override
  String get characterRank4 => 'Рівне полум\'я';

  @override
  String get characterRank5 => 'Смолоскип';

  @override
  String get characterRank6 => 'Маяк';

  @override
  String get characterRank7 => 'Горно';

  @override
  String get characterRank8 => 'Маленьке сонце';

  @override
  String get characterStagesTitle => 'Як він росте';

  @override
  String get characterStagesBody =>
      'Вигляд змінюється сам на цих рівнях. Тут нічого не сховано — це вся драбина.';

  @override
  String characterStageAtLevel(int level) {
    return 'Рівень $level';
  }

  @override
  String get characterStageCurrent => 'Ти тут';

  @override
  String characterNextStage(int level) {
    return 'Наступна зміна на рівні $level';
  }

  @override
  String get characterFinalStage =>
      'Остання сходинка. Далі — лише більше того самого.';

  @override
  String get battleTitle => 'Сутичка';

  @override
  String get battleEnemyHp => 'Його HP';

  @override
  String get battleProgressHint =>
      'Його HP спадає разом із часом у фокусі. Доведеш сесію до кінця — шкода закріпиться.';

  @override
  String get battleVictoryTitle => 'Готовий.';

  @override
  String get battleVictoryBody =>
      'Ти відсидів сесію до кінця, і цього вистачило. Повага.';

  @override
  String get battleBossVictoryTitle => 'Дорога відкрита.';

  @override
  String get battleHeldTitle => 'Устояв.';

  @override
  String get battleHeldBody =>
      'Ти спинився раніше — він перестав отримувати шкоду. Він досі стоїть, і ти теж. Повернешся.';

  @override
  String get battleBossResetTitle => 'Він зібрався назад.';

  @override
  String get battleBossResetBody =>
      'Витривалість скінчилася, і бос знову з повним HP. Набутий досвід лишається — це твоє.';

  @override
  String battleXpLine(int xp) {
    return 'Здобуто за сесію: +$xp XP';
  }

  @override
  String get battleBossStakes =>
      'Скінчиться витривалість — він повернеться до повного HP.';

  @override
  String get battleTimerHint =>
      'Та сама сесія і той самий таймер — просто тепер у неї є обличчя.';

  @override
  String get onboardingModeTitle => 'Як працюватимемо?';

  @override
  String get onboardingModeBody =>
      'Це можна перемкнути пізніше в налаштуваннях — нічого не фіксується назавжди.';

  @override
  String get onboardingModePlain => 'Просто трекер';

  @override
  String get onboardingModePlainBody =>
      'Сесії, звички, статистика. І нічого згори.';

  @override
  String get onboardingModeGame => 'З грою';

  @override
  String get onboardingModeGameBody =>
      'Той самий трекер плюс карта, якою йдеш, супротивники, яких стирають твої сесії, і персонаж, що росте разом із ними.';

  @override
  String get photoSectionTitle => 'Фото';

  @override
  String get photoAdd => 'Додати фото';

  @override
  String get photoHint =>
      'Те, над чим справді працюєш: зошит, екран, стіл. Лишається на цьому пристрої.';

  @override
  String get photoReplace => 'Замінити';

  @override
  String get photoRemove => 'Прибрати';

  @override
  String get photoFromCamera => 'Зняти';

  @override
  String get photoFromGallery => 'Вибрати з галереї';

  @override
  String get photoSourceTitle => 'Звідки?';

  @override
  String get photoFailed => 'Не вдалося додати фото.';

  @override
  String get photoMissing => 'Файла на цьому пристрої більше немає.';

  @override
  String get photoViewerTitle => 'Фото сесії';

  @override
  String get historyTitle => 'Останні сесії';

  @override
  String get historyEmpty => 'За цей період поки порожньо.';

  @override
  String get historyDelete => 'Видалити';

  @override
  String get historyDeleteTitle => 'Видалити цю сесію?';

  @override
  String get historyDeleteBody =>
      'Вона зникне з історії й перестане враховуватись у статистиці. Прикріплене фото теж буде видалено з пристрою. Скасувати не можна.';

  @override
  String get historyDeleted => 'Сесію видалено.';

  @override
  String historyMinutes(int minutes) {
    return '$minutes хв';
  }
}
