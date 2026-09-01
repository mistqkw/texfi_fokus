import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Пресеты звука окончания сессии.
///
/// Файлы лежат в `assets/audio/` и сгенерированы скриптом
/// `tool/generate_sounds.py` — это синтезированные квадратной и треугольной
/// волной короткие сигналы, а не чужие семплы: и права чистые, и звучание
/// попадает в пиксельную подачу остального приложения.
enum AlarmSound {
  arcadeCoin('arcade_coin', 'arcade_coin.mp3'),
  levelUp('level_up', 'level_up.mp3'),
  alarmBeep('alarm_beep', 'alarm_beep.mp3'),
  softChime('soft_chime', 'soft_chime.mp3'),
  powerDown('power_down', 'power_down.mp3');

  const AlarmSound(this.id, this.fileName);

  /// Устойчивый ключ для SharedPreferences. Порядок значений в перечислении
  /// менять можно, а эти строки — нет: по ним восстанавливается выбор.
  final String id;

  final String fileName;

  /// Путь так, как его ждёт audioplayers: `AssetSource` сам подставляет
  /// префикс `assets/`.
  String get assetPath => 'audio/$fileName';

  static const AlarmSound fallback = AlarmSound.arcadeCoin;

  /// Разбор сохранённого значения. Неизвестный или отсутствующий ключ — не
  /// повод остаться без звука вовсе.
  static AlarmSound fromId(String? id) {
    for (final sound in values) {
      if (sound.id == id) return sound;
    }
    return fallback;
  }
}

/// Конфигурация аудиосессии для сигнала окончания сессии.
///
/// Здесь весь смысл починки «на беззвучном режиме нет звука». Обычное
/// системное уведомление и `SystemSound.play` звучат через поток уведомлений,
/// а его глушит физический переключатель бесшумного режима — так устроены и
/// Android, и iOS, и подобрать сигнал погромче тут не помогает.
///
/// Поэтому звук идёт мимо этого потока:
///  * Android — `usageType: alarm`, то есть поток будильника. Бесшумный режим
///    его не выключает и большинство конфигураций «Не беспокоить» тоже: иначе
///    обычный будильник не будил бы. `contentType: sonification` честно
///    описывает короткий сигнал, а не музыку;
///  * iOS — категория `playback`, единственная, которая играет при опущенном
///    боковом переключателе (`ambient` и звук уведомления — нет).
///
/// Функция чистая и от плагина не зависит: её можно проверить тестом, не имея
/// ни звуковой карты, ни устройства.
AudioContext alarmAudioContext() {
  return AudioContext(
    android: const AudioContextAndroid(
      isSpeakerphoneOn: false,
      // Wake lock не берём: клип короче секунды, а Android и так доигрывает
      // его с погашенным экраном. Иначе пришлось бы просить WAKE_LOCK,
      // которого в манифесте нет, — лишнее разрешение ради ничего.
      stayAwake: false,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.alarm,
      // Короткий сигнал: чужую музыку глушим на время и возвращаем обратно.
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      // Приглушаем чужое звучание на время сигнала, а не обрываем его:
      // сессия закончилась — это не повод останавливать подкаст.
      options: const {AVAudioSessionOptions.duckOthers},
    ),
  );
}

/// Проигрывает выбранный сигнал окончания сессии.
///
/// Живёт рядом с уведомлением и вибрацией, а не вместо них: уведомление
/// нужно, когда приложение выгружено, вибрация — когда телефон в кармане, а
/// этот звук — единственное, что слышно на беззвучном режиме.
class AlarmSoundPlayer {
  AlarmSoundPlayer({AudioPlayer? player})
      : _player = player ?? AudioPlayer(playerId: 'texfi_alarm');

  final AudioPlayer _player;
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _player.setAudioContext(alarmAudioContext());
    await _player.setReleaseMode(ReleaseMode.stop);
    _configured = true;
  }

  /// Играет сигнал. Ошибки проглатываются намеренно: на десктопе без
  /// звукового бэкенда или при занятом устройстве упасть посреди завершения
  /// сессии — куда хуже, чем остаться без звука. Вибрация и уведомление
  /// сработают независимо.
  Future<void> play(AlarmSound sound) async {
    try {
      await _ensureConfigured();
      await _player.stop();
      await _player.setVolume(1);
      await _player.play(AssetSource(sound.assetPath));
    } catch (error, stackTrace) {
      debugPrint('AlarmSoundPlayer: не удалось проиграть ${sound.id}: $error');
      assert(() {
        debugPrintStack(stackTrace: stackTrace);
        return true;
      }());
    }
  }

  /// Прослушивание в настройках — тот же путь, что и у боевого сигнала.
  /// Слушать пресет через другой поток было бы нечестно: человек выбирает
  /// именно то, что услышит в конце сессии.
  Future<void> preview(AlarmSound sound) => play(sound);

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {
      // Останавливать нечего — и хорошо.
    }
  }

  void dispose() {
    _player.dispose();
  }
}
