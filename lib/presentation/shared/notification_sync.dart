import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/notification_service.dart';
import '../../data/providers/data_providers.dart';
import '../../domain/entities/mood.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_providers.dart';
import '../settings/settings_providers.dart';
import 'enum_labels.dart';

/// Собирает тексты уведомлений из текущей локали. Сервис уведомлений
/// намеренно не знает про l10n — иначе строки пришлось бы держать вне ARB.
NotificationCopy notificationCopyFrom(AppLocalizations l10n) {
  return NotificationCopy(
    channelName: l10n.notificationChannelHabits,
    channelDescription: l10n.notificationChannelHabitsDesc,
    habitTitle: l10n.notificationHabitTitle,
    habitBody: l10n.notificationHabitBody,
    dailyTitle: l10n.notificationDailyTitle,
    dailyBody: l10n.notificationDailyBody,
    dailyProductiveBody: l10n.notificationDailyProductive,
    dailyAllDoneBody: l10n.notificationDailyAllDone,
  );
}

/// Пересобирает расписание уведомлений под текущее состояние привычек и
/// настроек. Вызывается после любых изменений, которые на него влияют:
/// создание/правка/удаление привычки, переключатели в настройках, старт
/// приложения.
Future<void> syncNotifications(WidgetRef ref, AppLocalizations l10n) async {
  final repository = ref.read(habitRepositoryProvider);
  final habits = await repository.getHabits();
  final day = ref.read(todayProvider);
  final today = await repository.getHabitsForDay(day);
  final pending = today.where((h) => !h.doneToday && !h.frozenToday).length;

  // Текст итога дня собирается в момент планирования: плагин умеет только
  // фиксированную строку, и «живой» сводки в 21:00 всё равно не получится.
  // Зато пересинхронизация после каждой сессии держит её достаточно свежей.
  final sessions = await ref.read(sessionRepositoryProvider).sessionsInRange(
        day,
        day,
      );
  final focusSeconds =
      sessions.fold<int>(0, (sum, s) => sum + s.actualFocusSeconds);

  final moodCounts = <Mood, int>{};
  for (final session in sessions) {
    moodCounts[session.mood] = (moodCounts[session.mood] ?? 0) + 1;
  }
  Mood? dominant;
  for (final entry in moodCounts.entries) {
    if (dominant == null || entry.value > (moodCounts[dominant] ?? 0)) {
      dominant = entry.key;
    }
  }

  await ref.read(notificationServiceProvider).rescheduleAll(
        habits: habits,
        enabled: ref.read(notificationsEnabledProvider),
        dailySummaryMinutes: ref.read(dailySummaryTimeProvider),
        digest: DailyDigest(
          pendingHabits: pending,
          sessions: sessions.length,
          focusMinutes: (focusSeconds / 60).round(),
          dominantMood: dominant?.label(l10n),
        ),
        copy: notificationCopyFrom(l10n),
      );
}
