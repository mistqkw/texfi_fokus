/// Фаза таймера. Живёт в домене, а не рядом с контроллером, потому что от
/// неё зависит расчёт будильников — а он должен быть проверяемым без
/// Flutter и без экрана.
enum TimerPhase { focus, rest }

/// Одно запланированное срабатывание: «через [after] закончится [endingPhase]».
///
/// Смещение считается от «сейчас», а не абсолютным временем: тот, кто ставит
/// уведомление, сам знает, какой у него часовой пояс, а тесты не должны
/// зависеть от системных часов.
class TimerAlarm {
  const TimerAlarm({
    required this.after,
    required this.endingPhase,
    required this.cycleNumber,
    required this.isFinal,
  });

  final Duration after;
  final TimerPhase endingPhase;

  /// 1-based номер цикла, который закончится этим срабатыванием.
  final int cycleNumber;

  /// Последнее срабатывание сессии — дальше таймера нет.
  final bool isFinal;

  @override
  bool operator ==(Object other) =>
      other is TimerAlarm &&
      other.after == after &&
      other.endingPhase == endingPhase &&
      other.cycleNumber == cycleNumber &&
      other.isFinal == isFinal;

  @override
  int get hashCode => Object.hash(after, endingPhase, cycleNumber, isFinal);

  @override
  String toString() =>
      'TimerAlarm(${after.inSeconds}s, $endingPhase, cycle $cycleNumber, '
      'final: $isFinal)';
}

/// Считает, когда таймеру предстоит зазвонить.
///
/// Уведомления о конце фазы планируются заранее, в момент старта сессии, а не
/// ставятся через `Future.delayed` в момент, когда время уже вышло: таймер
/// на стороне Dart не переживает ни сворачивания приложения системой, ни его
/// закрытия, и пользователь в беззвучном режиме просто пропускал конец
/// сессии. Поэтому весь график считается вперёд и отдаётся системе.
abstract final class TimerAlarmPlanner {
  /// Больше этого числа уведомлений вперёд не планируем: длинная сессия из
  /// двадцати циклов иначе забьёт системную очередь, а точность дальних
  /// срабатываний всё равно теряется.
  static const int maxAlarms = 12;

  /// Полный график оставшихся срабатываний.
  ///
  /// Если следующая фаза не стартует сама ([autoStartNext] = false), дальше
  /// текущей фазы заглядывать нельзя: когда пользователь нажмёт «дальше» —
  /// неизвестно, и любые расчёты за этой точкой были бы выдумкой.
  static List<TimerAlarm> upcoming({
    required TimerPhase phase,
    required int cycleIndex,
    required int totalCycles,
    required Duration remaining,
    required Duration focusDuration,
    required Duration breakDuration,
    required bool autoStartNext,
    bool running = true,
  }) {
    // Пауза и уже вышедшее время не порождают будильников: на паузе конца
    // фазы просто не существует.
    if (!running || remaining <= Duration.zero || totalCycles <= 0) {
      return const [];
    }

    final alarms = <TimerAlarm>[];
    var offset = remaining;
    var current = phase;
    var cycle = cycleIndex.clamp(0, totalCycles - 1);

    while (alarms.length < maxAlarms) {
      final isFinal = current == TimerPhase.focus && cycle >= totalCycles - 1;
      alarms.add(
        TimerAlarm(
          after: offset,
          endingPhase: current,
          cycleNumber: cycle + 1,
          isFinal: isFinal,
        ),
      );

      if (isFinal || !autoStartNext) break;

      if (current == TimerPhase.focus) {
        current = TimerPhase.rest;
        offset += breakDuration;
      } else {
        current = TimerPhase.focus;
        cycle += 1;
        offset += focusDuration;
      }

      // Нулевая длительность перерыва свернула бы цикл в бесконечный: фазы
      // сменяли бы друг друга в одну и ту же секунду.
      if (offset <= alarms.last.after) break;
    }

    return alarms;
  }
}
