/// Часы одной фазы таймера, считающие по стенным часам, а не по тикам.
///
/// Почему так. Раньше обратный отсчёт вычитал секунду на каждый тик
/// `Timer.periodic`. Пока приложение на переднем плане, это выглядит
/// правильно — но стоит заблокировать экран или свернуть приложение, как
/// система придерживает Dart-таймеры, тики перестают приходить с нужной
/// частотой, и отсчёт отстаёт ровно на то время, что телефон лежал в кармане.
/// Пользователь возвращался к экрану, на котором «прошло» полминуты вместо
/// двадцати. Хуже того, тем же счётчиком набиралось `focusSeconds` — то есть
/// врало не только табло, но и статистика с опытом.
///
/// [PhaseClock] хранит не «сколько натикало», а точку отсчёта: сколько
/// оставалось в момент якоря и когда этот якорь поставлен. Остаток — всегда
/// разность с текущим временем, поэтому он верен в любой момент, когда его
/// ни спроси, и не зависит от того, приходили тики или нет. Тик из механизма
/// счёта превращается в то, чем и должен быть, — поводом перерисовать экран.
///
/// Класс намеренно не знает ни про Flutter, ни про фазы и циклы: только
/// арифметика времени, которую можно проверить тестом без единого кадра.
class PhaseClock {
  const PhaseClock({
    required this.plannedRemaining,
    required this.runningSince,
  });

  /// Часы на паузе: время не течёт, пока не позовут [resumedAt].
  const PhaseClock.paused(Duration remaining)
      : plannedRemaining = remaining,
        runningSince = null;

  /// Часы, запущенные в момент [now] с полной длительностью фазы.
  PhaseClock.startedAt(DateTime now, Duration duration)
      : plannedRemaining = duration,
        runningSince = now;

  /// Сколько оставалось в момент, когда поставлен якорь.
  final Duration plannedRemaining;

  /// Момент постановки якоря. `null` — часы стоят.
  final DateTime? runningSince;

  bool get running => runningSince != null;

  /// Сколько времени прошло с якоря.
  ///
  /// Отрицательная разница означает, что часы устройства перевели назад
  /// (или сменилась зона). Отматывать таймер назад из-за этого нельзя —
  /// считаем, что не прошло ничего.
  Duration elapsedSinceAnchor(DateTime now) {
    final since = runningSince;
    if (since == null) return Duration.zero;
    final elapsed = now.difference(since);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  /// Остаток фазы на момент [now]. Может быть отрицательным — и это важно:
  /// «минус три минуты» означает, что фаза кончилась три минуты назад, пока
  /// экран был заблокирован, и на столько же надо сдвинуть начало следующей.
  Duration remainingAt(DateTime now) =>
      plannedRemaining - elapsedSinceAnchor(now);

  /// Остаток для показа — уже без отрицательных значений.
  Duration displayRemainingAt(DateTime now) {
    final remaining = remainingAt(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Сколько времени фаза реально отработала с якоря: не больше, чем её
  /// собственный остаток. Перелёт за конец фазы принадлежит уже следующей
  /// фазе и в зачёт этой не идёт — иначе одна заблокированная на час трубка
  /// принесла бы час «фокуса» за пятиминутную фазу.
  Duration servedAt(DateTime now) {
    final elapsed = elapsedSinceAnchor(now);
    return elapsed > plannedRemaining ? plannedRemaining : elapsed;
  }

  /// Фаза дошла до конца к моменту [now].
  bool isExpiredAt(DateTime now) => running && remainingAt(now) <= Duration.zero;

  /// Остановить: запоминаем фактический остаток и снимаем якорь.
  PhaseClock pausedAt(DateTime now) =>
      PhaseClock.paused(displayRemainingAt(now));

  /// Запустить с текущего остатка.
  PhaseClock resumedAt(DateTime now) => PhaseClock(
        plannedRemaining: displayRemainingAt(now),
        runningSince: now,
      );

  /// Переставить остаток, не трогая состояния «идут / стоят». Нужно для
  /// подкрутки диском: пользователь меняет остаток посреди фазы, и якорь
  /// обязан переехать вместе с ним.
  PhaseClock withRemaining(Duration remaining, DateTime now) {
    final clamped = remaining.isNegative ? Duration.zero : remaining;
    return PhaseClock(
      plannedRemaining: clamped,
      runningSince: running ? now : null,
    );
  }

  /// Часы следующей фазы, начатой в момент истечения текущей.
  ///
  /// [overshoot] — насколько поздно мы об этом узнали. Якорь ставится назад
  /// на эту величину, поэтому фаза, целиком прошедшая под заблокированным
  /// экраном, окажется истёкшей сразу же, а не начнёт отсчёт заново.
  PhaseClock nextPhase({
    required Duration duration,
    required bool running,
    required Duration overshoot,
    required DateTime now,
  }) {
    if (!running) return PhaseClock.paused(duration);
    return PhaseClock(
      plannedRemaining: duration,
      runningSince: now.subtract(overshoot.isNegative ? Duration.zero : overshoot),
    );
  }
}
