import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'app_release.dart';

/// Откуда берутся обновления.
///
/// Приложение раздаётся `.apk` через GitHub Releases (тот же артефакт, что
/// собирает CI по тегу `v*.*.*`), магазина у него нет. Значит, и проверять
/// новую версию больше негде.
abstract final class UpdateSource {
  static const String owner = 'mistqkw';
  static const String repo = 'texfi_fokus';

  /// Публичный REST-эндпоинт последнего релиза. Без токена: репозиторий
  /// открытый, а класть ключ в клиент, который раздают всем, — бессмысленно.
  static Uri get latestRelease =>
      Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest');

  /// GitHub просит явный User-Agent и версию API — без первого он отвечает
  /// 403 даже на публичные данные.
  static const Map<String, String> headers = {
    'Accept': 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
    'User-Agent': 'texfi_fokus-updater',
  };
}

/// Обновление умеет только Android.
///
/// На iOS самоустановка запрещена в принципе, а десктопные сборки (Linux,
/// Windows, macOS) собираются отдельными артефактами и `.apk` им не нужен.
/// Показать им кнопку «скачать и установить» — значит показать кнопку,
/// которая гарантированно ничего не сделает.
bool get updatesSupported => !kIsWeb && Platform.isAndroid;

/// Проверка версии и установка `.apk` из GitHub Releases.
class UpdateService {
  UpdateService({http.Client? client, Duration? timeout})
      : _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 10);

  final http.Client _client;
  final Duration _timeout;

  /// Запрашивает последний релиз.
  ///
  /// Возвращает `null` на любом отказе: нет сети, GitHub ответил 403 из-за
  /// лимита, пришёл не тот JSON. Наружу техническая причина не уходит —
  /// человек, открывший настройки, не должен читать про rate limit.
  Future<AppRelease?> fetchLatest() async {
    try {
      final response = await _client
          .get(UpdateSource.latestRelease, headers: UpdateSource.headers)
          .timeout(_timeout);
      if (response.statusCode != 200) {
        debugPrint('UpdateService: GitHub ответил ${response.statusCode}');
        return null;
      }
      return AppRelease.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } catch (error) {
      debugPrint('UpdateService.fetchLatest failed: $error');
      return null;
    }
  }

  /// Качает `.apk` во временную директорию, отдавая прогресс `0..1`.
  ///
  /// Стрим, а не `http.get`: пакет весит десятки мегабайт, и держать его
  /// целиком в памяти, не показывая прогресс, — верный способ получить
  /// «приложение зависло».
  Future<File?> downloadApk(
    AppRelease release, {
    void Function(double progress)? onProgress,
  }) async {
    final url = release.apkUrl;
    if (url == null) return null;
    try {
      final request = http.Request('GET', Uri.parse(url))
        ..headers.addAll(UpdateSource.headers);
      final response = await _client.send(request).timeout(_timeout);
      if (response.statusCode != 200) {
        debugPrint('UpdateService: загрузка вернула ${response.statusCode}');
        return null;
      }

      final dir = await getTemporaryDirectory();
      // Имя с версией: рядом может лежать пакет от прошлой попытки, и
      // дописать новый в старый файл — гарантированный «повреждённый пакет».
      final file = File('${dir.path}/texfi_fokus_${release.version}.apk');
      if (await file.exists()) await file.delete();

      final total = response.contentLength ?? release.apkSizeBytes ?? 0;
      var received = 0;
      final sink = file.openWrite();
      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) onProgress?.call((received / total).clamp(0.0, 1.0));
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      onProgress?.call(1);
      return file;
    } catch (error) {
      debugPrint('UpdateService.downloadApk failed: $error');
      return null;
    }
  }

  /// Отдаёт скачанный пакет системному установщику.
  ///
  /// Прямой путь `file://` Android запрещает с версии 7, поэтому файл уходит
  /// через `FileProvider` — `open_filex` берёт объявленный в манифесте
  /// провайдер и сам собирает `content://`-URI и `ACTION_VIEW`.
  ///
  /// Дальше решает система: если «установка из этого источника» не
  /// разрешена, она сама покажет свой экран настроек. Обойти это приложение
  /// не может и не должно — поэтому перед вызовом человеку объясняют, что
  /// сейчас произойдёт.
  Future<bool> installApk(File file) async {
    try {
      final result = await OpenFilex.open(
        file.path,
        type: 'application/vnd.android.package-archive',
      );
      if (result.type != ResultType.done) {
        debugPrint('UpdateService: установщик не открылся: ${result.message}');
        return false;
      }
      return true;
    } catch (error) {
      debugPrint('UpdateService.installApk failed: $error');
      return false;
    }
  }

  void dispose() => _client.close();
}
