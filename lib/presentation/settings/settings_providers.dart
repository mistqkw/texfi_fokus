import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/haptics/haptics.dart';
import '../../core/theme/app_accent.dart';
import '../../data/providers/data_providers.dart';
import '../../domain/entities/session_guards.dart';

/// Ключи SharedPreferences собраны в одном месте: опечатка в строке иначе
/// молча теряет настройку пользователя.
abstract final class PrefKeys {
  static const themeMode = 'theme_mode';
  static const localeCode = 'locale_code';
  static const soundsEnabled = 'sounds_enabled';
  static const vibrationEnabled = 'vibration_enabled';
  static const vibrationIntensity = 'vibration_intensity';
  static const notificationsEnabled = 'notifications_enabled';
  static const dailySummaryMinutes = 'daily_summary_minutes';
  static const onboardingDone = 'onboarding_done';
  static const accent = 'accent_color';
  static const shortBreakMinutes = 'short_break_minutes';
  static const nightCapEnabled = 'night_cap_enabled';
  static const nightCapHour = 'night_cap_hour';
}

/// Все поддерживаемые языки. Порядок — как в списке настроек.
const List<Locale> supportedLocales = [
  Locale('en'),
  Locale('ru'),
  Locale('pl'),
  Locale('uk'),
];

// --- Тема ---

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs) : super(_read(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _read(SharedPreferences prefs) {
    final stored = prefs.getString(PrefKeys.themeMode);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(PrefKeys.themeMode, mode.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(sharedPreferencesProvider));
});

/// Акцентный тон интерфейса. Хранится ключом, а не индексом: порядок
/// пресетов может поменяться, а выбор пользователя — нет.
class AccentNotifier extends StateNotifier<AppAccent> {
  AccentNotifier(this._prefs)
      : super(AppAccent.fromKey(_prefs.getString(PrefKeys.accent)));

  final SharedPreferences _prefs;

  Future<void> set(AppAccent accent) async {
    state = accent;
    await _prefs.setString(PrefKeys.accent, accent.key);
  }
}

final accentProvider = StateNotifierProvider<AccentNotifier, AppAccent>((ref) {
  return AccentNotifier(ref.watch(sharedPreferencesProvider));
});

// --- Язык ---

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._prefs) : super(_read(_prefs));

  final SharedPreferences _prefs;

  static Locale? _read(SharedPreferences prefs) {
    final code = prefs.getString(PrefKeys.localeCode);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  /// null — следовать системному языку.
  Future<void> set(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _prefs.remove(PrefKeys.localeCode);
    } else {
      await _prefs.setString(PrefKeys.localeCode, locale.languageCode);
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref.watch(sharedPreferencesProvider));
});

// --- Звук и вибрация ---

class SoundsNotifier extends StateNotifier<bool> {
  SoundsNotifier(this._prefs)
      : super(_prefs.getBool(PrefKeys.soundsEnabled) ?? true);

  final SharedPreferences _prefs;

  Future<void> set(bool value) async {
    state = value;
    await _prefs.setBool(PrefKeys.soundsEnabled, value);
  }
}

final soundsEnabledProvider =
    StateNotifierProvider<SoundsNotifier, bool>((ref) {
  return SoundsNotifier(ref.watch(sharedPreferencesProvider));
});

/// Держит статический [Haptics] в согласии с настройкой. Статика тут
/// осознанная: вибрация вызывается из мест без доступа к ref (кастомные
/// painters, обработчики жестов), и таскать туда провайдер было бы шумно.
class VibrationNotifier extends StateNotifier<bool> {
  VibrationNotifier(this._prefs)
      : super(_prefs.getBool(PrefKeys.vibrationEnabled) ?? true) {
    Haptics.enabled = state;
  }

  final SharedPreferences _prefs;

  Future<void> set(bool value) async {
    state = value;
    Haptics.enabled = value;
    await _prefs.setBool(PrefKeys.vibrationEnabled, value);
  }
}

final vibrationEnabledProvider =
    StateNotifierProvider<VibrationNotifier, bool>((ref) {
  return VibrationNotifier(ref.watch(sharedPreferencesProvider));
});

class VibrationIntensityNotifier extends StateNotifier<double> {
  VibrationIntensityNotifier(this._prefs)
      : super(_prefs.getDouble(PrefKeys.vibrationIntensity) ?? 1.0) {
    Haptics.intensity = state;
  }

