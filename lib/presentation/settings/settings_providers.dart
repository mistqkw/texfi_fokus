import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/haptics/haptics.dart';
import '../../data/providers/data_providers.dart';

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
