import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/data_providers.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/session_guards.dart';
import '../settings/settings_providers.dart';

/// Последние сессии в порядке «свежие сверху». Лимита хватает и на серию
/// прерываний, и на «когда закончилась предыдущая».
final recentSessionsProvider = StreamProvider<List<SessionEntity>>((ref) {
  return ref.watch(sessionRepositoryProvider).watchRecentSessions(
        limit: SessionGuards.burnoutStreakThreshold,
      );
});

/// Когда закончилась последняя сессия. null — сессий ещё не было.
final lastSessionEndProvider = Provider<DateTime?>((ref) {
  final sessions = ref.watch(recentSessionsProvider).valueOrNull;
  if (sessions == null || sessions.isEmpty) return null;
  return sessions.first.endedAt;
});

/// Идёт ли серия прерванных сессий подряд.
final burnoutStreakProvider = Provider<bool>((ref) {
  final sessions = ref.watch(recentSessionsProvider).valueOrNull;
  if (sessions == null) return false;
  return SessionGuards.isBurnoutStreak(sessions);
});

/// Час, после которого включается ночной кап, — или null, если кап выключен.
/// Пустой Optional тут был бы шумом: null и так значит «не ограничивать».
final effectiveNightCapHourProvider = Provider<int?>((ref) {
  if (!ref.watch(nightCapEnabledProvider)) return null;
  return ref.watch(nightCapHourProvider);
});

/// Что именно стоит показать перед стартом. Порядок важен: разговор об
/// усталости перекрывает мелкое замечание про короткий перерыв — если человек
/// третий раз подряд не досидел, «ты только что закончил» звучит издевательски.
enum StartWarning { none, burnoutStreak, shortBreak }

final startWarningProvider = Provider<StartWarning>((ref) {
  if (ref.watch(burnoutStreakProvider)) return StartWarning.burnoutStreak;

  final needsBreak = SessionGuards.needsShortBreakWarning(
    lastEndedAt: ref.watch(lastSessionEndProvider),
    now: DateTime.now(),
    minGapMinutes: ref.watch(shortBreakMinutesProvider),
  );
  return needsBreak ? StartWarning.shortBreak : StartWarning.none;
});
