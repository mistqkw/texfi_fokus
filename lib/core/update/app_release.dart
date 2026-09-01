/// Разбор ответа GitHub Releases и сравнение версий.
///
/// Всё, что здесь лежит, — чистые функции без сети и без плагинов: именно
/// они решают, показывать ли карточку обновления, и именно они ломались бы
/// молча, если бы жили внутри HTTP-клиента и проверялись только руками.
library;

/// Опубликованный релиз в том виде, в каком он нужен приложению.
class AppRelease {
  const AppRelease({
    required this.tagName,
    required this.version,
    required this.notes,
    required this.apkUrl,
    this.apkSizeBytes,
  });

  /// Тег как в API: `v1.2.1`.
  final String tagName;

  /// Тот же тег без префикса `v` — в этом виде он сравнивается с версией
  /// приложения и показывается человеку.
  final String version;

  /// Тело релиза (markdown) как есть. Обрезкой занимается [notesPreview].
  final String notes;

  /// Прямая ссылка на `.apk`. `null` — сборка ещё не доехала до релиза
  /// (CI мог упасть или ещё идти), и предлагать «скачать» нечего.
  final String? apkUrl;

  final int? apkSizeBytes;

  bool get hasApk => apkUrl != null;

  /// Разбор `GET /repos/:owner/:repo/releases/latest`.
  ///
  /// Возвращает `null` на всём, что не похоже на релиз: черновик, ответ об
  /// ошибке (`{"message": "Not Found"}`), пустой тег. Бросать исключение
  /// здесь нечего — вызывающий код и так обязан молча пережить любой отказ.
  static AppRelease? fromJson(Object? json) {
    if (json is! Map) return null;
    final tag = json['tag_name'];
    if (tag is! String || tag.trim().isEmpty) return null;
    // Черновики и предрелизы не предлагаем: их публикуют, чтобы посмотреть
    // самому, а не чтобы раздать всем.
    if (json['draft'] == true || json['prerelease'] == true) return null;

    final assets = json['assets'];
    String? apkUrl;
    int? apkSize;
    if (assets is List) {
      for (final asset in assets) {
        if (asset is! Map) continue;
        final name = asset['name'];
        final url = asset['browser_download_url'];
        if (name is! String || url is! String) continue;
        if (!name.toLowerCase().endsWith('.apk')) continue;
        apkUrl = url;
        final size = asset['size'];
        apkSize = size is int ? size : null;
        break;
      }
    }

    final body = json['body'];
    return AppRelease(
      tagName: tag.trim(),
      version: normalizeVersion(tag),
      notes: body is String ? body : '',
      apkUrl: apkUrl,
      apkSizeBytes: apkSize,
    );
  }

  Map<String, Object?> toJson() => {
        'tag_name': tagName,
        'body': notes,
        'apk_url': apkUrl,
        'apk_size': apkSizeBytes,
      };

  /// Восстановление из кэша. Формат — тот же [toJson], а не сырой ответ
  /// GitHub: хранить целиком ответ API ради четырёх полей незачем.
  static AppRelease? fromCacheJson(Object? json) {
    if (json is! Map) return null;
    final tag = json['tag_name'];
    if (tag is! String || tag.trim().isEmpty) return null;
    final url = json['apk_url'];
    final size = json['apk_size'];
    final body = json['body'];
    return AppRelease(
      tagName: tag.trim(),
      version: normalizeVersion(tag),
      notes: body is String ? body : '',
      apkUrl: url is String ? url : null,
      apkSizeBytes: size is int ? size : null,
    );
  }
}

/// Убирает у тега префикс `v` и обрамляющие пробелы: `v1.2.1` -> `1.2.1`.
String normalizeVersion(String raw) {
  var value = raw.trim();
  if (value.startsWith('v') || value.startsWith('V')) {
    value = value.substring(1);
  }
  return value.trim();
}

/// Сравнивает две версии по числовым частям: `<0`, если `a` старше `b`.
///
/// Намеренно нестрогий semver: теги в этом репозитории — `vX.Y.Z`, но
/// приложение не должно сломаться от `v1.2` или `1.2.1+5`. Всё, что после
/// `+` или `-`, отбрасывается: build-метаданные в semver не участвуют в
/// сравнении, а суффикс вроде `-rc1` до пользователей и так не доходит —
/// предрелизы отсеиваются раньше, в [AppRelease.fromJson].
int compareVersions(String a, String b) {
  final left = _parts(a);
  final right = _parts(b);
  final length = left.length > right.length ? left.length : right.length;
  for (var i = 0; i < length; i++) {
    final l = i < left.length ? left[i] : 0;
    final r = i < right.length ? right[i] : 0;
    if (l != r) return l < r ? -1 : 1;
  }
  return 0;
}

List<int> _parts(String version) {
  var value = normalizeVersion(version);
  for (final separator in ['+', '-', ' ']) {
    final cut = value.indexOf(separator);
    if (cut >= 0) value = value.substring(0, cut);
  }
  if (value.isEmpty) return const [0];
  return value
      .split('.')
      .map((part) => int.tryParse(part.trim()) ?? 0)
      .toList(growable: false);
}

/// Новее ли [releaseVersion], чем [currentVersion].
bool isNewerVersion(String releaseVersion, String currentVersion) =>
    compareVersions(currentVersion, releaseVersion) < 0;

/// Первые строки release notes в виде простого текста.
///
/// Markdown намеренно не рендерится: в карточке настроек нужен смысл, а не
/// вёрстка. Снимаются заголовки, маркеры списков и лишние пустые строки —
/// после этого текст читается как обычный абзац.
String notesPreview(
  String body, {
  int maxLines = 4,
  int maxChars = 240,
}) {
  final lines = <String>[];
  for (final raw in body.split('\n')) {
    var line = raw.trim();
    if (line.isEmpty) continue;
    // Горизонтальные линейки и служебные строки смысла не несут.
    if (RegExp(r'^[-*_=]{3,}$').hasMatch(line)) continue;
    line = line.replaceFirst(RegExp(r'^#{1,6}\s*'), '');
    line = line.replaceFirst(RegExp(r'^[-*+]\s+'), '• ');
    line = line.replaceFirst(RegExp(r'^\d+\.\s+'), '• ');
    // Жирный/курсив/код: звёздочки и обратные кавычки в plain text — мусор.
    line = line.replaceAll(RegExp(r'[*`]'), '').trim();
    if (line.isEmpty) continue;
    lines.add(line);
    if (lines.length >= maxLines) break;
  }

  final text = lines.join('\n');
  if (text.length <= maxChars) return text;
  return '${text.substring(0, maxChars).trimRight()}…';
}
