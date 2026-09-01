import 'focus_technique.dart';

/// Пресет длительностей, заведённый самим пользователем.
///
/// Встроенных техник четыре, и они покрывают большинство случаев, но не все:
/// кто-то работает 35/7, кто-то — 20/3 по медицинским причинам. Такой пресет
/// не «ещё одна кнопка в ручном таймере», а полноценная рука бандита: он
/// участвует в рекомендациях наравне со встроенными и копит собственную
/// статистику.
///
/// Хранится в SharedPreferences (JSON-список), а не в Drift: это настройка
/// того же рода, что ночной кап или язык, и заводить ради неё таблицу с
/// миграцией значило бы развести два хранилища настроек вместо одного.
class CustomPreset {
  const CustomPreset({
    required this.id,
    required this.name,
    required this.focusMinutes,
    required this.breakMinutes,
    required this.cycles,
  });

  /// Префикс ключа. Держит пользовательские пресеты в своём пространстве
  /// имён: `custom:` никогда не столкнётся с именем значения [FocusTechnique],
  /// а значит, накопленные веса встроенных техник не могут быть перезаписаны
  /// пресетом — и наоборот.
  static const String keyPrefix = 'custom:';

  /// Границы, внутри которых пресет вообще имеет смысл. Верхняя не про
  /// «нельзя», а про то, что таймер на восемь часов — это не техника фокуса,
  /// а забытое приложение.
  static const int minFocusMinutes = 1;
  static const int maxFocusMinutes = 240;
  static const int maxBreakMinutes = 60;
  static const int maxCycles = 12;

  /// Сколько пресетов разрешаем. Каждый — это ещё одна рука бандита, а руки
  /// делят между собой один и тот же поток сессий: с двадцатью вариантами
  /// движок не выучит ни одного.
  static const int maxPresets = 5;

  final String id;
  final String name;
  final int focusMinutes;
  final int breakMinutes;
  final int cycles;

  /// Стабильный ключ для БД и таблицы весов — тот же контракт, что у
  /// [FocusTechnique.key].
  String get key => '$keyPrefix$id';

  /// Считается ровно как у встроенных техник: перерыв после последнего цикла
  /// не входит.
  int get totalMinutes =>
      focusMinutes * cycles + breakMinutes * (cycles - 1).clamp(0, cycles);

  /// Ключ принадлежит пользовательскому пресету, а не встроенной технике.
  static bool isCustomKey(String key) => key.startsWith(keyPrefix);

  /// Достаёт id из ключа. null — ключ не пользовательский.
  static String? idFromKey(String key) =>
      isCustomKey(key) ? key.substring(keyPrefix.length) : null;

  CustomPreset copyWith({
    String? name,
    int? focusMinutes,
    int? breakMinutes,
    int? cycles,
  }) {
    return CustomPreset(
      id: id,
      name: name ?? this.name,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      cycles: cycles ?? this.cycles,
    );
  }

  /// Приводит значения к допустимому диапазону. Вызывается на входе, а не
  /// на чтении: испорченный руками JSON не должен уронить экран таймера.
  CustomPreset normalized() {
    return CustomPreset(
      id: id,
      name: name.trim(),
      focusMinutes: focusMinutes.clamp(minFocusMinutes, maxFocusMinutes),
      breakMinutes: breakMinutes.clamp(0, maxBreakMinutes),
      cycles: cycles.clamp(1, maxCycles),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'focusMinutes': focusMinutes,
        'breakMinutes': breakMinutes,
        'cycles': cycles,
      };

  /// null — запись не разобралась. Один битый пресет не повод терять
  /// остальные, поэтому разбор мягкий, а отбраковка — на вызывающем.
  static CustomPreset? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    final focus = raw['focusMinutes'];
    final rest = raw['breakMinutes'];
    final cycles = raw['cycles'];
    if (id is! String || id.isEmpty) return null;
    if (name is! String) return null;
    if (focus is! int || rest is! int || cycles is! int) return null;
    return CustomPreset(
      id: id,
      name: name,
      focusMinutes: focus,
      breakMinutes: rest,
      cycles: cycles,
    ).normalized();
  }

  @override
  bool operator ==(Object other) =>
      other is CustomPreset &&
      other.id == id &&
      other.name == name &&
      other.focusMinutes == focusMinutes &&
      other.breakMinutes == breakMinutes &&
      other.cycles == cycles;

  @override
  int get hashCode => Object.hash(id, name, focusMinutes, breakMinutes, cycles);
}
