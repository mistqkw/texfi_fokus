import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_release.dart';

/// Когда можно снова спрашивать GitHub.
///
/// GitHub отдаёт неаутентифицированному клиенту 60 запросов в час на IP —
/// это не «на пользователя», а на весь NAT провайдера или офиса. Поэтому
/// дёргать API на каждом запуске нельзя даже теоретически, и главное здесь —
/// не забыть про неудачу: если просто не сохранять результат ошибки, то
/// приложение без сети будет ломиться в API при каждом старте, а после
/// исчерпания лимита — ещё и держать его исчерпанным.
abstract final class UpdateCheckPolicy {
  /// Успешная проверка живёт полдня: релизы выходят не чаще.
  static const Duration successTtl = Duration(hours: 6);

  /// После отказа (нет сети, 403 rate limit, мусор в ответе) ждём меньше,
  /// но всё-таки ждём: сеть могла появиться, а лимит — обнулиться.
  static const Duration failureBackoff = Duration(hours: 1);
}

/// Результат последней проверки: что нашли и когда.
class UpdateCheckState {
  const UpdateCheckState({
    required this.checkedAt,
    required this.succeeded,
    this.release,
  });

  final DateTime checkedAt;

  /// Дошёл ли запрос до внятного ответа. `false` — сеть или лимит.
  final bool succeeded;

  /// Последний известный релиз. `null` — проверка не удалась либо релизов нет.
  final AppRelease? release;

  /// Пора ли идти в сеть снова.
  bool isStaleAt(DateTime now) {
    final age = now.difference(checkedAt);
    // Часы на телефоне переводят, зону меняют, а сохранённое время при этом
    // оказывается «в будущем». Отрицательный возраст — повод проверить
    // заново, а не ждать шесть часов вперёд.
    if (age.isNegative) return true;
    final ttl = succeeded
        ? UpdateCheckPolicy.successTtl
        : UpdateCheckPolicy.failureBackoff;
    return age >= ttl;
  }
}

/// Решение о том, нужен ли сетевой запрос. Вынесено отдельной функцией,
/// чтобы проверяться тестом без SharedPreferences и без часов.
bool shouldCheckNow({
  required UpdateCheckState? last,
  required DateTime now,
  bool force = false,
}) {
  // Кнопка в настройках — это осознанное действие человека, она обязана
  // сходить в сеть, даже если кэш свежий. Иначе нажатие ничего не делает и
  // выглядит сломанным.
  if (force) return true;
  if (last == null) return true;
  return last.isStaleAt(now);
}

/// Хранение результата проверки в тех же SharedPreferences, что и остальные
/// настройки: отдельный слой ради трёх значений заводить незачем.
class UpdateCheckCache {
  UpdateCheckCache(this._prefs);

  final SharedPreferences _prefs;

  static const String _checkedAtKey = 'update_checked_at';
  static const String _succeededKey = 'update_check_ok';
  static const String _releaseKey = 'update_release';

  UpdateCheckState? read() {
    final millis = _prefs.getInt(_checkedAtKey);
    if (millis == null) return null;
    final raw = _prefs.getString(_releaseKey);
    AppRelease? release;
    if (raw != null && raw.isNotEmpty) {
      try {
        release = AppRelease.fromCacheJson(jsonDecode(raw));
      } catch (_) {
        // Кэш испорчен — считаем, что его нет. Это всего лишь повод сходить
        // в сеть, а не повод уронить настройки.
        release = null;
      }
    }
    return UpdateCheckState(
      checkedAt: DateTime.fromMillisecondsSinceEpoch(millis),
      succeeded: _prefs.getBool(_succeededKey) ?? false,
      release: release,
    );
  }

  Future<void> write(UpdateCheckState state) async {
    await _prefs.setInt(_checkedAtKey, state.checkedAt.millisecondsSinceEpoch);
    await _prefs.setBool(_succeededKey, state.succeeded);
    final release = state.release;
    if (release == null) {
      await _prefs.remove(_releaseKey);
    } else {
      await _prefs.setString(_releaseKey, jsonEncode(release.toJson()));
    }
  }
}
