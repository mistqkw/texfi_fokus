import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/core/notifications/focus_mode.dart';

/// Тишина на время сессии.
///
/// Проверяется дартовая половина: что вызовы уходят в канал под теми
/// именами, которые слушает нативная сторона, и что отсутствие этой стороны
/// не роняет ничего. Сам «Не беспокоить» живёт в Kotlin и здесь недоступен —
/// но именно поэтому важно, чтобы приложение переживало его отсутствие:
/// сборка под десктоп собирается из того же кода.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(FocusMode.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final calls = <String>[];

  void answerWith(Object? Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return handler(call);
    });
  }

  setUp(calls.clear);
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('на платформе без такого режима', () {
    const mode = FocusMode(supportedOverride: false);

    test('настройка не предлагается', () {
      expect(mode.isSupported, isFalse);
    });

    test('вызовы не уходят в канал и не бросают', () async {
      answerWith((_) => true);

      expect(await mode.isGranted(), isFalse);
      expect(await mode.enable(), isFalse);
      expect(await mode.disable(), isFalse);
      await mode.restoreAfterCrash();

      expect(calls, isEmpty);
    });
  });

  group('на поддерживаемой платформе', () {
    const mode = FocusMode(supportedOverride: true);

    test('каждый вызов уходит под своим именем', () async {
      answerWith((_) => true);

      expect(await mode.isGranted(), isTrue);
      expect(await mode.enable(), isTrue);
      expect(await mode.disable(), isTrue);
      expect(await mode.openAccessSettings(), isTrue);
      await mode.restoreAfterCrash();

      expect(calls, [
        'isGranted',
        'enable',
        'disable',
        'openAccessSettings',
        'restore',
      ]);
    });

    test('отказ нативной стороны отдаётся как есть, а не как успех', () async {
      answerWith((_) => false);

      expect(await mode.enable(), isFalse);
      expect(await mode.isGranted(), isFalse);
    });

    test('ошибка платформы не роняет, а читается как «не вышло»', () async {
      answerWith((_) => throw PlatformException(code: 'SECURITY'));

      expect(await mode.enable(), isFalse);
      expect(await mode.disable(), isFalse);
    });

    test('нативной стороны нет вовсе — тоже не роняет', () async {
      // Ровно то, что происходит в сборке без нативной части: канал есть,
      // слушателя нет. Тишина — удобство, а не условие работы таймера.
      messenger.setMockMethodCallHandler(channel, null);

      expect(await mode.enable(), isFalse);
      expect(await mode.isGranted(), isFalse);
      await mode.restoreAfterCrash();
    });

    test('null от канала не превращается в «получилось»', () async {
      answerWith((_) => null);

      expect(await mode.enable(), isFalse);
      expect(await mode.disable(), isFalse);
    });
  });
}
