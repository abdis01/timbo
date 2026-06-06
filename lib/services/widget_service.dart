import 'package:home_widget/home_widget.dart';
import '../providers/finance_provider.dart';
import '../services/hive_service.dart';

class WidgetService {
  static final WidgetService instance = WidgetService._();
  WidgetService._();

  void initialize() {
    HomeWidget.registerInteractivityCallback(_onWidgetClick);
  }

  Future<void> _onWidgetClick(Uri? uri) async {
    if (uri == null) return;

    switch (uri.toString()) {
      case 'timbo://quick_capture':
        // Quick capture — handled via notification service in app.dart
        break;
      case 'timbo://finance':
        // Navigate to finance — handled in app.dart
        break;
    }
  }

  Future<void> updateWidget(FinanceProvider financeProvider) async {
    await _updateWidgetData(financeProvider);
    await _updateWidget();
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
