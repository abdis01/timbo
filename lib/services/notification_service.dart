import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../config/routes.dart';

enum RepeatInterval { daily, weekly }

class RecurringTime {
  final int hour;
  final int minute;
  const RecurringTime({required this.hour, required this.minute});
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static final Map<String, int> _notificationIds = {};
  static int _nextId = 1000;

  static GlobalKey<NavigatorState>? navigatorKey;
  static String? _pendingRoute;

  static int _getId(String id) {
    if (_notificationIds.containsKey(id)) {
      return _notificationIds[id]!;
    }
    final intId = _nextId++;
    _notificationIds[id] = intId;
    return intId;
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || navigatorKey == null) return;
    _pendingRoute = payload;
  }

  static String? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  static void navigateToPendingRoute() {
    final route = _pendingRoute;
    if (route != null && navigatorKey?.currentState != null) {
      _pendingRoute = null;
      navigatorKey!.currentState!.pushNamedAndRemoveUntil(
        route,
        (r) => r.settings.name == AppRoutes.home,
      );
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    if (!_initialized) await initialize();
    await requestPermissions();

    final now = DateTime.now();
    if (scheduledAt.isBefore(now)) return;

    final intId = _getId(id);
    final location = tz.local;
    final tzScheduled = tz.TZDateTime.from(scheduledAt, location);

    await _plugin.zonedSchedule(
      id: intId,
      title: title,
      body: body,
      scheduledDate: tzScheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('reminders', 'Reminders',
            importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: '/reminders',
    );
  }

  static Future<void> scheduleRecurringReminder({
    required String id,
    required String title,
    required String body,
    required RepeatInterval interval,
    required RecurringTime time,
  }) async {
    if (!_initialized) await initialize();
    await requestPermissions();

    final intId = _getId(id);
    final now = DateTime.now();
    final scheduledAt = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    final location = tz.local;
    final tzScheduled = tz.TZDateTime.from(scheduledAt, location);

    final component = interval == RepeatInterval.daily
        ? DateTimeComponents.time
        : DateTimeComponents.dayOfWeekAndTime;

    await _plugin.zonedSchedule(
      id: intId,
      title: title,
      body: body,
      scheduledDate: tzScheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('reminders', 'Reminders',
            importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: component,
      payload: '/reminders',
    );
  }

  static Future<void> cancelNotification(String id) async {
    if (_notificationIds.containsKey(id)) {
      await _plugin.cancel(id: _notificationIds[id]!);
      _notificationIds.remove(id);
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
    _notificationIds.clear();
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();
    await requestPermissions();

    final intId = _nextId++;
    const details = NotificationDetails(
      android: AndroidNotificationDetails('default', 'Default',
          importance: Importance.high, priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(
      id: intId,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  static Future<void> scheduleDailyInsightNotification() async {
    if (!_initialized) await initialize();
    await requestPermissions();

    const intId = 999;
    final now = DateTime.now();
    final scheduledAt = DateTime(now.year, now.month, now.day, 9, 0)
        .add(const Duration(days: 1));

    final location = tz.local;
    final tzScheduled = tz.TZDateTime.from(scheduledAt, location);

    await _plugin.zonedSchedule(
      id: intId,
      title: 'Your Daily Timbo Insight',
      body: 'Tap to see your personalized insights for today',
      scheduledDate: tzScheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('insights', 'AI Insights',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '/insights',
    );
  }

  static const int _quickCaptureNotificationId = 888;

  static Future<void> showPersistentQuickCaptureNotification() async {
    if (!_initialized) await initialize();
    await requestPermissions();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'quick_capture', 'Quick Capture',
        importance: Importance.low,
        priority: Priority.min,
        ongoing: true,
        showWhen: false,
        visibility: NotificationVisibility.public,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      ),
    );

    await _plugin.show(
      id: _quickCaptureNotificationId,
      title: 'Timbo',
      body: 'Tap to quick capture',
      notificationDetails: details,
      payload: '/home',
    );
  }

  static Future<void> cancelPersistentQuickCaptureNotification() async {
    await _plugin.cancel(id: _quickCaptureNotificationId);
  }
}
