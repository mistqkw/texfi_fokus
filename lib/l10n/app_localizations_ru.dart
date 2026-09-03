// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'TexFi f0kus';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonNext => 'Далее';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonStart => 'Начать';

  @override
  String get commonSkip => 'Пропустить';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonMinutes => 'мин';

  @override
  String commonMinutesFull(int count) {
    return '$count мин';
  }

  @override
  String get onboardingWelcomeTitle => 'TexFi f0kus';

  @override
  String get onboardingWelcomeBody =>
      'Фокус-таймер, который учится тому, как ты работаешь на самом деле, и трекер привычек, который не даёт соскочить.';

  @override
  String get onboardingMoodTitle => 'Начни с настроения';

  @override
  String get onboardingMoodBody =>
      'Перед каждой сессией переключаешь тумблер: плохое, нормальное, хорошее, full f0kus. Приложение подбирает технику и длительность под это состояние.';

  @override
  String get onboardingLearningTitle => 'Оно учится на тебе';

  @override
  String get onboardingLearningBody =>
      'Каждая завершённая или брошенная сессия показывает приложению, какая техника работает у тебя в каком настроении. Рекомендации становятся точнее.';

  @override
  String get onboardingHabitsTitle => 'Привычки с последствиями';

  @override
  String get onboardingHabitsBody =>
      'Ставишь дневную цель и сам пишешь, что себе должен, если не выполнишь. Приложение это запомнит и напомнит.';

  @override
  String get onboardingThemeTitle => 'Выбери вид';

  @override
  String get onboardingThemeBody =>
      'Пиксель-арт в темноте, тёплый и солнечный на свету.';

  @override
  String get onboardingFirstHabitTitle => 'Первая привычка';

  @override
  String get onboardingFirstHabitBody =>
      'Назови одно дело, которое хочешь делать каждый день. Остальные добавишь позже.';

  @override
  String get onboardingNotificationsTitle => 'Напоминания';

  @override
  String get onboardingNotificationsBody =>
      'Разреши TexFi f0kus напоминать о невыполненных целях в конце дня.';

  @override
  String get onboardingAllowNotifications => 'Разрешить уведомления';

  @override
  String get onboardingFinish => 'Погнали';

  @override
  String get homeTitle => 'f0kus';

  @override
  String get homeStreakLabel => 'Стрик';

  @override
  String get homeStreakBasis => 'по привычкам';

  @override
  String homeStreakValue(int days) {
    return '$days д';
  }

  @override
  String get homeTodayHabits => 'Сегодня';

  @override
  String get homeHabitsEmpty => 'Привычек пока нет. Добавь первую.';

  @override
  String get homeStartFocus => 'Начать фокус-сессию';

  @override
  String get homeFocusToday => 'Сегодня';

  @override
  String get homeFocusWeek => 'За неделю';

  @override
  String get homeSummaryTitle => 'В фокусе';

  @override
  String get homeAllDone => 'Все цели на сегодня закрыты. Уважение.';

  @override
  String homePending(int count, int total) {
    return 'Осталось целей: $count из $total';
  }

  @override
  String get insightTitle => 'Замечено';

  @override
  String insightBestMood(String mood, int percent) {
    return 'Сессии, начатые в состоянии «$mood», доходят до конца в $percent% случаев — это твоё сильное состояние.';
  }

  @override
  String insightBestWeekday(String day, int minutes) {
    return '$day — твой самый глубокий день: в среднем $minutes мин в фокусе.';
  }

  @override
  String insightBestTime(String time, int percent) {
    return '$time — время, когда ты доводишь до конца: $percent% таких сессий закрываются.';
  }

  @override
  String insightBestTechnique(String technique, int percent) {
    return '«$technique» работает у тебя лучше остального — $percent% таких сессий закрываются.';
  }

  @override
  String insightBasis(int count) {
    return 'По $count сессиям за последние 30 дней.';
  }

  @override
  String get timeOfDayMorning => 'Утро';

  @override
  String get timeOfDayAfternoon => 'День';

  @override
  String get timeOfDayEvening => 'Вечер';

  @override
  String get timeOfDayNight => 'Ночь';

  @override
  String get navHome => 'Главная';

  @override
  String get navHabits => 'Привычки';

  @override
  String get navStats => 'Статистика';

  @override
  String get navSettings => 'Настройки';

  @override
  String get moodTitle => 'Как ты сейчас?';

  @override
  String get moodBad => 'плохое';

  @override
  String get moodNeutral => 'нормальное';

  @override
  String get moodGood => 'хорошее';

  @override
  String get moodFullFokus => 'full f0kus';

  @override
  String get moodHint =>
      'Проведи пальцем или нажми. У каждого состояния своя вибрация.';

  @override
  String get moodLateNightNote =>
      'Ночи в последнее время выходят длинные. Береги себя.';

  @override
  String get moodPickTaskTitle => 'Над чем работаешь?';

  @override
  String get moodTaskHint => 'Название задачи';

  @override
  String get moodNewTask => 'Новая задача';

  @override
  String get moodCategory => 'Категория';

  @override
  String get moodDifficulty => 'Сложность';

  @override
  String get moodDifficultyEasy => 'Лёгкая';

  @override
  String get moodDifficultyMedium => 'Средняя';

  @override
  String get moodDifficultyHard => 'Тяжёлая';

  @override
  String get moodContinue => 'Дальше';

  @override
  String get moodTaskRequired => 'Введи название задачи';

  @override
  String get categoryStudy => 'Учёба';

  @override
  String get categoryWork => 'Работа';

  @override
  String get categoryCreative => 'Творчество';

  @override
  String get categoryChores => 'Дела';

  @override
  String get categorySport => 'Спорт';

  @override
  String get categoryOther => 'Другое';

  @override
  String get recommendationTitle => 'Рекомендуем';

  @override
  String get recommendationColdStart =>
      'Безопасный вариант под это настроение — приложение ещё мало знает о твоих сессиях.';

  @override
  String recommendationColdStartProgress(int count) {
    return 'Ещё $count сессий — и подсказки станут твоими.';
  }

  @override
  String get recommendationWhyTitle => 'Почему это';

  @override
  String get recommendationBadgePersonal => 'ЛИЧНОЕ';

  @override
  String get recommendationBadgeDefault => 'ДЕФОЛТ';

  @override
  String recommendationEvidenceExact(int count, int percent) {
    return 'Ровно в таком контексте ты провёл с ней $count сессий — $percent% из них удались.';
  }

  @override
  String recommendationEvidenceSimilar(int count, int percent) {
    return 'На похожем настроении и задаче ты провёл с ней $count сессий — $percent% из них удались.';
  }

  @override
  String recommendationEvidenceBroad(int count, int percent) {
    return 'На этом настроении ты провёл с ней $count сессий — $percent% из них удались.';
  }

  @override
  String get recommendationEvidenceNone =>
      'По ней истории пока нет — приложение проверяет, подходит ли она тебе.';

  @override
  String get recommendationExploring =>
      'Это осознанная проверка, а не лучший известный вариант. Чем бы ни кончилось, следующий выбор станет точнее.';

  @override
  String recommendationHistorySize(int count) {
    return 'Всего в обучении $count сессий.';
  }

  @override
  String get recommendationStart => 'Начать';

  @override
  String get recommendationManual => 'Настроить вручную';

  @override
  String get recommendationManualTitle => 'Свой таймер';

  @override
  String get recommendationFocusLength => 'Длительность фокуса';

  @override
  String get recommendationBreakLength => 'Длительность перерыва';

  @override
  String get recommendationCycles => 'Циклов';

  @override
  String get recommendationSoundOnEnd => 'Звук в конце цикла';

  @override
  String get recommendationAutoStart => 'Автостарт следующего цикла';

  @override
  String get techniqueSprint15 => 'Спринт 15';

  @override
  String get techniqueSprint15Desc =>
      '15 минут работы, 5 отдыха. Мягкий заход, когда ничего не идёт.';

  @override
  String get techniquePomodoro2505 => 'Помодоро 25/5';

  @override
  String get techniquePomodoro2505Desc =>
      'Классика. 25 минут работы, 5 отдыха, четыре цикла.';

  @override
  String get techniquePomodoro5010 => 'Помодоро 50/10';

  @override
  String get techniquePomodoro5010Desc =>
      '50 минут работы, 10 отдыха. Для задач, где нужен разгон.';

  @override
  String get techniqueDeepWork90 => 'Глубокая работа 90';

  @override
  String get techniqueDeepWork90Desc =>
      '90 минут без перерывов. Только когда ты правда в потоке.';

  @override
  String get timerFocusPhase => 'ФОКУС';

  @override
  String get timerBreakPhase => 'ПЕРЕРЫВ';

  @override
  String get timerPause => 'Пауза';

  @override
  String get timerResume => 'Продолжить';

  @override
  String get timerStop => 'Стоп';

  @override
  String get timerSkip => 'Пропустить';

  @override
  String timerCycleOf(int current, int total) {
    return 'Цикл $current из $total';
  }

  @override
  String get timerDialHint => 'Крути диск, чтобы поправить оставшееся время';

  @override
  String get timerStopConfirmTitle => 'Остановить сессию?';

  @override
  String get timerStopConfirmBody =>
      'Она запишется как прерванная — это тоже полезные данные.';

  @override
  String get timerStopConfirmYes => 'Остановить';

  @override
  String get timerDoneTitle => 'Сессия завершена';

  @override
  String get timerAbortedTitle => 'Сессия прервана';

  @override
  String get timerRateQuestion => 'Насколько продуктивно вышло?';

  @override
  String get timerRateSave => 'Сохранить';

  @override
  String get timerFullscreen => 'На весь экран';

  @override
  String get timerExitFullscreen => 'Выйти из полноэкранного';

  @override
  String get habitsTitle => 'Привычки';

  @override
  String get habitsEmpty => 'Привычек пока нет.';

  @override
  String get habitsEmptyHint =>
      'Привычка — это дневная цель плюс то, что ты себе должен, если её пропустишь.';

  @override
  String get habitsAdd => 'Новая привычка';

  @override
  String get habitEditTitle => 'Изменить привычку';

  @override
  String get habitNameLabel => 'Название';

  @override
  String get habitNameHint => 'Читать 30 минут';

  @override
  String get habitNameRequired => 'Введи название';

  @override
  String get habitFrequency => 'Частота';

  @override
  String get habitDaily => 'Каждый день';

  @override
  String get habitCustomDays => 'Выбранные дни';

  @override
  String get habitPunishmentLabel => 'Если не выполнишь';

  @override
  String get habitPunishmentHint => '50 отжиманий, завтра без кофе…';

  @override
  String get habitPunishmentRequired => 'Напиши, что ты себе должен';

  @override
  String get habitPunishmentExplainer =>
      'Ты пишешь сам, приложение просто запоминает и напоминает. Ничего не автоматизируется.';

  @override
  String get habitReminderTime => 'Время напоминания';

  @override
  String get habitReminderOff => 'Выкл';

  @override
  String get habitDeleteConfirmTitle => 'Удалить привычку?';

  @override
  String get habitDeleteConfirmBody => 'История по ней тоже удалится.';

  @override
  String habitStreakLabel(int days) {
    return 'Стрик: $days д';
  }

  @override
  String get habitDaysShort => 'Пн Вт Ср Чт Пт Сб Вс';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsWeek => 'Неделя';

  @override
  String get statsMonth => 'Месяц';

  @override
  String get statsActivity => 'Активность';

  @override
  String get statsActivityHint =>
      'Каждый квадрат — день. Чем ярче, тем больше времени в фокусе.';

  @override
  String get statsFocusByDay => 'Время в фокусе по дням';

  @override
  String get statsMoodBreakdown => 'Настроение и результат';

  @override
  String get statsMoodBreakdownHint =>
      'Как часто ты доводишь до конца сессию, начатую в каждом настроении.';

  @override
  String get statsByCategory => 'По категориям задач';

  @override
  String get statsHabitSuccess => 'Выполнение привычек';

  @override
  String get statsTotalFocus => 'Всего в фокусе';

  @override
  String get statsSessions => 'Сессий';

  @override
  String get statsCompletionRate => 'Завершено';

  @override
  String get statsEmpty => 'Данных пока мало. Проведи пару сессий.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsFeedback => 'Звук и вибрация';

  @override
  String get settingsSounds => 'Звуки';

  @override
  String get settingsVibration => 'Вибрация';

  @override
  String get settingsVibrationIntensity => 'Интенсивность вибрации';

  @override
  String get settingsAlarmSound => 'Звук окончания';

  @override
  String get settingsAlarmSoundHint =>
      'Идёт через канал будильника, поэтому слышен на беззвучном. Нажмите, чтобы прослушать.';

  @override
  String get soundArcadeCoin => 'Монетка';

  @override
  String get soundLevelUp => 'Новый уровень';

  @override
  String get soundAlarmBeep => 'Гудок будильника';

  @override
  String get soundSoftChime => 'Мягкий перезвон';

  @override
  String get soundPowerDown => 'Выключение';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'Системный';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsNotificationsEnabled => 'Напоминания о привычках';

  @override
  String get settingsDailyReminderTime => 'Итог дня в';

  @override
  String get settingsData => 'Данные';

  @override
  String get settingsExport => 'Экспорт данных в JSON';

  @override
  String settingsExportDone(String path) {
    return 'Сохранено в $path';
  }

  @override
  String get settingsExportFailed =>
      'Не получилось сохранить файл. С данными ничего не случилось — попробуйте ещё раз.';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String settingsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get settingsAboutBody =>
      'Часть экосистемы TexFi. Работает полностью офлайн — данные не покидают устройство.';

  @override
  String notificationHabitTitle(String habit) {
    return 'Цель не выполнена: $habit';
  }

  @override
  String notificationHabitBody(String punishment) {
    return 'Ты обещал себе: $punishment';
  }

  @override
  String get notificationDailyTitle => 'Конец дня';

  @override
  String notificationDailyBody(int count) {
    return 'Незакрытых целей: $count. Ещё есть время.';
  }

  @override
  String get notificationChannelHabits => 'Напоминания о привычках';

  @override
  String get notificationChannelHabitsDesc =>
      'Напоминания о невыполненных дневных целях';

  @override
  String get interruptionQuestion => 'Что выбило?';

  @override
  String get interruptionOptional =>
      'Необязательно — помогает приложению понять твои закономерности.';

  @override
  String get interruptionDistracted => 'Отвлёкся';

  @override
  String get interruptionWrongTask => 'Задача оказалась не та';

  @override
  String get interruptionTired => 'Устал';

  @override
  String get interruptionNoComment => 'Не хочу говорить';

  @override
  String get sessionNoteQuestion => 'Как прошло?';

  @override
  String get sessionNoteHint => 'Пара слов или стикер';

  @override
  String get guardShortBreakTitle => 'Сразу дальше?';

  @override
  String get guardShortBreakBody =>
      'Ты только что закончил сессию. Настоящий перерыв сделает следующую лучше.';

  @override
  String get guardBurnoutTitle => 'Три прерванных подряд';

  @override
  String get guardBurnoutBody =>
      'Возможно, стоит отдохнуть сегодня. Если не согласен — ничто не мешает начать.';

  @override
  String get guardNightCapTitle => 'Поздно';

  @override
  String get guardNightCapBody =>
      'После ночного часа предлагаем короче — независимо от настроения и рекомендации движка.';

  @override
  String get guardStartAnyway => 'Всё равно начать';

  @override
  String get guardTakeABreak => 'Не сейчас';

  @override
  String get settingsBurnout => 'Темп';

  @override
  String get settingsShortBreakWarning => 'Предупреждать о коротком перерыве';

  @override
  String settingsShortBreakSubtitle(int count) {
    return 'Предупреждать, если старт раньше чем через $count мин после прошлой сессии';
  }

  @override
  String get settingsShortBreakOff => 'Выключено';

  @override
  String get settingsNightCap => 'Ночной софт-кап';

  @override
  String get settingsNightCapSubtitle => 'Ночью не предлагать длиннее 25/5';

  @override
  String get settingsNightCapHour => 'Ночь начинается в';

  @override
  String get habitByWeekdays => 'По выбранным дням';

  @override
  String get habitTimesPerWeek => 'N раз в неделю';

  @override
  String get habitTimesPerWeekLabel => 'Раз в неделю';

  @override
  String habitTimesPerWeekValue(int count) {
    return '$count× в неделю';
  }

  @override
  String get habitRewardLabel => 'Если выдержишь';

  @override
  String get habitRewardHint => 'Долгая ванна, та самая игра, выходной';

  @override
  String get habitRewardExplainer =>
      'Необязательно и ровно так же твоя договорённость с собой, как и наказание, — приложение только запомнит и покажет, когда дойдёшь.';

  @override
  String get habitRewardStreakDays => 'Нужен стрик';

  @override
  String habitRewardAfter(int count) {
    return 'Награда за $count дней';
  }

  @override
  String habitRewardEarned(int count) {
    return 'Заслужено — $count дней подряд';
  }

  @override
  String habitStreakWeeks(int count) {
    return '$count недель подряд';
  }

  @override
  String habitWeekProgress(int done, int target) {
    return '$done из $target на неделе';
  }

  @override
  String get habitFreezeAllow => 'Разрешить заморозку стрика';

  @override
  String habitFreezeAllowSubtitle(int days) {
    return 'Один пропуск раз в $days дней сохраняет стрик';
  }

  @override
  String get habitFreezeToday => 'Заморозить';

  @override
  String get habitFreezeUndo => 'Разморозить';

  @override
  String get habitFreezeHint => 'Пропустить сегодня, не теряя стрик';

  @override
  String get habitFreezeUndoHint => 'Сегодня заморожено — стрик держится';

  @override
  String get habitFreezeUnavailable => 'Заморозка пока недоступна';

  @override
  String get habitFrozenToday => 'Заморожено';

  @override
  String get statsPunishment => 'Когда наказание сработало';

  @override
  String statsPunishmentCount(int missed, int scheduled) {
    return '$missed из $scheduled дней пропущено';
  }

  @override
  String get statsPunishmentEmpty => 'За период ничего не пропущено.';

  @override
  String get statsInterruptions => 'Почему сессии обрывались';

  @override
  String get statsInterruptionsEmpty => 'За период прерванных сессий не было.';

  @override
  String get statsInterruptionUnnamed => 'Причина не названа';

  @override
  String get homePlanDay => 'Спланировать день';

  @override
  String get planTitle => 'План на сегодня';

  @override
  String get planIntro =>
      'Две-три задачи, примерно по порядку. Необязательно — просто чтобы не придумывать задачу в момент, когда уже сел работать.';

  @override
  String get planAddHint => 'Чем займёшься сегодня?';

  @override
  String get planEnough => 'Трёх на день обычно достаточно.';

  @override
  String get planToday => 'В плане';

  @override
  String get planEmpty => 'Пока ничего не запланировано.';

  @override
  String get planFromTasks => 'Из твоих задач';

  @override
  String get planDone => 'Отметить';

  @override
  String get planUndone => 'Снять отметку';

  @override
  String get planSubtasks => 'Чеклист';

  @override
  String get planSubtaskHint => 'Один шаг';

  @override
  String planSubtaskCount(int done, int total) {
    return '$done из $total шагов';
  }

  @override
  String get planSubtasksEmpty =>
      'Шагов пока нет — в сессии они показываются чеклистом.';

  @override
  String planSubtasksFull(int count) {
    return '$count шагов — предел для одной сессии.';
  }

  @override
  String get moodFromPlan => 'Из плана на сегодня';

  @override
  String notificationDailyProductive(int sessions, int minutes, String mood) {
    return 'Сегодня: $sessions сессии, $minutes мин в фокусе, чаще всего — $mood.';
  }

  @override
  String get notificationDailyAllDone => 'Сегодня всё закрыто. Хорошо.';

  @override
  String get notificationChannelTimer => 'Таймер';

  @override
  String get notificationChannelTimerDesc =>
      'Конец отрезка фокуса, перерыва или всей сессии';

  @override
  String get notificationTimerFocusDoneTitle => 'Отрезок фокуса закончен';

  @override
  String notificationTimerFocusDoneBody(int cycle, int total) {
    return 'Цикл $cycle из $total позади. Пора на перерыв.';
  }

  @override
  String get notificationTimerBreakDoneTitle => 'Перерыв закончился';

  @override
  String get notificationTimerBreakDoneBody =>
      'Возвращайся в фокус, когда будешь готов.';

  @override
  String get notificationTimerSessionDoneTitle => 'Сессия завершена';

  @override
  String notificationTimerSessionDoneBody(int minutes) {
    return '$minutes мин фокуса по плану. Хорошо продержался.';
  }

  @override
  String get navMap => 'Карта';

  @override
  String get gameSectionTitle => 'Игровой режим';

  @override
  String get gameModeToggle => 'Играть, а не только отмечать';

  @override
  String get gameModeSubtitle =>
      'Сессии и привычки остаются ровно такими же — поверх них появляются карта, дриферы и уровни.';

  @override
  String get gameModeOffNote =>
      'Выключение только прячет игру. Уровень и прогресс по карте сохраняются, и ты вернёшься на то же место.';

  @override
  String get gameReset => 'Начать игру заново';

  @override
  String get gameResetSubtitle =>
      'Обнуляет опыт и карту. Сессий и привычек не касается.';

  @override
  String get gameResetConfirm =>
      'Начать заново? Уровень и карта обнулятся. Сессии, привычки и статистика останутся нетронутыми.';

  @override
  String get gameResetDone => 'Карта начинается сначала.';

  @override
  String get mapTitle => 'Карта';

  @override
  String mapWorld(int world) {
    return 'Мир $world';
  }

  @override
  String get mapAllCleared =>
      'Все миры пройдены. Опыт за сессии продолжает капать.';

  @override
  String get mapNodeLocked => 'Закрыт';

  @override
  String get mapNodeCleared => 'Пройден';

  @override
  String get mapNodeCurrent => 'Ты здесь';

  @override
  String get mapBossNode => 'Босс';

  @override
  String get characterTitle => 'Персонаж';

  @override
  String characterLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String characterXp(int current, int needed) {
    return '$current / $needed XP';
  }

  @override
  String characterToNextLevel(int xp) {
    return '$xp XP до следующего уровня';
  }

  @override
  String get characterDriftersDefeated => 'Дриферов побеждено';

  @override
  String get characterBossesDefeated => 'Боссов побеждено';

  @override
  String get characterTotalXp => 'Опыта заработано';

  @override
  String get characterStage1 => 'Только ядро';

  @override
  String get characterStage2 => 'Огонёк обрёл форму';

  @override
  String get characterStage3 => 'Ореол из искр';

  @override
  String get characterStage4 => 'Корона';

  @override
  String get drifterBuzz => 'Гудок';

  @override
  String get drifterCreep => 'Ползун';

  @override
  String get drifterLoom => 'Морок';

  @override
  String get drifterBuzzFlavor =>
      'Размах крыльев больше тела. Звякнет один раз — и внимания нет.';

  @override
  String get drifterCreepFlavor =>
      'Низкий и многоногий. Не налетает, а подбирается снизу.';

  @override
  String get drifterLoomFlavor =>
      'Высокий, узкий, с одним пустым глазом. Просто стоит и смотрит.';

  @override
  String get bossScroll => 'Лента';

  @override
  String get bossChorus => 'Хор';

  @override
  String get bossHollow => 'Пустота';

  @override
  String get bossScrollFlavor =>
      'Лента, свернувшаяся в саму себя. У неё нет конца — в этом весь фокус.';

  @override
  String get bossChorusFlavor =>
      'Не одно существо, а гроздь голов, и говорят они разом.';

  @override
  String get bossHollowFlavor => 'Тяжёлая рама вокруг ничего. Тянет внутрь.';

  @override
  String get encounterTitle => 'Против тебя';

  @override
  String encounterHp(int current, int max) {
    return '$current / $max HP';
  }

  @override
  String get encounterWounded => 'Ранен — доверши.';

  @override
  String get encounterHealed => 'Пока тебя не было, он успел восстановиться.';

  @override
  String get encounterBossHint =>
      'По-настоящему его пробивают только сессии, начатые в full f0kus.';

  @override
  String encounterBossStamina(int current, int total) {
    return 'Твоя выносливость: $current из $total';
  }

  @override
  String get encounterBossStaminaHint =>
      'Каждый брошенный f0kus-заход стоит одного очка.';

  @override
  String get encounterFokusMissing =>
      'Выбери full f0kus на чекине, чтобы драться в полную силу.';

  @override
  String gameXpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String gameLevelUp(int level) {
    return 'Уровень $level';
  }

  @override
  String get gameLevelUpBody => 'Твой огонёк изменился.';

  @override
  String get gameDrifterDefeated => 'Дрифер побеждён';

  @override
  String get gameBossDefeated => 'Босс побеждён';

  @override
  String get gameBossDefeatedBody => 'Дорога в следующий мир открыта.';

  @override
  String get gamePlayerDefeated => 'Дрифер-босс пришёл в себя';

  @override
  String get gamePlayerDefeatedBody =>
      'Он снова полон сил, и твоя выносливость тоже. Попробуй снова, когда будешь готов, — больше ничего не потеряно.';

  @override
  String get gameContinue => 'Дальше';

  @override
  String get settingsAccent => 'Акцентный цвет';

  @override
  String get settingsAccentSubtitle =>
      'Меняется только акцентный тон — остальная палитра остаётся прежней.';

  @override
  String get settingsImport => 'Импорт из JSON';

  @override
  String get settingsImportSubtitle =>
      'Восстановить выгрузку на новом устройстве';

  @override
  String get settingsImportPathHint =>
      'Полный путь к выгруженному .json-файлу.';

  @override
  String get settingsImportNoFile => 'По этому пути файла нет';

  @override
  String get settingsImportWarnTitle => 'Это затронет твои данные';

  @override
  String get settingsImportWarnBody =>
      'Слияние оставит то, что уже есть, и добавит недостающее. Замена сначала сотрёт текущую историю — отменить будет нельзя.';

  @override
  String get settingsImportMerge => 'Слить';

  @override
  String get settingsImportReplace => 'Заменить всё';

  @override
  String settingsImportDone(int habits, int tasks, int sessions) {
    return 'Импортировано: привычек — $habits, задач — $tasks, сессий — $sessions';
  }

  @override
  String get settingsImportFailed =>
      'Не получилось прочитать файл. Ничего не изменилось — проверьте, что это выгрузка из этого приложения.';

  @override
  String get timerRepeat => 'Ещё одну такую же';

  @override
  String get recommendationEvidenceScopeLabel => 'Совпадение контекста';

  @override
  String get recommendationEvidenceCountLabel => 'Сессий в основе';

  @override
  String get recommendationEvidenceRateLabel => 'Срабатывало';

  @override
  String get recommendationScopeExact => 'ровно этот';

  @override
  String get recommendationScopeSimilar => 'похожая работа';

  @override
  String get recommendationScopeBroad => 'это настроение вообще';

  @override
  String get recommendationScopeNone => 'данных пока нет';

  @override
  String get drifterTangle => 'Клубок';

  @override
  String get drifterTangleFlavor =>
      'Две воронки, сходящиеся в одной нити. Чем дольше тянешь, тем туже сидит.';

  @override
  String get drifterMote => 'Мошкара';

  @override
  String get drifterMoteFlavor =>
      'Не одно существо, а восемь мелких по краям. Каждое по отдельности не весит ничего.';

  @override
  String get drifterHusk => 'Скорлупа';

  @override
  String get drifterHuskFlavor =>
      'Замкнутая оболочка, внутри пусто. Эту задачу кто-то давно выпотрошил.';

  @override
  String get drifterSiphon => 'Воронка';

  @override
  String get drifterSiphonFlavor =>
      'Широкая сверху, тонкая струйка снизу. Входит всё, выходит почти ничего.';

  @override
  String get drifterKnot => 'Узел';

  @override
  String get drifterKnotFlavor =>
      'Столб с двумя перекладинами. Не существо — просто то, что стоит поперёк.';

  @override
  String get drifterVeil => 'Полог';

  @override
  String get drifterVeilFlavor =>
      'Тяжёлая занавесь наискось через весь кадр. Не прячет работу, а приглушает.';

  @override
  String get mapWorld1Name => 'Тихая комната';

  @override
  String get mapWorld2Name => 'Громкое поле';

  @override
  String get mapWorld3Name => 'Длинный зал';

  @override
  String get characterStage5 => 'Полная корона';

  @override
  String get characterStage6 => 'Почти солнце';

  @override
  String get characterRank1 => 'Искра';

  @override
  String get characterRank2 => 'Проблеск';

  @override
  String get characterRank3 => 'Уголёк';

  @override
  String get characterRank4 => 'Ровное пламя';

  @override
  String get characterRank5 => 'Факел';

  @override
  String get characterRank6 => 'Маяк';

  @override
  String get characterRank7 => 'Горн';

  @override
  String get characterRank8 => 'Маленькое солнце';

  @override
  String get characterStagesTitle => 'Как он растёт';

  @override
  String get characterStagesBody =>
      'Вид меняется сам на этих уровнях. Здесь ничего не спрятано — это вся лестница целиком.';

  @override
  String characterStageAtLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String get characterStageCurrent => 'Ты здесь';

  @override
  String characterNextStage(int level) {
    return 'Следующее изменение на уровне $level';
  }

  @override
  String get characterFinalStage =>
      'Последняя ступень. Дальше — только больше того же.';

  @override
  String get battleTitle => 'Столкновение';

  @override
  String get battleEnemyHp => 'Его HP';

  @override
  String get battleProgressHint =>
      'Его HP убывает вместе с временем в фокусе. Доведёшь сессию до конца — урон закрепится.';

  @override
  String get battleVictoryTitle => 'Готов.';

  @override
  String get battleVictoryBody =>
      'Ты отсидел сессию до конца, и этого хватило. Уважение.';

  @override
  String get battleBossVictoryTitle => 'Дорога открыта.';

  @override
  String get battleHeldTitle => 'Устоял.';

  @override
  String get battleHeldBody =>
      'Ты остановился раньше — он перестал получать урон. Он всё ещё стоит, и ты тоже. Вернёшься.';

  @override
  String get battleBossResetTitle => 'Он собрался обратно.';

  @override
  String get battleBossResetBody =>
      'Выносливость кончилась, и босс снова с полным HP. Набранный опыт остаётся — это твоё.';

  @override
  String battleXpLine(int xp) {
    return 'Заработано за сессию: +$xp XP';
  }

  @override
  String get battleBossStakes =>
      'Кончится выносливость — он вернётся к полному HP.';

  @override
  String get battleTimerHint =>
      'Та же сессия и тот же таймер — просто теперь у неё есть лицо.';

  @override
  String get onboardingModeTitle => 'Как будем работать?';

  @override
  String get onboardingModeBody =>
      'Это можно переключить позже в настройках — ничего не фиксируется навсегда.';

  @override
  String get onboardingModePlain => 'Просто трекер';

  @override
  String get onboardingModePlainBody =>
      'Сессии, привычки, статистика. И ничего сверху.';

  @override
  String get onboardingModeGame => 'С игрой';

  @override
  String get onboardingModeGameBody =>
      'Тот же трекер плюс карта, по которой идёшь, противники, которых стачивают твои сессии, и персонаж, растущий вместе с ними.';

  @override
  String get photoSectionTitle => 'Фото';

  @override
  String get photoAdd => 'Добавить фото';

  @override
  String get photoHint =>
      'То, над чем реально работаешь: тетрадь, экран, стол. Остаётся на этом устройстве.';

  @override
  String get photoReplace => 'Заменить';

  @override
  String get photoRemove => 'Убрать';

  @override
  String get photoFromCamera => 'Снять';

  @override
  String get photoFromGallery => 'Выбрать из галереи';

  @override
  String get photoSourceTitle => 'Откуда?';

  @override
  String get photoFailed => 'Не получилось приложить фото.';

  @override
  String get photoMissing => 'Файла на этом устройстве больше нет.';

  @override
  String get photoViewerTitle => 'Фото сессии';

  @override
  String get historyTitle => 'Последние сессии';

  @override
  String get historyEmpty => 'За этот период пока пусто.';

  @override
  String get historyDelete => 'Удалить';

  @override
  String get historyDeleteTitle => 'Удалить эту сессию?';

  @override
  String get historyDeleteBody =>
      'Она уйдёт из истории и перестанет учитываться в статистике. Прикреплённое фото тоже будет удалено с устройства. Отменить нельзя.';

  @override
  String get historyDeleted => 'Сессия удалена.';

  @override
  String historyMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get updateSectionTitle => 'Обновления';

  @override
  String get updateCheckButton => 'Проверить обновления';

  @override
  String get updateChecking => 'Проверяем…';

  @override
  String get updateUpToDate => 'Установлена последняя версия.';

  @override
  String updateAvailable(String version) {
    return 'Доступно обновление v$version';
  }

  @override
  String get updateDownloadButton => 'Скачать и установить';

  @override
  String updateDownloading(int percent) {
    return 'Скачиваем… $percent%';
  }

  @override
  String get updateInstallExplainerTitle => 'Сейчас начнётся установка';

  @override
  String get updateInstallExplainerBody =>
      'Android спросит разрешение на установку из этого источника — это нормально для приложений не из Google Play: f0kus раздаётся как .apk через GitHub.';

  @override
  String get updateInstallExplainerOk => 'Понятно';

  @override
  String get updateFailed => 'Не удалось скачать обновление. Попробуйте позже.';

  @override
  String get updateNoApk => 'У этого релиза пока нет пакета для установки.';

  @override
  String get timerQuietMode => 'Тихий режим';

  @override
  String get timerQuietModeHint => 'Коснитесь экрана, чтобы вернуться';

  @override
  String get mapWorldIntroLabel => 'Новый мир';

  @override
  String get mapWorld1Epigraph =>
      'Здесь ничего не шумит. В этом вся сложность.';

  @override
  String get mapWorld2Epigraph =>
      'Здесь всё просит очереди. И ничего из этого — не твоё.';

  @override
  String get mapWorld3Epigraph => 'Дальнего конца не видно. Всё равно идёшь.';

  @override
  String get techniqueCustomDesc =>
      'Твой собственный пресет. Участвует в рекомендациях наравне со встроенными и копит свою статистику.';

  @override
  String get settingsPresetsTitle => 'Мои пресеты';

  @override
  String get settingsPresetsHint =>
      'Четыре встроенные техники подходят не всем. Заведённый здесь пресет движок предлагает наравне со встроенными.';

  @override
  String get settingsPresetsEmpty =>
      'Пресетов пока нет. Заведи свой, если ни один из четырёх встроенных ритмов не твой.';

  @override
  String get settingsPresetAdd => 'Добавить пресет';

  @override
  String get settingsPresetEdit => 'Изменить пресет';

  @override
  String get settingsPresetName => 'Название';

  @override
  String get settingsPresetNameHint => 'Например: 35/7';

  @override
  String get settingsPresetLimitReached =>
      'Не больше пяти пресетов. Каждый — ещё один вариант, который движку надо выучить, а сессии у них общие.';

  @override
  String get settingsPresetDelete => 'Удалить пресет';

  @override
  String get settingsBurnoutStreakTitle => 'Прерванных сессий подряд';

  @override
  String get settingsBurnoutStreakHint =>
      'После стольких прерванных сессий подряд приложение предложит остановиться. Две — неудачный час, пять — целый упрямый день.';

  @override
  String get settingsWeekStartTitle => 'Неделя начинается с';

  @override
  String get settingsWeekStartHint =>
      'Влияет на календарь активности и на всё, что считается по неделям.';

  @override
  String get settingsWeekStartMonday => 'Понедельника';

  @override
  String get settingsWeekStartSunday => 'Воскресенья';

  @override
  String get settingsAutoBackupTitle => 'Копия раз в неделю';

  @override
  String get settingsAutoBackupHint =>
      'Раз в неделю молча сохранять копию всего в папку backups приложения. Без облака — файл остаётся на этом устройстве.';

  @override
  String get settingsAutoBackupNever => 'Копия ещё не делалась';

  @override
  String get statsSummaryEmpty =>
      'За этот период сессий не было. Числа ниже останутся нулями до первой.';

  @override
  String get statsActivityEmpty =>
      'Календарь заполняется по ходу дела: квадрат — день, чем ярче, тем больше времени в фокусе.';

  @override
  String get statsHabitsEmpty =>
      'В этом периоде привычек не запланировано — считать пока нечего.';

  @override
  String get characterStatsEmptyNew =>
      'Здесь пока пусто. Числа сдвинутся после первой доведённой до конца сессии.';

  @override
  String get characterStatsNoWins =>
      'Сессии идут, но ни одна ещё не доведена до конца — победой считается только досиженная сессия.';

  @override
  String get mapIntroTitle => 'Куда это ведёт';

  @override
  String get mapIntroBody =>
      'Каждая доведённая до конца сессия — шаг по тропе. Миры открываются один за другим; здесь нечего покупать и не о чем гадать.';

  @override
  String get mapPreparing => 'Раскладываем тропу…';

  @override
  String get commonLoadError =>
      'Не удалось загрузить. Попробуй ещё раз — данные лежат на устройстве, ничего не потеряно.';

  @override
  String get homeHabitsEmptyHint =>
      'Привычка — это дневная цель плюс то, что ты себе должен, если её пропустишь.';

  @override
  String get planEmptyHint =>
      'План — это короткий список на сегодня, а не на всю неделю: три строки уже план.';

  @override
  String get commonUndo => 'Отменить';

  @override
  String get habitUndone => 'Привычка отмечена';

  @override
  String get habitsSearchHint => 'Найти привычку';

  @override
  String get habitsSearchNothing => 'Ни одна привычка не подходит.';

  @override
  String settingsBurnoutStreakValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сессий',
      few: '$count сессии',
      one: '$count сессия',
    );
    return '$_temp0';
  }

  @override
  String mapWorldAffinity(String category) {
    return 'Тяготеет к: $category';
  }

  @override
  String get mapWorldAffinityHint =>
      'Сессии этой категории оставляют здесь чуть больше. Всё остальное работает ровно так же.';

  @override
  String encounterMemoryNoticed(int count) {
    return 'Заходов сюда, оборвавшихся на полпути: $count. Он всё ещё стоит.';
  }

  @override
  String encounterMemoryDeep(int count) {
    return 'Уже $count. С этой задачей что-то не то, чем она записана в плане.';
  }

  @override
  String resultResonance(String category) {
    return 'Этот мир тяготеет к: $category — небольшая надбавка.';
  }

  @override
  String get loreTitle => 'Обрывки';

  @override
  String get loreBody =>
      'У каждого мира что-то написано на обороте. Находится, когда того, кто стоял в конце, больше нет.';

  @override
  String get loreEmpty => 'Пока ничего. Первый обрывок — за первым боссом.';

  @override
  String get loreLocked => 'Ещё не найден';

  @override
  String loreScrap(int number) {
    return 'Обрывок $number';
  }

  @override
  String get loreFragment1 =>
      'На полу тихой комнаты: «Оставил дверь открытой на минуту. Вернулся — минуты нет».';

  @override
  String get loreFragment2 =>
      'Тот же почерк, уже в поле: «Они не приходят снаружи. Они — то, что я положил и не поднял».';

  @override
  String get loreFragment3 =>
      'В дальнем конце зала: «Зал — это та же комната. Я иду по ней с тех пор, как сел».';

  @override
  String get loreFragment4 =>
      'Последний обрывок, вообще без почерка: «Сейчас тихо. Тихо не останется. Это нормально — дорогу назад ты знаешь».';
}
