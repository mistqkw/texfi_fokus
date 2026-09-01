import 'custom_preset.dart';
import 'focus_technique.dart';

/// Один вариант, между которыми выбирает движок: встроенная техника либо
/// пользовательский пресет.
///
/// Нужен потому, что [FocusTechnique] — перечисление, а пресеты пользователь
/// заводит в рантайме. Бандиту при этом всё равно, откуда взялась рука: ему
/// нужен стабильный строковый ключ и три числа. Этот класс и есть та самая
/// общая форма, к которой сводятся оба случая, — без него пришлось бы либо
/// раздувать enum, либо вести две параллельные ветки выбора.
class TechniqueArm {
  const TechniqueArm._({
    required this.key,
    required this.focusMinutes,
    required this.breakMinutes,
    required this.cycles,
    required this.technique,
    this.preset,
  });

  /// Встроенная техника.
  factory TechniqueArm.builtIn(FocusTechnique technique) => TechniqueArm._(
        key: technique.key,
        focusMinutes: technique.focusMinutes,
        breakMinutes: technique.breakMinutes,
        cycles: technique.cycles,
        technique: technique,
      );

  /// Пользовательский пресет.
  ///
  /// [technique] здесь — не «настоящая» техника, а ближайшая встроенная: она
  /// нужна только тем местам, которые исторически умеют работать лишь с
  /// перечислением (иконки, старые инсайты). Ни на выбор, ни на статистику
  /// она не влияет — там всё держится на [key].
  factory TechniqueArm.custom(CustomPreset preset) => TechniqueArm._(
        key: preset.key,
        focusMinutes: preset.focusMinutes,
        breakMinutes: preset.breakMinutes,
        cycles: preset.cycles,
        technique: nearestBuiltIn(preset.focusMinutes),
        preset: preset,
      );

  /// Стабильный ключ для таблицы весов и колонки `sessions.technique`.
  final String key;

  final int focusMinutes;
  final int breakMinutes;
  final int cycles;

  /// Встроенная техника — сама рука либо ближайшая к пресету.
  final FocusTechnique technique;

  /// Заполнен только у пользовательских пресетов.
  final CustomPreset? preset;

  bool get isCustom => preset != null;

  int get totalMinutes =>
      focusMinutes * cycles + breakMinutes * (cycles - 1).clamp(0, cycles);

  /// Ближайшая по длине непрерывного блока встроенная техника. Используется
  /// как «подложка» для пресета там, где нужен именно enum.
  static FocusTechnique nearestBuiltIn(int focusMinutes) {
    var best = FocusTechnique.pomodoro2505;
    var bestDelta = (best.focusMinutes - focusMinutes).abs();
    for (final t in FocusTechnique.values) {
      final delta = (t.focusMinutes - focusMinutes).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        best = t;
      }
    }
    return best;
  }

  /// Полный набор рук: сначала встроенные (порядок стабильный), затем
  /// пользовательские в порядке добавления.
  static List<TechniqueArm> all(List<CustomPreset> presets) => [
        for (final t in FocusTechnique.values) TechniqueArm.builtIn(t),
        for (final p in presets) TechniqueArm.custom(p),
      ];

  /// Восстанавливает руку по ключу. Пресет ищется среди [presets]; если он
  /// удалён, откатываемся на ближайшую встроенную технику — история сессии
  /// не должна ломаться из-за того, что пользователь убрал пресет.
  static TechniqueArm fromKey(String key, List<CustomPreset> presets) {
    final id = CustomPreset.idFromKey(key);
    if (id != null) {
      for (final preset in presets) {
        if (preset.id == id) return TechniqueArm.custom(preset);
      }
      return TechniqueArm.builtIn(FocusTechnique.pomodoro2505);
    }
    return TechniqueArm.builtIn(FocusTechnique.fromKey(key));
  }

  @override
  bool operator ==(Object other) => other is TechniqueArm && other.key == key;

  @override
  int get hashCode => key.hashCode;
}
