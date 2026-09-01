import 'focus_technique.dart';
import 'mood.dart';
import 'recommendation.dart';
import 'session_entity.dart';

/// О чём именно наблюдение. UI по этому виду выбирает формулировку —
/// сам текст в домене не живёт, он локализуемый.
enum InsightKind {
  /// Настроение, с которого сессии чаще всего доходят до конца.
  bestMood,

  /// День недели с наибольшим временем в фокусе.
  bestWeekday,

  /// Время суток с лучшей доводимостью сессий.
  bestTimeOfDay,

  /// Техника, которая у пользователя срабатывает чаще прочих.
  bestTechnique,
}

/// Одно конкретное наблюдение о том, как человек работает.
///
/// Значения — типизированные, а не заранее собранная строка: иначе домен
/// пришлось бы знакомить с локализацией, и наблюдение нельзя было бы
/// проверить тестом без всего Flutter-а.
class Insight {
  const Insight({
    required this.kind,
    required this.sampleSize,
    this.mood,
    this.weekday,
    this.timeOfDay,
    this.technique,
    this.percent = 0,
    this.minutes = 0,
  });

  final InsightKind kind;

  /// Сколько сессий стоит за наблюдением.
  final int sampleSize;

  final Mood? mood;

  /// 1 — понедельник … 7 — воскресенье.
  final int? weekday;

  final TimeOfDayBucket? timeOfDay;
  final FocusTechnique? technique;

  /// Доля успеха в процентах — для наблюдений, где она осмысленна.
  final int percent;

  /// Среднее время в фокусе за день, минуты — для [InsightKind.bestWeekday].
  final int minutes;
}

/// Достаёт из истории сессий одно наблюдение, которое стоит показать.
///
/// Правила намеренно строгие. Наблюдение, собранное на двух сессиях, — это
/// не наблюдение, а совпадение; показать его один раз дешевле, чем потом
/// объяснять пользователю, почему приложение соврало. Поэтому у каждой
/// гипотезы есть минимальный объём выборки и минимальный отрыв от
/// остальных вариантов.
abstract final class InsightBuilder {
  /// Меньше этого числа сессий за период — не показываем ничего.
  static const int minSessions = 6;

  /// Минимум наблюдений в самой корзине-победителе.
  static const int minBucket = 3;

  /// На сколько победитель должен опережать среднее, чтобы это считалось
  /// закономерностью, а не разбросом.
  static const double minLead = 0.15;

  /// Собирает все подтверждённые наблюдения и выбирает одно.
  ///
  /// [now] задаёт «сегодня»: от него зависит, какое из равнозначных
  /// наблюдений покажется. Ротация по дню — чтобы карточка не показывала
  /// неделю подряд одну и ту же фразу; выбор при этом детерминированный, и
  /// в течение дня карточка не прыгает при каждом перестроении экрана.
  static Insight? build(List<SessionEntity> sessions, DateTime now) {
    if (sessions.length < minSessions) return null;

    final candidates = <Insight>[
      ..._mood(sessions),
      ..._weekday(sessions),
      ..._timeOfDay(sessions),
      ..._technique(sessions),
    ];
    if (candidates.isEmpty) return null;

    // Сначала по объёму данных — наблюдение на 12 сессиях весомее, чем на
    // четырёх, — и только внутри равных ротация по дню.
    candidates.sort((a, b) => b.sampleSize.compareTo(a.sampleSize));
    final top = candidates
        .where((c) => c.sampleSize >= candidates.first.sampleSize - 1)
        .toList();
    final dayIndex = now.difference(DateTime(now.year)).inDays;
    return top[dayIndex % top.length];
  }

  static Iterable<Insight> _mood(List<SessionEntity> sessions) sync* {
    final best = _bestRate(sessions, (s) => s.mood);
    if (best == null) return;
    yield Insight(
      kind: InsightKind.bestMood,
      sampleSize: best.count,
      mood: best.key,
      percent: (best.rate * 100).round(),
    );
  }

