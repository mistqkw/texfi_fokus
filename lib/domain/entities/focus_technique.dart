/// Набор техник, между которыми выбирает движок рекомендаций.
///
/// Набор фиксированный и небольшой — это руки бандита. Добавление новой
/// техники безопасно: у неё просто не будет накопленной статистики, и на
/// первых порах она будет выбираться как неисследованная.
enum FocusTechnique {
  sprint15(focusMinutes: 15, breakMinutes: 5, cycles: 2),
  pomodoro2505(focusMinutes: 25, breakMinutes: 5, cycles: 4),
  pomodoro5010(focusMinutes: 50, breakMinutes: 10, cycles: 2),
  deepWork90(focusMinutes: 90, breakMinutes: 15, cycles: 1);

  const FocusTechnique({
    required this.focusMinutes,
    required this.breakMinutes,
    required this.cycles,
  });

  final int focusMinutes;
  final int breakMinutes;
  final int cycles;

  /// Полная длительность плана в минутах — перерывы между циклами входят,
  /// перерыв после последнего цикла не считаем.
  int get totalMinutes =>
      focusMinutes * cycles + breakMinutes * (cycles - 1).clamp(0, cycles);

  /// Стабильный строковый ключ для БД. Именно он, а не `index`, пишется в
  /// `recommendation_weights`, чтобы порядок значений можно было менять.
  String get key => name;

  static FocusTechnique fromKey(String key) => FocusTechnique.values.firstWhere(
        (t) => t.name == key,
        orElse: () => FocusTechnique.pomodoro2505,
      );
}
