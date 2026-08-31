import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/habit_entity.dart';

/// Тексты уведомлений приходят из слоя локализации: сервис ничего не
/// переводит сам, иначе строки пришлось бы дублировать вне ARB.
class NotificationCopy {
  const NotificationCopy({
    required this.channelName,
    required this.channelDescription,
    required this.habitTitle,
    required this.habitBody,
    required this.dailyTitle,
    required this.dailyBody,
  });

  final String channelName;
  final String channelDescription;

  /// `(имя привычки) -> заголовок`.
  final String Function(String habit) habitTitle;

  /// `(текст наказания) -> тело`.
  final String Function(String punishment) habitBody;

  final String dailyTitle;

  /// `(число невыполненных целей) -> тело`.
  final String Function(int count) dailyBody;
}

/// Локальные уведомления: напоминания по привычкам и общий итог дня.
///
/// Плагин поддерживает планирование не везде: на Android/iOS/macOS работает
/// `zonedSchedule`, на Linux — только показ уведомления здесь и сейчас,
/// а Windows в этой версии плагина не поддерживается вовсе. Поэтому весь
/// сервис устроен так, чтобы на неподдерживаемых платформах молча
/// становиться no-op, а не ронять приложение.
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;

  static const String _channelId = 'texfi_fokus_habits';

  /// Идентификаторы уведомлений: у итога дня свой фиксированный, у привычек —
  /// производные от хеша id, смещённые, чтобы не столкнуться с ним.
  static const int _dailySummaryId = 1;
  static const int _habitIdOffset = 1000;

  /// Планирование доступно только там, где плагин умеет `zonedSchedule`.
  bool get _canSchedule =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  /// Показ уведомления «прямо сейчас» умеет ещё и Linux.
  bool get _canNotify => _canSchedule || (!kIsWeb && Platform.isLinux);

  Future<void> init() async {
    if (_initialized || !_canNotify) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(_resolveLocalLocation());

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      linux: LinuxInitializationSettings(defaultActionName: 'Open'),
    );

    try {
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (error, stack) {
      debugPrint('NotificationService.init failed: $error\n$stack');
    }
  }

  /// Пакет `timezone` не знает системную зону сам, а тянуть ради одного
  /// значения ещё один плагин не хочется. Поэтому подбираем зону по текущему
  /// смещению UTC: для планирования на ближайшие сутки этого достаточно, а
  /// ошибиться можно разве что в правилах перехода на летнее время.
  tz.Location _resolveLocalLocation() {
    final offset = DateTime.now().timeZoneOffset;
    final now = DateTime.now().toUtc();
    for (final location in tz.timeZoneDatabase.locations.values) {
      if (location.currentTimeZone.offset == offset.inMilliseconds) {
        // Проверяем, что зона действительно даёт то же локальное время.
        final localized = tz.TZDateTime.from(now, location);
        if (localized.timeZoneOffset == offset) return location;
      }
    }
    return tz.UTC;
  }

  /// Запрашивает разрешение на уведомления. Возвращает `true`, если
  /// показывать их можно (в том числе там, где разрешение не требуется).
  Future<bool> requestPermission() async {
    if (!_canNotify) return false;
    await init();
    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await android?.requestNotificationsPermission();
        return granted ?? true;
      }
      if (Platform.isIOS || Platform.isMacOS) {
        final darwin = _plugin.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
        final granted = await darwin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? true;
      }
      return true;
    } catch (error) {
      debugPrint('requestPermission failed: $error');
      return false;
    }
  }

  NotificationDetails _details(NotificationCopy copy) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        copy.channelName,
        channelDescription: copy.channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
      linux: const LinuxNotificationDetails(),
    );
  }

  int _habitNotificationId(String habitId) =>
      _habitIdOffset + (habitId.hashCode.abs() % 100000);

  /// Ближайшее наступление указанного времени суток — сегодня, если оно ещё
  /// не прошло, иначе завтра.
  tz.TZDateTime _nextInstanceOf(int minutesFromMidnight) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutesFromMidnight ~/ 60,
      minutesFromMidnight % 60,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Персональное напоминание по привычке — повторяется каждый день в
  /// указанное время. Дни недели фильтруются при показе на стороне
  /// приложения: `matchDateTimeComponents` умеет только «каждый день».
  Future<void> scheduleHabitReminder(
    HabitEntity habit,
    NotificationCopy copy,
  ) async {
    if (!_canSchedule || habit.reminderMinutes == null) return;
    await init();
    if (!_initialized) return;

    try {
      await _plugin.zonedSchedule(
        _habitNotificationId(habit.id),
        copy.habitTitle(habit.name),
        copy.habitBody(habit.punishment),
        _nextInstanceOf(habit.reminderMinutes!),
        _details(copy),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'habit:${habit.id}',
      );
    } catch (error) {
      debugPrint('scheduleHabitReminder failed: $error');
    }
  }

  Future<void> cancelHabitReminder(String habitId) async {
    if (!_canNotify) return;
    try {
      await _plugin.cancel(_habitNotificationId(habitId));
    } catch (error) {
      debugPrint('cancelHabitReminder failed: $error');
    }
  }

  /// Ежедневная проверка ближе к концу дня: сколько целей осталось незакрытыми.
  Future<void> scheduleDailySummary({
    required int minutesFromMidnight,
    required int pendingCount,
    required NotificationCopy copy,
  }) async {
    if (!_canSchedule) return;
    await init();
    if (!_initialized) return;

    try {
      await _plugin.zonedSchedule(
        _dailySummaryId,
        copy.dailyTitle,
        copy.dailyBody(pendingCount),
        _nextInstanceOf(minutesFromMidnight),
        _details(copy),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily',
      );
    } catch (error) {
      debugPrint('scheduleDailySummary failed: $error');
    }
  }

  Future<void> cancelDailySummary() async {
    if (!_canNotify) return;
    try {
      await _plugin.cancel(_dailySummaryId);
    } catch (error) {
      debugPrint('cancelDailySummary failed: $error');
    }
  }

  /// Пересобирает все запланированные напоминания: вызывается после любых
  /// изменений в привычках и настройках уведомлений.
  Future<void> rescheduleAll({
    required List<HabitEntity> habits,
    required bool enabled,
    required int dailySummaryMinutes,
    required int pendingCount,
    required NotificationCopy copy,
  }) async {
    if (!_canNotify) return;
    await init();
    await cancelAll();
    if (!enabled) return;

    for (final habit in habits) {
      if (habit.archived) continue;
      await scheduleHabitReminder(habit, copy);
    }
    await scheduleDailySummary(
      minutesFromMidnight: dailySummaryMinutes,
      pendingCount: pendingCount,
      copy: copy,
    );
  }

  Future<void> cancelAll() async {
    if (!_canNotify) return;
    try {
      await _plugin.cancelAll();
    } catch (error) {
      debugPrint('cancelAll failed: $error');
    }
  }
}
