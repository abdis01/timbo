import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('ic_notification');
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'View');
    const settings = InitializationSettings(android: androidSettings, linux: linuxSettings);
    await _plugin.initialize(settings: settings);
  }

  Future<bool> _requestExactAlarm() async {
    if (await Permission.scheduleExactAlarm.isGranted) return true;
    final status = await Permission.scheduleExactAlarm.request();
    return status.isGranted;
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    if (scheduledAt.isBefore(DateTime.now())) return;

    if (await _requestExactAlarm()) {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'timbo_reminders',
            'Timbo Reminders',
            channelDescription: 'Reminders from your Timbos',
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
        scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'timbo_reminders',
            'Timbo Reminders',
            channelDescription: 'Reminders from your Timbos',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_notification',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id: id);
  }
}
