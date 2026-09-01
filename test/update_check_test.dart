import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/core/constants/app_info.dart';
import 'package:texfi_fokus/core/update/app_release.dart';
import 'package:texfi_fokus/core/update/update_cache.dart';
import 'package:texfi_fokus/core/update/update_service.dart';

void main() {
  group('сравнение версий', () {
    test('префикс v в теге не мешает сравнению', () {
      expect(normalizeVersion('v1.2.1'), '1.2.1');
      expect(normalizeVersion('  V1.2.1 '), '1.2.1');
      expect(normalizeVersion('1.2.1'), '1.2.1');
    });

    test('новее только то, что действительно новее', () {
      expect(isNewerVersion('1.2.1', '1.2.0'), isTrue);
      expect(isNewerVersion('v1.3.0', '1.2.9'), isTrue);
      expect(isNewerVersion('2.0.0', '1.9.9'), isTrue);
      expect(isNewerVersion('1.2.0', '1.2.0'), isFalse);
      expect(isNewerVersion('v1.2.0', '1.2.0'), isFalse);
      // Откат релиза не должен предлагать «обновиться» назад.
      expect(isNewerVersion('1.1.9', '1.2.0'), isFalse);
    });

    test('разное число частей и десятичные разряды', () {
      // '1.10.0' новее '1.9.0': сравниваем числами, а не строками.
      expect(isNewerVersion('1.10.0', '1.9.0'), isTrue);
      expect(isNewerVersion('1.2', '1.2.0'), isFalse);
      expect(isNewerVersion('1.2.1', '1.2'), isTrue);
    });

    test('build-метаданные в сравнении не участвуют', () {
      expect(isNewerVersion('1.2.0+7', '1.2.0+5'), isFalse);
      expect(isNewerVersion('1.2.1+1', '1.2.0+9'), isTrue);
    });

    test('мусор вместо версии не роняет сравнение', () {
      expect(() => compareVersions('', 'вообще не версия'), returnsNormally);
      expect(isNewerVersion('', AppInfo.version), isFalse);
    });
  });

  group('разбор ответа GitHub', () {
    Map<String, Object?> release({
      String tag = 'v1.2.1',
      List<Object?>? assets,
      bool draft = false,
      bool prerelease = false,
      String body = 'Что нового',
    }) {
      return {
        'tag_name': tag,
        'draft': draft,
        'prerelease': prerelease,
        'body': body,
        'assets': assets ??
            [
              {
                'name': 'texfi_fokus-1.2.1.apk',
                'browser_download_url': 'https://example.test/app.apk',
                'size': 4242,
              },
            ],
      };
    }

    test('находит .apk среди нескольких ассетов', () {
      final parsed = AppRelease.fromJson(release(assets: [
        {
          'name': 'SHA256SUMS.txt',
          'browser_download_url': 'https://example.test/sums.txt',
          'size': 100,
        },
        {
          'name': 'texfi_fokus-1.2.1.apk',
          'browser_download_url': 'https://example.test/app.apk',
          'size': 4242,
        },
        {
          'name': 'texfi_fokus-linux.tar.gz',
          'browser_download_url': 'https://example.test/linux.tar.gz',
          'size': 900,
        },
      ]))!;

      expect(parsed.version, '1.2.1');
      expect(parsed.apkUrl, 'https://example.test/app.apk');
      expect(parsed.apkSizeBytes, 4242);
      expect(parsed.hasApk, isTrue);
    });

    test('расширение узнаётся независимо от регистра', () {
      final parsed = AppRelease.fromJson(release(assets: [
        {
          'name': 'TexFi_f0kus.APK',
          'browser_download_url': 'https://example.test/upper.apk',
        },
      ]))!;
      expect(parsed.apkUrl, 'https://example.test/upper.apk');
    });

    test('релиз без .apk разбирается, но качать нечего', () {
      final parsed = AppRelease.fromJson(release(assets: []))!;
      expect(parsed.hasApk, isFalse);
      expect(parsed.apkUrl, isNull);
    });

    test('черновики и предрелизы игнорируются', () {
      expect(AppRelease.fromJson(release(draft: true)), isNull);
      expect(AppRelease.fromJson(release(prerelease: true)), isNull);
    });

    test('ответ об ошибке и мусор не разбираются', () {
      expect(AppRelease.fromJson({'message': 'Not Found'}), isNull);
      expect(AppRelease.fromJson(release(tag: '   ')), isNull);
      expect(AppRelease.fromJson('строка'), isNull);
      expect(AppRelease.fromJson(null), isNull);
    });

    test('переживает круг через кэш без потерь', () {
      final parsed = AppRelease.fromJson(release())!;
      final restored =
          AppRelease.fromCacheJson(jsonDecode(jsonEncode(parsed.toJson())))!;
      expect(restored.tagName, parsed.tagName);
      expect(restored.version, parsed.version);
      expect(restored.apkUrl, parsed.apkUrl);
      expect(restored.notes, parsed.notes);
    });
  });

  group('release notes в plain text', () {
    test('снимает заголовки, маркеры и разметку', () {
      const body = '## Что нового\n\n'
          '- **Проверка обновлений** прямо в приложении\n'
          '- Звук окончания сессии в `фоне`\n';
      final preview = notesPreview(body);
      expect(preview, contains('Что нового'));
      expect(preview, contains('• Проверка обновлений прямо в приложении'));
      expect(preview, isNot(contains('#')));
      expect(preview, isNot(contains('**')));
      expect(preview, isNot(contains('`')));
    });

    test('обрезает по числу строк и по длине', () {
      final many = List.generate(20, (i) => 'строка $i').join('\n');
      expect(notesPreview(many, maxLines: 3).split('\n'), hasLength(3));

      final long = 'a' * 500;
      final preview = notesPreview(long, maxChars: 50);
      expect(preview.length, lessThanOrEqualTo(51));
      expect(preview, endsWith('…'));
    });

    test('пустое тело даёт пустой текст, а не мусор', () {
      expect(notesPreview(''), isEmpty);
      expect(notesPreview('\n\n---\n\n'), isEmpty);
    });
  });

  group('троттлинг проверок', () {
    final now = DateTime(2026, 9, 1, 12);

    test('первая проверка идёт всегда', () {
      expect(shouldCheckNow(last: null, now: now), isTrue);
    });

    test('свежая успешная проверка в сеть не ходит', () {
      final last = UpdateCheckState(
        checkedAt: now.subtract(const Duration(hours: 1)),
        succeeded: true,
      );
      expect(shouldCheckNow(last: last, now: now), isFalse);
    });

    test('успешная проверка протухает через шесть часов', () {
      final stale = UpdateCheckState(
        checkedAt: now.subtract(UpdateCheckPolicy.successTtl),
        succeeded: true,
      );
      expect(shouldCheckNow(last: stale, now: now), isTrue);
    });

    test('после неудачи ждём меньше, но всё-таки ждём', () {
      final justFailed = UpdateCheckState(
        checkedAt: now.subtract(const Duration(minutes: 5)),
        succeeded: false,
      );
      // Главное: неудача тоже кэшируется, иначе каждый запуск бил бы по
      // лимиту GitHub и держал его исчерпанным.
      expect(shouldCheckNow(last: justFailed, now: now), isFalse);

      final backedOff = UpdateCheckState(
        checkedAt: now.subtract(UpdateCheckPolicy.failureBackoff),
        succeeded: false,
      );
      expect(shouldCheckNow(last: backedOff, now: now), isTrue);
    });

    test('кнопка в настройках игнорирует кэш', () {
      final fresh = UpdateCheckState(checkedAt: now, succeeded: true);
      expect(shouldCheckNow(last: fresh, now: now, force: true), isTrue);
    });

    test('время, уехавшее в будущее, не блокирует проверку навсегда', () {
      final future = UpdateCheckState(
        checkedAt: now.add(const Duration(days: 30)),
        succeeded: true,
      );
      expect(shouldCheckNow(last: future, now: now), isTrue);
    });
  });

  group('источник обновлений', () {
    test('адрес API — публичный latest-релиз этого репозитория', () {
      expect(
        UpdateSource.latestRelease.toString(),
        'https://api.github.com/repos/mistqkw/texfi_fokus/releases/latest',
      );
    });

    test('GitHub требует User-Agent — без него будет 403', () {
      expect(UpdateSource.headers['User-Agent'], isNotEmpty);
    });
  });

  test('AppInfo.version не разъезжается с pubspec.yaml', () {
    // Версия приложения берётся из константы, а не из package_info_plus.
    // Единственный риск такого решения — забыть её при выпуске; этот тест
    // ровно его и снимает.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match =
        RegExp(r'^version:\s*([0-9.]+)', multiLine: true).firstMatch(pubspec);
    expect(match, isNotNull, reason: 'в pubspec.yaml нет строки version');
    expect(match!.group(1), AppInfo.version);
  });
}
