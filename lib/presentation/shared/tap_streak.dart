/// Счётчик быстрых нажатий подряд.
///
/// Отдельный класс, а не пара полей в состоянии экрана: у такого счётчика
/// есть ровно один способ ошибиться незаметно — не сбрасываться на паузе.
/// Тогда семь нажатий, растянутые на неделю, однажды сработали бы сами
/// собой, и человек получил бы экран, которого не звал.
class TapStreak {
  TapStreak({this.required = 7, this.window = const Duration(seconds: 1)});

  /// Сколько нажатий подряд нужно набрать.
  final int required;

  /// Максимальная пауза между двумя нажатиями. Секунда — это заведомо
  /// быстрее, чем случайные повторные тычки по одному и тому же тексту.
  final Duration window;

  int _count = 0;
  DateTime? _last;

  int get count => _count;

  /// Регистрирует нажатие в момент [at]. Возвращает `true` ровно один раз —
  /// на том нажатии, которое замкнуло серию; счётчик при этом обнуляется,
  /// чтобы восьмое нажатие не открывало экран второй раз.
  bool register(DateTime at) {
    final previous = _last;
    _last = at;
    _count = (previous == null || at.difference(previous) > window)
        ? 1
        : _count + 1;

    if (_count < required) return false;
    reset();
    return true;
  }

  void reset() {
    _count = 0;
    _last = null;
  }
}
