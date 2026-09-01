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
  String get settingsExportFailed => 'Не удалось экспортировать';

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
}
