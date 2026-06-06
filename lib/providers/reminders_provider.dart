import 'package:flutter/foundation.dart';
import '../models/reminder_model.dart';
import '../services/hive_service.dart';

class RemindersProvider extends ChangeNotifier {
  List<ReminderModel> _reminders = [];
  List<ReminderModel> _todayReminders = [];
  bool _isLoading = false;

  List<ReminderModel> get allReminders => List.unmodifiable(_reminders);
  List<ReminderModel> get upcomingReminders {
    final now = DateTime.now();
    return _reminders
        .where((r) => r.isActive && r.scheduledAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  List<ReminderModel> get todayReminders => List.unmodifiable(_todayReminders);
  bool get isLoading => _isLoading;
  int get pendingCount =>
      _todayReminders.where((r) => !r.isCompleted).length;

  Future<void> loadReminders() async {
    _isLoading = true;
    notifyListeners();

    _reminders = HiveService.instance.getAllReminders();
    _todayReminders = HiveService.instance.getTodayReminders();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await HiveService.instance.saveReminder(reminder);
    _reminders.add(reminder);
    _todayReminders = HiveService.instance.getTodayReminders();
    notifyListeners();
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await HiveService.instance.saveReminder(reminder);
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
    }
    _todayReminders = HiveService.instance.getTodayReminders();
    notifyListeners();
  }

  Future<void> deleteReminder(String id) async {
    await HiveService.instance.deleteReminder(id);
    _reminders.removeWhere((r) => r.id == id);
    _todayReminders = HiveService.instance.getTodayReminders();
    notifyListeners();
  }

  Future<void> markComplete(String id) async {
    await HiveService.instance.markReminderComplete(id);
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].isCompleted = true;
    }
    _todayReminders = HiveService.instance.getTodayReminders();
    notifyListeners();
  }

  List<ReminderModel> getRemindersForDay(DateTime day) {
    return _reminders.where((r) {
      return r.scheduledAt.year == day.year &&
          r.scheduledAt.month == day.month &&
          r.scheduledAt.day == day.day;
    }).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }
}
