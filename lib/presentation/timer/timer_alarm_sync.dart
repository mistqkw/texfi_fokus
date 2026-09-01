import '../../core/notifications/notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../shared/notification_sync.dart';
import 'timer_providers.dart';

/// Приводит системную очередь уведомлений в соответствие с состоянием
/// таймера. Пустой график (пауза, завершение) означает «снять всё».
///
/// Общая для экрана таймера и экрана боя: конец сессии должна знать система,
/// а не только живой Dart-таймер, — и это верно независимо от того, с какого
/// экрана сессию ведут. Приложение можно свернуть, выгрузить из памяти и
/// заблокировать экран, и с игровым слоем это не должно ломаться.
Future<void> syncTimerAlarms({
  required NotificationService notifications,
  required AppLocalizations l10n,
  required TimerState state,
  required TimerAlarmSignal signal,
}) async {
  final alarms = state.alarms;

  if (alarms.isEmpty) {
    await notifications.cancelTimerAlarms();
    return;
  }

  await notifications.scheduleTimerAlarms(
    alarms: alarms,
    totalCycles: state.plan.cycles,
    focusMinutes: state.plan.focusMinutes * state.plan.cycles,
    copy: timerNotificationCopyFrom(l10n),
    signal: signal,
  );
}
