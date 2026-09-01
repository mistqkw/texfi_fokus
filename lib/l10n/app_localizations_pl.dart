// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'TexFi f0kus';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get commonDelete => 'Usuń';

  @override
  String get commonEdit => 'Edytuj';

  @override
  String get commonNext => 'Dalej';

  @override
  String get commonBack => 'Wstecz';

  @override
  String get commonDone => 'Gotowe';

  @override
  String get commonStart => 'Zacznij';

  @override
  String get commonSkip => 'Pomiń';

  @override
  String get commonAdd => 'Dodaj';

  @override
  String get commonClose => 'Zamknij';

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
      'Timer skupienia, który uczy się tego, jak naprawdę pracujesz, i tracker nawyków, który nie pozwoli ci odpuścić.';

  @override
  String get onboardingMoodTitle => 'Zacznij od nastroju';

  @override
  String get onboardingMoodBody =>
      'Przed każdą sesją przełączasz suwak: złe, normalne, dobre, full f0kus. Aplikacja dobiera technikę i długość do tego stanu.';

  @override
  String get onboardingLearningTitle => 'Uczy się od ciebie';

  @override
  String get onboardingLearningBody =>
      'Każda ukończona lub porzucona sesja pokazuje aplikacji, która technika działa u ciebie przy jakim nastroju. Rekomendacje stają się trafniejsze.';

  @override
  String get onboardingHabitsTitle => 'Nawyki z konsekwencjami';

  @override
  String get onboardingHabitsBody =>
      'Ustawiasz dzienny cel i sam wpisujesz, co jesteś sobie winien, jeśli go nie zrobisz. Aplikacja to zapamięta i przypomni.';

  @override
  String get onboardingThemeTitle => 'Wybierz wygląd';

  @override
  String get onboardingThemeBody =>
      'Pixel art w ciemności, ciepło i słonecznie w jasności.';

  @override
  String get onboardingFirstHabitTitle => 'Pierwszy nawyk';

  @override
  String get onboardingFirstHabitBody =>
      'Nazwij jedną rzecz, którą chcesz robić codziennie. Resztę dodasz później.';

  @override
  String get onboardingNotificationsTitle => 'Przypomnienia';

  @override
  String get onboardingNotificationsBody =>
      'Pozwól TexFi f0kus przypominać o niezrobionych celach pod koniec dnia.';

  @override
  String get onboardingAllowNotifications => 'Zezwól na powiadomienia';

  @override
  String get onboardingFinish => 'Jedziemy';

  @override
  String get homeTitle => 'f0kus';

  @override
  String get homeStreakLabel => 'Seria';

  @override
  String get homeStreakBasis => 'wg nawyków';

  @override
  String homeStreakValue(int days) {
    return '$days d';
  }

  @override
  String get homeTodayHabits => 'Dzisiaj';

  @override
  String get homeHabitsEmpty => 'Brak nawyków. Dodaj pierwszy.';

  @override
  String get homeStartFocus => 'Zacznij sesję skupienia';

  @override
  String get homeFocusToday => 'Dzisiaj';

  @override
  String get homeFocusWeek => 'W tym tygodniu';

  @override
  String get homeSummaryTitle => 'W skupieniu';

  @override
  String get homeAllDone => 'Wszystkie cele na dziś zrobione. Szacunek.';

  @override
  String homePending(int count, int total) {
    return 'Pozostało celów: $count z $total';
  }

  @override
  String get insightTitle => 'Zauważone';

  @override
  String insightBestMood(String mood, int percent) {
    return 'Sesje zaczęte w nastroju „$mood” kończysz w $percent% przypadków — to twój najmocniejszy stan.';
  }

  @override
  String insightBestWeekday(String day, int minutes) {
    return '$day to twój najgłębszy dzień — średnio $minutes min w skupieniu.';
  }

  @override
  String insightBestTime(String time, int percent) {
    return '$time to pora, w której dowozisz: $percent% takich sesji domykasz.';
  }

  @override
  String insightBestTechnique(String technique, int percent) {
    return '„$technique” działa u ciebie najlepiej — $percent% takich sesji domykasz.';
  }

  @override
  String insightBasis(int count) {
    return 'Na podstawie $count sesji z ostatnich 30 dni.';
  }

  @override
  String get timeOfDayMorning => 'Rano';

  @override
  String get timeOfDayAfternoon => 'Popołudnie';

  @override
  String get timeOfDayEvening => 'Wieczór';

  @override
  String get timeOfDayNight => 'Noc';

  @override
  String get navHome => 'Główna';

  @override
  String get navHabits => 'Nawyki';

  @override
  String get navStats => 'Statystyki';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get moodTitle => 'Jak się teraz czujesz?';

  @override
  String get moodBad => 'źle';

  @override
  String get moodNeutral => 'normalnie';

  @override
  String get moodGood => 'dobrze';

  @override
  String get moodFullFokus => 'full f0kus';

  @override
  String get moodHint => 'Przesuń albo dotknij. Każdy stan ma własną wibrację.';

  @override
  String get moodPickTaskTitle => 'Nad czym pracujesz?';

  @override
  String get moodTaskHint => 'Nazwa zadania';

  @override
  String get moodNewTask => 'Nowe zadanie';

  @override
  String get moodCategory => 'Kategoria';

  @override
  String get moodDifficulty => 'Trudność';

  @override
  String get moodDifficultyEasy => 'Łatwe';

  @override
  String get moodDifficultyMedium => 'Średnie';

  @override
  String get moodDifficultyHard => 'Trudne';

  @override
  String get moodContinue => 'Dalej';

  @override
  String get moodTaskRequired => 'Wpisz nazwę zadania';

  @override
  String get categoryStudy => 'Nauka';

  @override
  String get categoryWork => 'Praca';

  @override
  String get categoryCreative => 'Twórczość';

  @override
  String get categoryChores => 'Obowiązki';

  @override
  String get categorySport => 'Sport';

  @override
  String get categoryOther => 'Inne';

  @override
  String get recommendationTitle => 'Polecane dla ciebie';

  @override
  String get recommendationColdStart =>
      'Bezpieczny wybór na ten nastrój — aplikacja zna jeszcze za mało twoich sesji.';

  @override
  String recommendationColdStartProgress(int count) {
    return 'Jeszcze $count sesji i podpowiedzi staną się twoje.';
  }

  @override
  String get recommendationWhyTitle => 'Dlaczego to';

  @override
  String get recommendationBadgePersonal => 'OSOBISTE';

  @override
  String get recommendationBadgeDefault => 'DOMYŚLNE';

  @override
  String recommendationEvidenceExact(int count, int percent) {
    return 'Dokładnie w takim układzie zrobiłeś z nią $count sesji — $percent% się udało.';
  }

  @override
  String recommendationEvidenceSimilar(int count, int percent) {
    return 'Przy podobnym nastroju i zadaniu zrobiłeś z nią $count sesji — $percent% się udało.';
  }

  @override
  String recommendationEvidenceBroad(int count, int percent) {
    return 'Przy tym nastroju zrobiłeś z nią $count sesji — $percent% się udało.';
  }

  @override
  String get recommendationEvidenceNone =>
      'Nie ma jeszcze historii tej techniki — aplikacja sprawdza, czy do ciebie pasuje.';

  @override
  String get recommendationExploring =>
      'To świadomy test, a nie najlepsza znana opcja. Jakkolwiek pójdzie, kolejny wybór będzie trafniejszy.';

  @override
  String recommendationHistorySize(int count) {
    return 'Łącznie w nauce $count sesji.';
  }

  @override
  String get recommendationStart => 'Zacznij';

  @override
  String get recommendationManual => 'Ustaw ręcznie';

  @override
  String get recommendationManualTitle => 'Własny timer';

  @override
  String get recommendationFocusLength => 'Długość skupienia';

  @override
  String get recommendationBreakLength => 'Długość przerwy';

  @override
  String get recommendationCycles => 'Cykle';

  @override
  String get recommendationSoundOnEnd => 'Dźwięk na koniec cyklu';

  @override
  String get recommendationAutoStart => 'Automatyczny start kolejnego cyklu';

  @override
  String get techniqueSprint15 => 'Sprint 15';

  @override
  String get techniqueSprint15Desc =>
      '15 minut pracy, 5 przerwy. Łagodne wejście, gdy nic nie idzie.';

  @override
  String get techniquePomodoro2505 => 'Pomodoro 25/5';

  @override
  String get techniquePomodoro2505Desc =>
      'Klasyka. 25 minut pracy, 5 przerwy, cztery cykle.';

  @override
  String get techniquePomodoro5010 => 'Pomodoro 50/10';

  @override
  String get techniquePomodoro5010Desc =>
      '50 minut pracy, 10 przerwy. Do zadań, które potrzebują rozpędu.';

  @override
  String get techniqueDeepWork90 => 'Deep work 90';

  @override
  String get techniqueDeepWork90Desc =>
      '90 minut bez przerw. Tylko gdy naprawdę jesteś w formie.';

  @override
  String get timerFocusPhase => 'SKUPIENIE';

  @override
  String get timerBreakPhase => 'PRZERWA';

  @override
  String get timerPause => 'Pauza';

  @override
  String get timerResume => 'Wznów';

  @override
  String get timerStop => 'Stop';

  @override
  String get timerSkip => 'Pomiń';

  @override
  String timerCycleOf(int current, int total) {
    return 'Cykl $current z $total';
  }

  @override
  String get timerDialHint => 'Kręć tarczą, żeby poprawić pozostały czas';

  @override
  String get timerStopConfirmTitle => 'Zatrzymać sesję?';

  @override
  String get timerStopConfirmBody =>
      'Zostanie zapisana jako przerwana — to też przydatne dane.';

  @override
  String get timerStopConfirmYes => 'Zatrzymaj';

  @override
  String get timerDoneTitle => 'Sesja zakończona';

  @override
  String get timerAbortedTitle => 'Sesja przerwana';

  @override
  String get timerRateQuestion => 'Jak produktywnie wyszło?';

  @override
  String get timerRateSave => 'Zapisz';

  @override
  String get timerFullscreen => 'Pełny ekran';

  @override
  String get timerExitFullscreen => 'Wyjdź z pełnego ekranu';

  @override
  String get habitsTitle => 'Nawyki';

  @override
  String get habitsEmpty => 'Brak nawyków.';

  @override
  String get habitsEmptyHint =>
      'Nawyk to dzienny cel plus to, co jesteś sobie winien, jeśli go pominiesz.';

  @override
  String get habitsAdd => 'Nowy nawyk';

  @override
  String get habitEditTitle => 'Edytuj nawyk';

  @override
  String get habitNameLabel => 'Nazwa';

  @override
  String get habitNameHint => 'Czytać 30 minut';

  @override
  String get habitNameRequired => 'Wpisz nazwę';

  @override
  String get habitFrequency => 'Częstotliwość';

  @override
  String get habitDaily => 'Codziennie';

  @override
  String get habitCustomDays => 'Wybrane dni';

  @override
  String get habitPunishmentLabel => 'Jeśli nie zrobisz';

  @override
  String get habitPunishmentHint => '50 pompek, jutro bez kawy…';

  @override
  String get habitPunishmentRequired => 'Napisz, co jesteś sobie winien';

  @override
  String get habitPunishmentExplainer =>
      'Ty to wpisujesz, aplikacja tylko zapamiętuje i przypomina. Nic nie jest automatyzowane.';

  @override
  String get habitReminderTime => 'Godzina przypomnienia';

  @override
  String get habitReminderOff => 'Wył.';

  @override
  String get habitDeleteConfirmTitle => 'Usunąć nawyk?';

  @override
  String get habitDeleteConfirmBody => 'Jego historia też zostanie usunięta.';

  @override
  String habitStreakLabel(int days) {
    return 'Seria: $days d';
  }

  @override
  String get habitDaysShort => 'Pon Wt Śr Czw Pt Sob Nd';

  @override
  String get statsTitle => 'Statystyki';

  @override
  String get statsWeek => 'Tydzień';

  @override
  String get statsMonth => 'Miesiąc';

  @override
  String get statsActivity => 'Aktywność';

  @override
  String get statsActivityHint =>
      'Każdy kwadrat to dzień. Im jaśniejszy, tym więcej czasu w skupieniu.';

  @override
  String get statsFocusByDay => 'Czas skupienia dzień po dniu';

  @override
  String get statsMoodBreakdown => 'Nastrój a wynik';

  @override
  String get statsMoodBreakdownHint =>
      'Jak często kończysz sesję zaczętą w danym nastroju.';

  @override
  String get statsByCategory => 'Według kategorii zadań';

  @override
  String get statsHabitSuccess => 'Realizacja nawyków';

  @override
  String get statsTotalFocus => 'Łącznie w skupieniu';

  @override
  String get statsSessions => 'Sesje';

  @override
  String get statsCompletionRate => 'Ukończone';

  @override
  String get statsEmpty => 'Za mało danych. Zrób kilka sesji.';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsAppearance => 'Wygląd';

  @override
  String get settingsTheme => 'Motyw';

  @override
  String get settingsThemeSystem => 'Systemowy';

  @override
  String get settingsThemeLight => 'Jasny';

  @override
  String get settingsThemeDark => 'Ciemny';

  @override
  String get settingsFeedback => 'Dźwięk i wibracja';

  @override
  String get settingsSounds => 'Dźwięki';

  @override
  String get settingsVibration => 'Wibracja';

  @override
  String get settingsVibrationIntensity => 'Siła wibracji';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsLanguageSystem => 'Systemowy';

  @override
  String get settingsNotifications => 'Powiadomienia';

  @override
  String get settingsNotificationsEnabled => 'Przypomnienia o nawykach';

  @override
  String get settingsDailyReminderTime => 'Podsumowanie dnia o';

  @override
  String get settingsData => 'Dane';

  @override
  String get settingsExport => 'Eksport danych do JSON';

  @override
  String settingsExportDone(String path) {
    return 'Zapisano w $path';
  }

  @override
  String get settingsExportFailed => 'Eksport nie powiódł się';

  @override
  String get settingsAbout => 'O aplikacji';

  @override
  String settingsVersion(String version) {
    return 'Wersja $version';
  }

  @override
  String get settingsAboutBody =>
      'Część ekosystemu TexFi. Działa całkowicie offline — dane nie opuszczają urządzenia.';

  @override
  String notificationHabitTitle(String habit) {
    return 'Cel niezrobiony: $habit';
  }

  @override
  String notificationHabitBody(String punishment) {
    return 'Obiecałeś sobie: $punishment';
  }

  @override
  String get notificationDailyTitle => 'Koniec dnia';

  @override
  String notificationDailyBody(int count) {
    return 'Niezamkniętych celów: $count. Jeszcze jest czas.';
  }

  @override
  String get notificationChannelHabits => 'Przypomnienia o nawykach';

  @override
  String get notificationChannelHabitsDesc =>
      'Przypomnienia o niezrobionych dziennych celach';

  @override
  String get interruptionQuestion => 'Co cię wybiło?';

  @override
  String get interruptionOptional =>
      'Opcjonalne — pomaga aplikacji poznać twoje wzorce.';

  @override
  String get interruptionDistracted => 'Rozproszenie';

  @override
  String get interruptionWrongTask => 'Nie to zadanie';

  @override
  String get interruptionTired => 'Zmęczenie';

  @override
  String get interruptionNoComment => 'Wolę nie mówić';

  @override
  String get sessionNoteQuestion => 'Jak poszło?';

  @override
  String get sessionNoteHint => 'Kilka słów albo naklejka';

  @override
  String get guardShortBreakTitle => 'Od razu dalej?';

  @override
  String get guardShortBreakBody =>
      'Właśnie skończyłeś sesję. Prawdziwa przerwa poprawi następną.';

  @override
  String get guardBurnoutTitle => 'Trzy przerwane z rzędu';

  @override
  String get guardBurnoutBody =>
      'Może dziś warto odpocząć. Jeśli się nie zgadzasz, nic cię nie zatrzymuje.';

  @override
  String get guardNightCapTitle => 'Jest późno';

  @override
  String get guardNightCapBody =>
      'Po nocnej godzinie proponujemy krócej — niezależnie od nastroju i rekomendacji silnika.';

  @override
  String get guardStartAnyway => 'Zacznij mimo to';

  @override
  String get guardTakeABreak => 'Nie teraz';

  @override
  String get settingsBurnout => 'Tempo';

  @override
  String get settingsShortBreakWarning => 'Ostrzeżenie o krótkiej przerwie';

  @override
  String settingsShortBreakSubtitle(int count) {
    return 'Ostrzegaj, gdy start następuje w ciągu $count min od poprzedniej sesji';
  }

  @override
  String get settingsShortBreakOff => 'Wyłączone';

  @override
  String get settingsNightCap => 'Nocny limit';

  @override
  String get settingsNightCapSubtitle => 'Nocą nie proponuj dłużej niż 25/5';

  @override
  String get settingsNightCapHour => 'Noc zaczyna się o';

  @override
  String get habitByWeekdays => 'W wybrane dni';

  @override
  String get habitTimesPerWeek => 'N razy w tygodniu';

  @override
  String get habitTimesPerWeekLabel => 'Razy w tygodniu';

  @override
  String habitTimesPerWeekValue(int count) {
    return '$count× w tygodniu';
  }

  @override
  String get habitRewardLabel => 'Jeśli wytrwasz';

  @override
  String get habitRewardHint => 'Długa kąpiel, ta gra, wolny dzień';

  @override
  String get habitRewardExplainer =>
      'Opcjonalne i dokładnie tak samo twoja umowa z sobą jak kara — aplikacja tylko zapamięta i pokaże, gdy dojdziesz.';

  @override
  String get habitRewardStreakDays => 'Potrzebna seria';

  @override
  String habitRewardAfter(int count) {
    return 'Nagroda po $count dniach';
  }

  @override
  String habitRewardEarned(int count) {
    return 'Zasłużone — $count dni z rzędu';
  }

  @override
  String habitStreakWeeks(int count) {
    return '$count tygodni z rzędu';
  }

  @override
  String habitWeekProgress(int done, int target) {
    return '$done z $target w tym tygodniu';
  }

  @override
  String get habitFreezeAllow => 'Pozwól zamrozić serię';

  @override
  String habitFreezeAllowSubtitle(int days) {
    return 'Jeden pominięty dzień co $days dni nie psuje serii';
  }

  @override
  String get habitFreezeToday => 'Zamroź';

  @override
  String get habitFreezeUndo => 'Odmroź';

  @override
  String get habitFreezeHint => 'Pomiń dziś bez utraty serii';

  @override
  String get habitFreezeUndoHint => 'Dziś zamrożone — seria trwa';

  @override
  String get habitFreezeUnavailable => 'Zamrożenie jeszcze niedostępne';

  @override
  String get habitFrozenToday => 'Zamrożone';

  @override
  String get statsPunishment => 'Kiedy kara zadziałała';

  @override
  String statsPunishmentCount(int missed, int scheduled) {
    return '$missed z $scheduled dni pominięto';
  }

  @override
  String get statsPunishmentEmpty => 'W tym okresie nic nie pominięto.';

  @override
  String get statsInterruptions => 'Dlaczego sesje się urywały';

  @override
  String get statsInterruptionsEmpty =>
      'W tym okresie nie było przerwanych sesji.';

  @override
  String get statsInterruptionUnnamed => 'Bez podanego powodu';

  @override
  String get homePlanDay => 'Zaplanuj dzień';

  @override
  String get planTitle => 'Plan na dziś';

  @override
  String get planIntro =>
      'Dwa–trzy zadania, mniej więcej po kolei. Opcjonalne — po prostu nie musisz wymyślać zadania, gdy już siadasz do pracy.';

  @override
  String get planAddHint => 'Czym się dziś zajmiesz?';

  @override
  String get planEnough => 'Trzy na dzień zwykle wystarczą.';

  @override
  String get planToday => 'W planie';

  @override
  String get planEmpty => 'Nic jeszcze nie zaplanowano.';

  @override
  String get planFromTasks => 'Z twoich zadań';

  @override
  String get planDone => 'Odhacz';

  @override
  String get planUndone => 'Cofnij';

  @override
  String get planSubtasks => 'Lista kroków';

  @override
  String get planSubtaskHint => 'Jeden krok';

  @override
  String planSubtaskCount(int done, int total) {
    return '$done z $total kroków';
  }

  @override
  String get planSubtasksEmpty =>
      'Brak kroków — w sesji pokazują się jako lista.';

  @override
  String planSubtasksFull(int count) {
    return '$count kroków to limit na jedną sesję.';
  }

  @override
  String get moodFromPlan => 'Z dzisiejszego planu';

  @override
  String notificationDailyProductive(int sessions, int minutes, String mood) {
    return 'Dziś: $sessions sesji, $minutes min skupienia, najczęściej — $mood.';
  }

  @override
  String get notificationDailyAllDone =>
      'Dziś wszystko zamknięte. Dobra robota.';

  @override
  String get notificationChannelTimer => 'Minutnik';

  @override
  String get notificationChannelTimerDesc =>
      'Koniec bloku skupienia, przerwy albo całej sesji';

  @override
  String get notificationTimerFocusDoneTitle => 'Blok skupienia skończony';

  @override
  String notificationTimerFocusDoneBody(int cycle, int total) {
    return 'Cykl $cycle z $total za tobą. Czas na przerwę.';
  }

  @override
  String get notificationTimerBreakDoneTitle => 'Przerwa się skończyła';

  @override
  String get notificationTimerBreakDoneBody =>
      'Wróć do skupienia, gdy będziesz gotów.';

  @override
  String get notificationTimerSessionDoneTitle => 'Sesja zakończona';

  @override
  String notificationTimerSessionDoneBody(int minutes) {
    return '$minutes min skupienia w planie. Dobra robota.';
  }

  @override
  String get navMap => 'Mapa';

  @override
  String get gameSectionTitle => 'Tryb gry';

  @override
  String get gameModeToggle => 'Graj, a nie tylko odhaczaj';

  @override
  String get gameModeSubtitle =>
      'Sesje i nawyki zostają dokładnie takie same — nad nimi pojawiają się mapa, dryfery i poziomy.';

  @override
  String get gameModeOffNote =>
      'Wyłączenie tylko ukrywa grę. Poziom i postęp na mapie zostają, wrócisz w to samo miejsce.';

  @override
  String get gameReset => 'Zacznij grę od nowa';

  @override
  String get gameResetSubtitle =>
      'Zeruje doświadczenie i mapę. Nie dotyka sesji ani nawyków.';

  @override
  String get gameResetConfirm =>
      'Zacząć od nowa? Poziom i mapa wrócą do zera. Sesje, nawyki i statystyki zostaną nietknięte.';

  @override
  String get gameResetDone => 'Mapa zaczyna się od początku.';

  @override
  String get mapTitle => 'Mapa';

  @override
  String mapWorld(int world) {
    return 'Świat $world';
  }

  @override
  String get mapAllCleared =>
      'Wszystkie światy przejdziesz. Sesje wciąż dają doświadczenie.';

  @override
  String get mapNodeLocked => 'Zamknięty';

  @override
  String get mapNodeCleared => 'Przejdziony';

  @override
  String get mapNodeCurrent => 'Jesteś tutaj';

  @override
  String get mapBossNode => 'Boss';

  @override
  String get characterTitle => 'Postać';

  @override
  String characterLevel(int level) {
    return 'Poziom $level';
  }

  @override
  String characterXp(int current, int needed) {
    return '$current / $needed XP';
  }

  @override
  String characterToNextLevel(int xp) {
    return '$xp XP do następnego poziomu';
  }

  @override
  String get characterDriftersDefeated => 'Pokonane dryfery';

  @override
  String get characterBossesDefeated => 'Pokonani bossowie';

  @override
  String get characterTotalXp => 'Zdobyte doświadczenie';

  @override
  String get characterStage1 => 'Iskra';

  @override
  String get characterStage2 => 'Równy płomyk';

  @override
  String get characterStage3 => 'Płomyk z aurą';

  @override
  String get characterStage4 => 'Płomyk w koronie';

  @override
  String get drifterBuzz => 'Brzęk';

  @override
  String get drifterCreep => 'Pełzacz';

  @override
  String get drifterLoom => 'Mara';

  @override
  String get drifterBuzzFlavor =>
      'Rozpiętość skrzydeł większa niż ciało. Brzęknie raz — i uwagi nie ma.';

  @override
  String get drifterCreepFlavor =>
      'Niski i wielonogi. Nie nadlatuje, tylko podchodzi od dołu.';

  @override
  String get drifterLoomFlavor =>
      'Wysoka, wąska, z jednym pustym okiem. Po prostu stoi i patrzy.';

  @override
  String get bossScroll => 'Wstęga';

  @override
  String get bossChorus => 'Chór';

  @override
  String get bossHollow => 'Pustka';

  @override
  String get bossScrollFlavor =>
      'Wstęga zwinięta w samą siebie. Nie ma końca — na tym polega sztuczka.';

  @override
  String get bossChorusFlavor =>
      'Nie jedno stworzenie, lecz kiść głów, i mówią wszystkie naraz.';

  @override
  String get bossHollowFlavor => 'Ciężka rama wokół niczego. Wciąga do środka.';

  @override
  String get encounterTitle => 'Naprzeciw ciebie';

  @override
  String encounterHp(int current, int max) {
    return '$current / $max HP';
  }

  @override
  String get encounterWounded => 'Ranny — dokończ go.';

  @override
  String get encounterHealed => 'Kiedy cię nie było, zdążył się wylizać.';

  @override
  String get encounterBossHint =>
      'Naprawdę ranią go tylko sesje zaczęte w full f0kus.';

  @override
  String encounterBossStamina(int current, int total) {
    return 'Twoja wytrzymałość: $current z $total';
  }

  @override
  String get encounterBossStaminaHint =>
      'Każde porzucone podejście w f0kus kosztuje jeden punkt.';

  @override
  String get encounterFokusMissing =>
      'Wybierz full f0kus przy check-inie, żeby walczyć pełną siłą.';

  @override
  String gameXpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String gameLevelUp(int level) {
    return 'Poziom $level';
  }

  @override
  String get gameLevelUpBody => 'Twój płomyk się zmienił.';

  @override
  String get gameDrifterDefeated => 'Dryfer pokonany';

  @override
  String get gameBossDefeated => 'Boss pokonany';

  @override
  String get gameBossDefeatedBody => 'Droga do następnego świata jest otwarta.';

  @override
  String get gamePlayerDefeated => 'Boss doszedł do siebie';

  @override
  String get gamePlayerDefeatedBody =>
      'Znów jest pełen sił, i twoja wytrzymałość też. Spróbuj ponownie, gdy będziesz gotów — nic więcej nie przepadło.';

  @override
  String get gameContinue => 'Dalej';

  @override
  String get settingsAccent => 'Kolor akcentu';

  @override
  String get settingsAccentSubtitle =>
      'Zmienia się tylko ton akcentu — reszta palety zostaje bez zmian.';

  @override
  String get settingsImport => 'Import z JSON';

  @override
  String get settingsImportSubtitle =>
      'Przywróć wcześniejszy eksport na nowym urządzeniu';

  @override
  String get settingsImportPathHint =>
      'Pełna ścieżka do wyeksportowanego pliku .json.';

  @override
  String get settingsImportNoFile => 'Pod tą ścieżką nie ma pliku';

  @override
  String get settingsImportWarnTitle => 'To dotknie twoich danych';

  @override
  String get settingsImportWarnBody =>
      'Scalanie zachowa to, co już masz, i doda brakujące. Zamiana najpierw wymaże obecną historię — bez cofnięcia.';

  @override
  String get settingsImportMerge => 'Scal';

  @override
  String get settingsImportReplace => 'Zamień wszystko';

  @override
  String settingsImportDone(int habits, int tasks, int sessions) {
    return 'Zaimportowano: nawyki — $habits, zadania — $tasks, sesje — $sessions';
  }

  @override
  String get settingsImportFailed => 'Import nieudany';

  @override
  String get timerRepeat => 'Jeszcze jedna taka sama';

  @override
  String get recommendationEvidenceScopeLabel => 'Dopasowanie kontekstu';

  @override
  String get recommendationEvidenceCountLabel => 'Sesji u podstaw';

  @override
  String get recommendationEvidenceRateLabel => 'Zadziałało';

  @override
  String get recommendationScopeExact => 'dokładnie ten';

  @override
  String get recommendationScopeSimilar => 'podobna praca';

  @override
  String get recommendationScopeBroad => 'ten nastrój ogólnie';

  @override
  String get recommendationScopeNone => 'brak danych';
}
