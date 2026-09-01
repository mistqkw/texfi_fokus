import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/custom_preset.dart';
import '../providers/data_providers.dart';

/// Хранилище пользовательских пресетов длительностей.
///
/// Живёт в `data/`, а не рядом с остальными настройками в `presentation/`,
/// по одной причине: пресеты нужны движку рекомендаций, а движок собирается
/// в `data_providers`. Обратная зависимость (data → presentation) замкнула бы
/// импорты в кольцо.
///
/// Формат — JSON-список в одном ключе SharedPreferences. Отдельная таблица
/// Drift ради пяти строк потребовала бы миграции схемы и второго механизма
/// хранения настроек там, где уже есть работающий первый.
class CustomPresetsNotifier extends StateNotifier<List<CustomPreset>> {
  CustomPresetsNotifier(this._prefs) : super(_read(_prefs));

  static const String prefsKey = 'custom_presets';

  final SharedPreferences _prefs;

  /// Разбор намеренно снисходительный: одна испорченная запись не должна
  /// уносить с собой остальные пресеты пользователя.
  static List<CustomPreset> _read(SharedPreferences prefs) {
    final raw = prefs.getString(prefsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded) ?CustomPreset.tryFromJson(item),
      ].take(CustomPreset.maxPresets).toList();
    } on FormatException {
      return const [];
    }
  }

  Future<void> _persist(List<CustomPreset> next) async {
    state = next;
    await _prefs.setString(
      prefsKey,
      jsonEncode([for (final p in next) p.toJson()]),
    );
  }

  /// Возвращает false, если лимит уже выбран, — экран покажет об этом
  /// сообщение вместо молчаливого игнорирования нажатия.
  Future<bool> add(CustomPreset preset) async {
    if (state.length >= CustomPreset.maxPresets) return false;
    await _persist([...state, preset.normalized()]);
    return true;
  }

  Future<void> update(CustomPreset preset) async {
    final normalized = preset.normalized();
    await _persist([
      for (final p in state)
        if (p.id == normalized.id) normalized else p,
    ]);
  }

  /// Удаляет пресет. Накопленные им веса в базе намеренно НЕ трогаем: если
  /// пользователь заведёт пресет с тем же id обратно, статистика вернётся к
  /// нему, а чужой она стать не может — ключ `custom:<id>` уникален.
  Future<void> remove(String id) async {
    await _persist([
      for (final p in state)
        if (p.id != id) p,
    ]);
  }

  /// id на основе времени: пресеты заводятся руками и по одному, коллизия
  /// потребовала бы двух нажатий в одну миллисекунду.
  static String newId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}

final customPresetsProvider =
    StateNotifierProvider<CustomPresetsNotifier, List<CustomPreset>>((ref) {
  return CustomPresetsNotifier(ref.watch(sharedPreferencesProvider));
});
