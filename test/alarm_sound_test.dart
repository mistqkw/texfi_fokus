import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:texfi_fokus/core/audio/alarm_sound.dart';
import 'package:texfi_fokus/presentation/settings/settings_providers.dart';

/// Про звук окончания сессии проверяемо ровно две вещи без железа:
/// с какими параметрами уходит запрос в аудиосессию и переживает ли выбор
/// перезапуск. Слышно ли это на беззвучном телефоне — вопрос к живому
/// устройству, не к тесту.
void main() {
  group('конфигурация аудиосессии', () {
    test('Android играет через поток будильника, а не уведомлений', () {
      final context = alarmAudioContext();

      // Именно это и чинит «на беззвучном нет звука»: поток уведомлений
      // глушится переключателем, поток будильника — нет.
      expect(context.android.usageType, AndroidUsageType.alarm);
      expect(context.android.contentType, AndroidContentType.sonification);
    });

    test('iOS использует категорию playback', () {
      final context = alarmAudioContext();

      // `playback` звучит при опущенном боковом переключателе; `ambient` и
      // звук уведомления — нет.
      expect(context.iOS.category, AVAudioSessionCategory.playback);
    });

    test('чужой звук приглушается, а не обрывается', () {
      final context = alarmAudioContext();

      expect(
        context.android.audioFocus,
        AndroidAudioFocus.gainTransientMayDuck,
      );
      expect(context.iOS.options, contains(AVAudioSessionOptions.duckOthers));
    });

    test('wake lock не запрашивается: его нет в манифесте', () {
      expect(alarmAudioContext().android.stayAwake, isFalse);
    });
  });

  group('пресеты', () {
    test('у каждого свой файл и свой ключ', () {
      final ids = AlarmSound.values.map((s) => s.id).toSet();
      final files = AlarmSound.values.map((s) => s.fileName).toSet();

      expect(ids.length, AlarmSound.values.length);
      expect(files.length, AlarmSound.values.length);
    });

    test('путь собирается так, как ждёт AssetSource', () {
      expect(AlarmSound.levelUp.assetPath, 'audio/level_up.mp3');
    });

    test('неизвестный или пустой ключ откатывается к запасному', () {
      expect(AlarmSound.fromId(null), AlarmSound.fallback);
      expect(AlarmSound.fromId(''), AlarmSound.fallback);
      // Например, пресет удалили из сборки, а выбор в настройках остался.
      expect(AlarmSound.fromId('trombone'), AlarmSound.fallback);
    });

    test('сохранённый ключ читается обратно', () {
      for (final sound in AlarmSound.values) {
        expect(AlarmSound.fromId(sound.id), sound);
      }
    });
  });

  group('сохранение выбора', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('по умолчанию — запасной пресет', () async {
      final prefs = await SharedPreferences.getInstance();
      expect(AlarmSoundNotifier(prefs).state, AlarmSound.fallback);
    });

    test('выбор переживает перезапуск', () async {
      final prefs = await SharedPreferences.getInstance();
      await AlarmSoundNotifier(prefs).set(AlarmSound.softChime);

      // Новый запуск читает те же SharedPreferences.
      expect(AlarmSoundNotifier(prefs).state, AlarmSound.softChime);
      expect(prefs.getString(PrefKeys.alarmSound), 'soft_chime');
    });

    test('мусор в настройках не оставляет пользователя без звука', () async {
      SharedPreferences.setMockInitialValues({
        PrefKeys.alarmSound: 'сгинувший_пресет',
      });
      final prefs = await SharedPreferences.getInstance();

      expect(AlarmSoundNotifier(prefs).state, AlarmSound.fallback);
    });
  });
}