  static Iterable<Insight> _timeOfDay(List<SessionEntity> sessions) sync* {
    final best = _bestRate(
      sessions,
      (s) => TimeOfDayBucket.fromHour(s.startedAt.hour),
    );
    if (best == null) return;
    yield Insight(
      kind: InsightKind.bestTimeOfDay,
      sampleSize: best.count,
      timeOfDay: best.key,
      percent: (best.rate * 100).round(),
    );
  }

  static Iterable<Insight> _technique(List<SessionEntity> sessions) sync* {
    final best = _bestRate(sessions, (s) => s.technique);
    if (best == null) return;
    yield Insight(
      kind: InsightKind.bestTechnique,
      sampleSize: best.count,
      technique: best.key,
      percent: (best.rate * 100).round(),
    );
  }

  /// День недели меряем не долей успеха, а временем в фокусе: «во вторник
  /// я работаю больше» — утверждение о нагрузке, а не о доводимости.
  /// Считаем средним на активный день, иначе победит тот день, который
  /// просто чаще попал в период.
  static Iterable<Insight> _weekday(List<SessionEntity> sessions) sync* {
    final seconds = <int, int>{};
    final days = <int, Set<DateTime>>{};
    final counts = <int, int>{};

    for (final session in sessions) {
      final weekday = session.startedAt.weekday;
      seconds[weekday] = (seconds[weekday] ?? 0) + session.actualFocusSeconds;
      counts[weekday] = (counts[weekday] ?? 0) + 1;
      (days[weekday] ??= <DateTime>{}).add(
        DateTime(
          session.startedAt.year,
          session.startedAt.month,
          session.startedAt.day,
        ),
      );
    }
    if (seconds.length < 2) return;

    final averages = <int, double>{
      for (final entry in seconds.entries)
        entry.key: entry.value / days[entry.key]!.length,
    };

    final sorted = averages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final winner = sorted.first;
    if ((counts[winner.key] ?? 0) < minBucket) return;

    final rest = sorted.skip(1);
    final restAverage =
        rest.fold<double>(0, (sum, e) => sum + e.value) / rest.length;
    if (restAverage <= 0 || winner.value < restAverage * (1 + minLead)) return;

    yield Insight(
      kind: InsightKind.bestWeekday,
      sampleSize: counts[winner.key] ?? 0,
      weekday: winner.key,
      minutes: (winner.value / 60).round(),
    );
  }

  /// Общая механика для «где доля успеха выше»: группируем, отбрасываем
  /// мелкие корзины, требуем отрыва от среднего по остальным.
  static _Bucket<T>? _bestRate<T>(
    List<SessionEntity> sessions,
    T Function(SessionEntity) keyOf,
  ) {
    final total = <T, int>{};
    final success = <T, int>{};
    for (final session in sessions) {
      final key = keyOf(session);
      total[key] = (total[key] ?? 0) + 1;
      if (session.isSuccess) success[key] = (success[key] ?? 0) + 1;
    }

    final eligible = total.entries.where((e) => e.value >= minBucket).toList();
    if (eligible.length < 2) return null;

    final rates = <T, double>{
      for (final entry in eligible)
        entry.key: (success[entry.key] ?? 0) / entry.value,
    };
    final sorted = rates.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final winner = sorted.first;
    final rest = sorted.skip(1);
    final restAverage =
        rest.fold<double>(0, (sum, e) => sum + e.value) / rest.length;
    if (winner.value < restAverage + minLead) return null;
    if (winner.value <= 0) return null;

    return _Bucket(
      key: winner.key,
      count: total[winner.key]!,
      rate: winner.value,
    );
  }
}

class _Bucket<T> {
  const _Bucket({required this.key, required this.count, required this.rate});

  final T key;
  final int count;
  final double rate;
}
