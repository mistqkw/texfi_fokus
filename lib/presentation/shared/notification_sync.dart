import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/notification_service.dart';
import '../../data/providers/data_providers.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_providers.dart';
import '../settings/settings_providers.dart';

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
  );
}

/// Пересобирает расписание уведомлений под текущее состояние привычек и
/// настроек. Вызывается после любых изменений, которые на него влияют:
/// создание/правка/удаление привычки, переключатели в настройках, старт
/// приложения.
Future<void> syncNotifications(WidgetRef ref, AppLocalizations l10n) async {
  final repository = ref.read(habitRepositoryProvider);
  final habits = await repository.getHabits();
  final today = await repository.getHabitsForDay(ref.read(todayProvider));
  final pending = today.where((h) => !h.doneToday).length;

  await ref.read(notificationServiceProvider).rescheduleAll(
        habits: habits,
        enabled: ref.read(notificationsEnabledProvider),
        dailySummaryMinutes: ref.read(dailySummaryTimeProvider),
        pendingCount: pending,
        copy: notificationCopyFrom(l10n),
      );
}
