/// Распознавание одного узкого случая: несколько ночей подряд подряд идущих
/// сессий глубоко за полночь.
///
/// Отдельной системы слежения за сном здесь нет и не предполагается — это
/// чистая функция от уже сохранённых времён начала сессий. Ничего не
/// записывает, ни на что не влияет и никого ни в чём не убеждает: её
/// единственный потребитель показывает по ней одну короткую строку.
abstract final class LateNightPattern {
  /// С какого часа вечера считается «уже ночь».
  static const int nightStartsAtHour = 23;

  /// До какого часа утра. Пять — граница, после которой это уже не
  /// «засиделся», а «встал рано», и путать их незачем.
  static const int nightEndsAtHour = 5;

  /// Сколько сессий за ночь делают её «несколькими подряд».
  static const int sessionsPerNight = 2;

  /// Сколько таких ночей подряд складываются в закономерность.
  static const int nightsInARow = 3;

  /// Насколько свежей должна быть последняя такая ночь, чтобы речь шла о
  /// сейчас, а не о позапрошлом месяце. Считается от вечера этой ночи,
  /// поэтому «сегодняшняя» ночь укладывается в сутки с небольшим.
  static const Duration staleAfter = Duration(days: 3);

  static bool isLateNight(DateTime at) =>
      at.hour >= nightStartsAtHour || at.hour < nightEndsAtHour;

  /// К какой ночи относится момент. Ночь называется по своему вечеру:
  /// час ночи второго числа — это всё ещё ночь первого, и считать её
  /// отдельным днём значило бы разрывать одну ночь пополам.
  static DateTime nightOf(DateTime at) {
    final shifted = at.subtract(const Duration(hours: nightEndsAtHour));
    return DateTime(shifted.year, shifted.month, shifted.day);
  }

  /// Есть ли закономерность в этих временах начала сессий.
  ///
  /// [starts] может приходить в любом порядке и с любым мусором за пределами
  /// ночных часов — всё лишнее отсеивается здесь.
  static bool detect(Iterable<DateTime> starts, {required DateTime now}) {
    final perNight = <DateTime, int>{};
    for (final start in starts) {
      if (!isLateNight(start)) continue;
      final night = nightOf(start);
      perNight[night] = (perNight[night] ?? 0) + 1;
    }

    final nights = [
      for (final entry in perNight.entries)
        if (entry.value >= sessionsPerNight) entry.key,
    ]..sort();
    if (nights.length < nightsInARow) return false;

    // Ищем цепочку подряд идущих ночей, кончающуюся достаточно недавно.
    var run = 1;
    for (var i = 1; i < nights.length; i++) {
      final gap = nights[i].difference(nights[i - 1]).inDays;
      run = gap == 1 ? run + 1 : 1;
      if (run < nightsInARow) continue;
      if (now.difference(nights[i]) <= staleAfter) return true;
    }
    return false;
  }
}
