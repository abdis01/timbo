import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../providers/finance_provider.dart';
import '../services/hive_service.dart';

class WidgetService {
  static final WidgetService instance = WidgetService._();
  WidgetService._();

  bool get _isSupported {
    final platform = defaultTargetPlatform;
    return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
  }

  void initialize() {
    if (!_isSupported) return;
    try {
      HomeWidget.registerInteractivityCallback(_onWidgetClick);
    } catch (_) {}
  }

  Future<void> _onWidgetClick(Uri? uri) async {
    if (uri == null) return;

    switch (uri.toString()) {
      case 'timbo://quick_capture':
        break;
      case 'timbo://finance':
        break;
    }
  }

  Future<void> updateWidget(FinanceProvider financeProvider) async {
    if (!_isSupported) return;
    try {
      await _updateWidgetData(financeProvider);
      await _updateWidget();
    } catch (_) {}
  }

  Future<void> _updateWidgetData(FinanceProvider financeProvider) async {
    final balance = financeProvider.balance;
    final balanceStr = balance >= 0
        ? '+${balance.toStringAsFixed(0)}'
        : balance.toStringAsFixed(0);

    final reminders = HiveService.instance.getTodayReminders();
    final reminderStr = reminders.isNotEmpty && !reminders.first.isCompleted
        ? '${reminders.first.title} · ${reminders.first.scheduledAt.hour}:${reminders.first.scheduledAt.minute.toString().padLeft(2, '0')}'
        : 'No reminders today';

    await HomeWidget.saveWidgetData('balance', balanceStr);
    await HomeWidget.saveWidgetData('reminder', reminderStr);
  }

  Future<void> _updateWidget() async {
    await HomeWidget.updateWidget(
      androidName: 'TimboWidgetProvider',
      qualifiedAndroidName: 'com.timbo.timbo_app.TimboWidgetProvider',
    );
  }
}
