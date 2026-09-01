import '../../core/audio/alarm_sound.dart';
import '../../l10n/app_localizations.dart';

/// Человеческое имя пресета сигнала.
///
/// Отдельно от [AlarmSound] намеренно: перечисление живёт в `core` и про
/// локализацию знать не должно, а имена всё равно переводятся на все четыре
/// языка. Switch без `default` — чтобы добавленный пресет не проскочил в
/// интерфейс безымянным: анализатор потребует ветку.
String alarmSoundLabel(AppLocalizations l10n, AlarmSound sound) {
  return switch (sound) {
    AlarmSound.arcadeCoin => l10n.soundArcadeCoin,
    AlarmSound.levelUp => l10n.soundLevelUp,
    AlarmSound.alarmBeep => l10n.soundAlarmBeep,
    AlarmSound.softChime => l10n.soundSoftChime,
    AlarmSound.powerDown => l10n.soundPowerDown,
  };
}
