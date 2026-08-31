/// Форматирование длительностей для интерфейса.
abstract final class DurationFormat {
  /// Компактно: `45m`, `2h 10m`, `0m`. Единицы намеренно не переводятся —
  /// это часть «терминального» вида счётчиков, одинаковая во всех языках.
  static String compact(Duration duration) {
    final total = duration.isNegative ? Duration.zero : duration;
    final hours = total.inHours;
    final minutes = total.inMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  static String compactFromSeconds(int seconds) =>
      compact(Duration(seconds: seconds));

  static String compactFromMinutes(int minutes) =>
      compact(Duration(minutes: minutes));

  /// `MM:SS`, а при часе и больше — `H:MM:SS`. Для цифр таймера.
  static String clock(Duration duration) {
    final total = duration.isNegative ? Duration.zero : duration;
    final seconds = total.inSeconds % 60;
    final minutes = total.inMinutes;
    if (minutes >= 60) {
      return '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}'
          ':${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}'
        ':${seconds.toString().padLeft(2, '0')}';
  }

  /// Минуты от полуночи в `HH:MM`.
  static String timeOfDay(int minutesFromMidnight) {
    final h = (minutesFromMidnight ~/ 60) % 24;
    final m = minutesFromMidnight % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
