import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:texfi_fokus/core/audio/alarm_sound.dart';
import 'package:texfi_fokus/core/notifications/notification_service.dart';

/// Проверки вокруг починки «в фоне и при выключенном экране нет звука».
///
/// Суть починки: выбранный пресет должен доходить до канала уведомления, а не
/// только до плеера внутри приложения. Плеер живёт ровно столько, сколько
/// живёт изолят на переднем плане, — поэтому раньше при погашенном экране
/// звучать было нечему. Канал же принадлежит системе и играет сам.
void main() {
  group('канал под выбранный сигнал', () {
    test('у каждого пресета свой канал', () {
      final ids = <String>{};
      for (final sound in AlarmSound.values) {
        final signal = TimerAlarmSignal(sound: sound, vibrate: true);
        expect(ids.add(signal.channelId), isTrue,
            reason: 'каналы пресетов не должны совпадать: ${sound.id}');
      }
      expect(ids, hasLength(AlarmSound.values.length));
    });

    test('вибрация тоже разводит каналы', () {
      // И звук, и вибрация фиксируются при создании канала: если бы оба
      // сочетания делили один канал, выключение вибрации ни на что не влияло
      // бы до переустановки приложения.
      const withVibration =
          TimerAlarmSignal(sound: AlarmSound.arcadeCoin, vibrate: true);
      const without =
          TimerAlarmSignal(sound: AlarmSound.arcadeCoin, vibrate: false);
      expect(withVibration.channelId, isNot(without.channelId));
    });

    test('выключенный звук — отдельный канал, а не отсутствие канала', () {
      const silent = TimerAlarmSignal(sound: null, vibrate: true);
      expect(silent.channelId, contains('silent'));
      expect(silent.sound, isNull);
      for (final sound in AlarmSound.values) {
        expect(
          silent.channelId,
          isNot(TimerAlarmSignal(sound: sound, vibrate: true).channelId),
        );
      }
    });

    test('канал не совпадает с прежним, неисправимым', () {
      // Старый канал создавался со звуком уведомления и потоком notification.
      // Параметры канала на Android неизменяемы, поэтому переиспользовать его
      // нельзя ни при каких условиях — иначе починка не доедет до тех, у кого
      // приложение уже установлено.
      for (final sound in AlarmSound.values) {
        final id = TimerAlarmSignal(sound: sound, vibrate: true).channelId;
        expect(id, isNot('texfi_fokus_timer'));
      }
    });

    test('идентификатор канала годится в имя ресурса Android', () {
      for (final sound in AlarmSound.values) {
        final id = TimerAlarmSignal(sound: sound, vibrate: true).channelId;
        expect(RegExp(r'^[a-z0-9_]+$').hasMatch(id), isTrue, reason: id);
      }
    });
  });

  group('звуки как ресурсы Android', () {
    test('имя ресурса — без расширения и без запрещённых символов', () {
      for (final sound in AlarmSound.values) {
        expect(sound.androidResourceName, isNot(contains('.')));
        expect(
          RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(sound.androidResourceName),
          isTrue,
          reason: '${sound.id}: ${sound.androidResourceName}',
        );
      }
    });

    test('каждый пресет лежит в res/raw, а не только в assets', () {
      // Это и есть механизм починки: систему нельзя попросить взять звук из
      // flutter-ассетов — до них она не дотягивается. Если файл потеряется,
      // уведомление молча зазвучит дефолтным звуком, и заметить это можно
      // будет только на устройстве.
      for (final sound in AlarmSound.values) {
        final raw = File(
          'android/app/src/main/res/raw/${sound.androidResourceName}.mp3',
        );
        expect(raw.existsSync(), isTrue,
            reason: 'нет ресурса для ${sound.id}: ${raw.path}');
        expect(raw.lengthSync(), greaterThan(0));
      }
    });

    test('ресурс и ассет — один и тот же звук', () {
      for (final sound in AlarmSound.values) {
        final asset = File('assets/audio/${sound.fileName}');
        final raw = File(
          'android/app/src/main/res/raw/${sound.androidResourceName}.mp3',
        );
        expect(raw.readAsBytesSync(), asset.readAsBytesSync(),
            reason: 'копии ${sound.id} разъехались — перегенерируйте '
                'tool/generate_sounds.py');
      }
    });
  });
}
