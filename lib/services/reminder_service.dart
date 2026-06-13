import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  VoidCallback? onNotificationTap;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('ic_notification');
      const linuxSettings = LinuxInitializationSettings(defaultActionName: 'View');
      const settings = InitializationSettings(android: androidSettings, linux: linuxSettings);
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) {
          onNotificationTap?.call();
        },
      );
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'timbo_reminders',
          'Timbo Reminders',
          description: 'Reminders from your Timbos',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'timbo_test',
          'Timbo Test',
          description: 'Test notifications',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  Future<bool> _requestExactAlarm() async {
    if (await Permission.scheduleExactAlarm.isGranted) return true;
    final status = await Permission.scheduleExactAlarm.request();
    return status.isGranted;
  }

  Future<bool> _requestNotificationPermission() async {
    if (await Permission.notification.isGranted) return true;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    if (!_initialized) await initialize();

    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime.from(scheduledAt, tz.local);
    if (scheduled.isBefore(now)) return;

    final notifGranted = await _requestNotificationPermission();
    if (!notifGranted) return;

    try {
      if (await _requestExactAlarm()) {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduled,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'timbo_reminders',
              'Timbo Reminders',
              importance: Importance.high,
              priority: Priority.high,
              icon: 'ic_notification',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } else {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduled,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'timbo_reminders',
              'Timbo Reminders',
              importance: Importance.high,
              priority: Priority.high,
              icon: 'ic_notification',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('Failed to schedule reminder: $e');
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (e) {
      debugPrint('Failed to cancel reminder: $e');
    }
  }

  Future<void> showTestNotification() async {
    if (!_initialized) await initialize();
    final notifGranted = await _requestNotificationPermission();
    if (!notifGranted) return;

    try {
      await _plugin.show(
        id: 999999,
        title: 'Timbo Test Notification',
        body: 'Your reminder system is working perfectly!',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'timbo_test',
            'Timbo Test',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_notification',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Failed to show test notification: $e');
    }
  }
}