  final SharedPreferences _prefs;

  Future<void> set(double value) async {
    state = value;
    Haptics.intensity = value;
    await _prefs.setDouble(PrefKeys.vibrationIntensity, value);
  }
}

final vibrationIntensityProvider =
    StateNotifierProvider<VibrationIntensityNotifier, double>((ref) {
  return VibrationIntensityNotifier(ref.watch(sharedPreferencesProvider));
});

// --- Уведомления ---

class NotificationsEnabledNotifier extends StateNotifier<bool> {
  NotificationsEnabledNotifier(this._prefs)
      : super(_prefs.getBool(PrefKeys.notificationsEnabled) ?? true);

  final SharedPreferences _prefs;

  Future<void> set(bool value) async {
    state = value;
    await _prefs.setBool(PrefKeys.notificationsEnabled, value);
  }
}

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsEnabledNotifier, bool>((ref) {
  return NotificationsEnabledNotifier(ref.watch(sharedPreferencesProvider));
});

/// Во сколько приходит итог дня, минуты от полуночи. 21:00 по умолчанию —
/// поздно, но ещё остаётся время что-то закрыть.
class DailySummaryTimeNotifier extends StateNotifier<int> {
  DailySummaryTimeNotifier(this._prefs)
      : super(_prefs.getInt(PrefKeys.dailySummaryMinutes) ?? 21 * 60);

  final SharedPreferences _prefs;

  Future<void> set(int minutesFromMidnight) async {
    state = minutesFromMidnight;
    await _prefs.setInt(PrefKeys.dailySummaryMinutes, minutesFromMidnight);
  }
}

final dailySummaryTimeProvider =
    StateNotifierProvider<DailySummaryTimeNotifier, int>((ref) {
  return DailySummaryTimeNotifier(ref.watch(sharedPreferencesProvider));
});

// --- Защита от выгорания ---

/// Сколько минут после прошлой сессии считаются «ты только что закончил».
/// 0 — предупреждение выключено.
class ShortBreakMinutesNotifier extends StateNotifier<int> {
  ShortBreakMinutesNotifier(this._prefs)
      : super(_prefs.getInt(PrefKeys.shortBreakMinutes) ??
            SessionGuards.defaultShortBreakMinutes);

  final SharedPreferences _prefs;

  Future<void> set(int minutes) async {
    state = minutes;
    await _prefs.setInt(PrefKeys.shortBreakMinutes, minutes);
  }
}

final shortBreakMinutesProvider =
    StateNotifierProvider<ShortBreakMinutesNotifier, int>((ref) {
  return ShortBreakMinutesNotifier(ref.watch(sharedPreferencesProvider));
});

class NightCapEnabledNotifier extends StateNotifier<bool> {
  NightCapEnabledNotifier(this._prefs)
      : super(_prefs.getBool(PrefKeys.nightCapEnabled) ?? true);

  final SharedPreferences _prefs;

  Future<void> set(bool value) async {
    state = value;
    await _prefs.setBool(PrefKeys.nightCapEnabled, value);
  }
}

final nightCapEnabledProvider =
    StateNotifierProvider<NightCapEnabledNotifier, bool>((ref) {
  return NightCapEnabledNotifier(ref.watch(sharedPreferencesProvider));
});

/// С какого часа предложения укорачиваются. Хранится часом, а не минутами:
/// «полночь с четвертью» тут ничего не уточняет.
class NightCapHourNotifier extends StateNotifier<int> {
  NightCapHourNotifier(this._prefs)
      : super(_prefs.getInt(PrefKeys.nightCapHour) ??
            SessionGuards.defaultNightCapHour);

  final SharedPreferences _prefs;

  Future<void> set(int hour) async {
    state = hour;
    await _prefs.setInt(PrefKeys.nightCapHour, hour);
  }
}

final nightCapHourProvider =
    StateNotifierProvider<NightCapHourNotifier, int>((ref) {
  return NightCapHourNotifier(ref.watch(sharedPreferencesProvider));
});

// --- Онбординг ---

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._prefs)
      : super(_prefs.getBool(PrefKeys.onboardingDone) ?? false);

  final SharedPreferences _prefs;

  Future<void> complete() async {
    state = true;
    await _prefs.setBool(PrefKeys.onboardingDone, true);
  }
}

final onboardingDoneProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier(ref.watch(sharedPreferencesProvider));
});
