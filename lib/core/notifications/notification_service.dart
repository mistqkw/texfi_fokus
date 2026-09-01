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
    required this.dailyProductiveBody,
    required this.dailyAllDoneBody,
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

  /// `(сессии, минуты в фокусе, настроение) -> тело` для продуктивного дня.
  final String Function(int sessions, int minutes, String mood)
      dailyProductiveBody;

  /// Все цели закрыты и сессий не было — говорить «осталось 0» глупо.
  final String dailyAllDoneBody;
}

/// Итог дня для вечернего уведомления. Собирается на стороне приложения:
/// сервис уведомлений о сессиях и настроениях ничего не знает.
class DailyDigest {
  const DailyDigest({
    required this.pendingHabits,
    this.sessions = 0,
    this.focusMinutes = 0,
    this.dominantMood,
  });

  final int pendingHabits;
  final int sessions;
  final int focusMinutes;

  /// Подпись преобладающего настроения дня; null — сессий не было.
  final String? dominantMood;

  /// Был ли день продуктивным настолько, чтобы об этом стоило сказать.
  ///
  /// Одна сессия — это ещё не сводка: «сегодня: 1 сессия, 12 минут» звучит
  /// как упрёк, а не как похвала.
  bool get isProductive => sessions >= 2 && focusMinutes > 0;
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
    required DailyDigest digest,
    required NotificationCopy copy,
  }) async {
    if (!_canSchedule) return;
    await init();
    if (!_initialized) return;

    try {
      await _plugin.zonedSchedule(
        _dailySummaryId,
        copy.dailyTitle,
        _dailyBody(digest, copy),
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

  /// Текст вечернего уведомления.
  ///
  /// Слот тот же, что был, — меняется только содержание. Напоминание о
  /// незакрытых целях остаётся главным, но если день вышел рабочим, об этом
  /// говорится первым: приложение, которое к вечеру умеет только упрекать,
  /// быстро отключают.
  String _dailyBody(DailyDigest digest, NotificationCopy copy) {
    final summary = digest.isProductive
        ? copy.dailyProductiveBody(
            digest.sessions,
            digest.focusMinutes,
            digest.dominantMood ?? '',
          )
        : null;

    if (digest.pendingHabits == 0) {
      return summary ?? copy.dailyAllDoneBody;
    }
    final pending = copy.dailyBody(digest.pendingHabits);
    return summary == null ? pending : '$summary $pending';
  }

  /// Тот же сборщик текста, что уходит в уведомление, — открыт для тестов.
  /// Планировщик на тестовой платформе не работает, а проверять надо именно
  /// формулировку, а не факт вызова плагина.
  @visibleForTesting
  String debugDailyBody(DailyDigest digest, NotificationCopy copy) =>
      _dailyBody(digest, copy);

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
    required DailyDigest digest,
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
      digest: digest,
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
