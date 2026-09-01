import 'focus_technique.dart';
import 'recommendation.dart';
import 'session_entity.dart';

/// Правила, которые стоят между пользователем и кнопкой «начать».
///
/// Ни одно из них не запрещает старт — все они только замедляют его на один
/// осознанный шаг. Приложение, которое умеет сказать «не сейчас», полезнее
/// того, которое молча продаёт ещё одну сессию; но приложение, которое
/// запрещает работать, пользователь удаляет.
///
/// Логика вынесена из провайдеров нарочно: это чистые функции от времени и
/// истории, и проверять их надо без Flutter, БД и настроек.
abstract final class SessionGuards {
  /// Через сколько минут после прошлой сессии старт уже не считается
  /// «сразу же». Пять минут — короткий перерыв в самой популярной технике:
  /// меньше этого человек буквально не встал со стула.
  static const int defaultShortBreakMinutes = 5;

  /// С какого часа включается ночной софт-кап.
  static const int defaultNightCapHour = 23;

  /// Сколько прерванных сессий подряд считаем поводом остановиться.
  ///
  /// Две подряд — обычное невезение или два телефонных звонка. Три — уже
  /// картина дня, и продолжать в том же режиме смысла мало.
  static const int burnoutStreakThreshold = 3;

  /// Границы настройки. Единица означала бы «после любой прерванной сессии»
  /// — это не забота, а придирка; выше пяти разговор об усталости приходит
  /// уже после того, как день закончился.
  static const int minStreakThreshold = 2;
  static const int maxStreakThreshold = 5;

  /// Самое длинное, что предлагаем ночью. Полный помидор 25/5 ещё оставляет
  /// шанс лечь спать; deep work на 90 минут в час ночи — нет.
  static const FocusTechnique nightCapTechnique = FocusTechnique.pomodoro2505;

  /// Ночь как её ощущает человек, а не календарь: и 23:30, и 03:00 — это
  /// «уже поздно». Час [capHour] и всё после него до пяти утра.
  static bool isLateNight(int hour, {int capHour = defaultNightCapHour}) {
    if (capHour <= 0 || capHour > 23) return false;
    return hour >= capHour || hour < 5;
  }

  /// Нужно ли предупредить, что предыдущая сессия закончилась только что.
  ///
  /// [lastEndedAt] null — предыдущей сессии нет, предупреждать не о чем.
  /// Отрицательный интервал (часы перевели назад) тоже не повод: это
  /// артефакт, а не спешка пользователя.
  static bool needsShortBreakWarning({
    required DateTime? lastEndedAt,
    required DateTime now,
    int minGapMinutes = defaultShortBreakMinutes,
  }) {
    if (lastEndedAt == null || minGapMinutes <= 0) return false;
    final gap = now.difference(lastEndedAt);
    if (gap.isNegative) return false;
    return gap < Duration(minutes: minGapMinutes);
  }

  /// Идёт ли серия прерванных сессий. [recent] ожидается отсортированным от
  /// свежих к старым — именно так его отдаёт `watchRecentSessions`.
  ///
  /// Считаем только по [SessionOutcome], а не по [SessionEntity.isSuccess]:
  /// оценка «3 из 5» на оборванной сессии всё равно означает, что человек
  /// не досидел, и для разговора об усталости важно именно это.
  static bool isBurnoutStreak(
    List<SessionEntity> recent, {
    int threshold = burnoutStreakThreshold,
  }) {
    if (recent.length < threshold) return false;
    return recent
        .take(threshold)
        .every((s) => s.outcome == SessionOutcome.aborted);
  }

  /// Ночной софт-кап: укорачивает предложение, если сессия стартует поздно.
  ///
  /// Кап именно мягкий — техника подменяется на более короткую, но выбор
  /// движка и всё его объяснение сохраняются: пользователь должен видеть,
  /// что предложение урезали, а не что движок вдруг передумал.
  static Recommendation capForNight(
    Recommendation recommendation, {
    required int hour,
    int capHour = defaultNightCapHour,
  }) {
    if (!isLateNight(hour, capHour: capHour)) return recommendation;

    final capped = nightCapTechnique;
    // Сравниваем и непрерывный блок, и весь план. Одного общего времени мало:
    // deep work на 90 минут короче четырёх помидоров суммарно, но именно эти
    // 90 минут без единого перерыва ночью и не нужны.
    final tooLong =
        recommendation.focusMinutes > capped.focusMinutes ||
            recommendation.technique.totalMinutes > capped.totalMinutes;
    // Сессия короче капа ночью остаётся как есть: подтягивать спринт на 15
    // минут вверх до помидора было бы ровно обратным тому, чего мы хотим.
    if (!tooLong) return recommendation;

    return recommendation.copyWith(
      technique: capped,
      focusMinutes: capped.focusMinutes,
      breakMinutes: capped.breakMinutes,
      cycles: capped.cycles,
      cappedForNight: true,
      clearPreset: true,
    );
  }
}
