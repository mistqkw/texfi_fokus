import '../../core/notifications/notification_service.dart';
import '../../core/utils/duration_format.dart';
import '../../l10n/app_localizations.dart';
import '../shared/notification_sync.dart';
import 'timer_providers.dart';

/// Держит постоянное уведомление о ходе сессии в согласии с таймером — то,
/// что видно на заблокированном экране, пока идёт фокус или перерыв.
///
/// Общий для обычного экрана таймера и экрана боя, по той же причине, что и
/// [syncTimerAlarms]: сессию можно вести с любого из них, и обновляться
/// уведомление обязано одинаково.
///
/// Обновление намеренно не на каждый тик секунды. `TimerState` пересчитывается
/// раз в секунду, пока таймер идёт, а системные уведомления на Android не
/// рассчитаны на такую частоту показа: обновление на каждую секунду и
/// расточительно по батарее, и рискует упереться в системные лимиты частоты.
/// Поэтому текст меняется только тогда, когда меняется то, что человек и так
/// увидит на заблокированном экране, — целая минута на табло, пауза/продолжение
/// или смена фазы, — а не на каждое малозаметное «59 → 58».
class OngoingSessionNotifier {
  OngoingSessionNotifier(this._notifications);

  final NotificationService _notifications;

  int? _shownMinute;
  bool? _shownRunning;
  TimerPhase? _shownPhase;
  bool _cancelled = true;

  Future<void> sync(TimerState state, AppLocalizations l10n) async {
    if (state.finished) {
      await cancel();
      return;
    }

    final minute = state.remaining.inMinutes;
    final unchanged = !_cancelled &&
        minute == _shownMinute &&
        state.running == _shownRunning &&
        state.phase == _shownPhase;
    if (unchanged) return;

    _shownMinute = minute;
    _shownRunning = state.running;
    _shownPhase = state.phase;
    _cancelled = false;

    final phaseLabel =
        state.phase == TimerPhase.focus ? l10n.timerFocusPhase : l10n.timerBreakPhase;
    final title = state.running
        ? l10n.notificationOngoingRunningTitle(phaseLabel)
        : l10n.notificationOngoingPausedTitle(phaseLabel);

    await _notifications.showOngoingSession(
      title: title,
      body: l10n.notificationOngoingBody(DurationFormat.clock(state.remaining)),
      copy: ongoingSessionCopyFrom(l10n),
    );
  }

  Future<void> cancel() async {
    if (_cancelled) return;
    _cancelled = true;
    _shownMinute = null;
    _shownRunning = null;
    _shownPhase = null;
    await _notifications.cancelOngoingSession();
  }
}
