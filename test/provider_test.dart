import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:timbo_app/models/note_model.dart';
import 'package:timbo_app/models/expense_model.dart';
import 'package:timbo_app/models/reminder_model.dart';
import 'package:timbo_app/models/user_model.dart';
import 'package:timbo_app/providers/notes_provider.dart';
import 'package:timbo_app/providers/finance_provider.dart';
import 'package:timbo_app/providers/reminders_provider.dart';
import 'package:timbo_app/providers/user_provider.dart';
import 'package:timbo_app/services/hive_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('provider_test_');
    await HiveService.instance.init(testPath: tempDir.path);
  });

  tearDownAll(() async {
    await HiveService.instance.dispose();
    tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    await HiveService.instance.clearAll();
  });

  test('NotesProvider — CRUD via Hive', () async {
    final provider = NotesProvider();
    await provider.loadNotes();
    expect(provider.notes, isEmpty);

    await provider.addNote(NoteModel(
      title: 'Test Note',
      content: 'Content here',
      tags: ['test'],
    ));
    expect(provider.notes.length, 1);
    expect(provider.notes.first.title, 'Test Note');

    await provider.togglePin(provider.notes.first.id);
    expect(provider.pinnedNotes.length, 1);
    expect(provider.pinnedNotes.first.isPinned, true);

    provider.search('Test');
    expect(provider.searchResults.length, 1);
    expect(provider.searchQuery, 'Test');

    provider.clearSearch();
    expect(provider.searchResults, isEmpty);

    await provider.deleteNote(provider.notes.first.id);
    expect(provider.notes, isEmpty);
  });

  test('FinanceProvider — CRUD via Hive', () async {
    final provider = FinanceProvider();
    await provider.loadFinanceData();
    expect(provider.expenses, isEmpty);
    expect(provider.balance, 0);

    await provider.addExpense(ExpenseModel(
      amount: 100, type: 'expense', category: 'food', description: 'Lunch',
    ));
    await provider.addExpense(ExpenseModel(
      amount: 200, type: 'income', category: 'salary', description: 'Pay',
    ));
    expect(provider.expenses.length, 2);
    expect(provider.monthlyExpenses, 100);
    expect(provider.monthlyIncome, 200);
    expect(provider.balance, 100);
    expect(provider.savingsRate, 50);
    expect(provider.getTopSpendingCategory(), 'food');

    await provider.deleteExpense(provider.expenses.first.id);
    expect(provider.expenses.length, 1);
  });

  test('RemindersProvider — CRUD via Hive', () async {
    final provider = RemindersProvider();
    await provider.loadReminders();
    expect(provider.allReminders, isEmpty);

    await provider.addReminder(ReminderModel(
      title: 'Meeting', description: 'Standup',
      scheduledAt: DateTime.now(), priority: 'high',
    ));
    expect(provider.allReminders.length, 1);
    expect(provider.todayReminders.length, 1);

    await provider.markComplete(provider.allReminders.first.id);
    expect(provider.allReminders.first.isCompleted, true);

    await provider.deleteReminder(provider.allReminders.first.id);
    expect(provider.allReminders, isEmpty);
  });

  test('UserProvider — CRUD via Hive', () async {
    final provider = UserProvider();
    await provider.loadUser();
    expect(provider.user, isNull);
    expect(provider.isLoggedIn, false);

    final user = UserModel(
      name: 'Test User', email: 'test@timbo.app', darkModeEnabled: true,
    );
    await provider.updateUser(user);

    expect(provider.user, isNotNull);
    expect(provider.user!.name, 'Test User');
    expect(provider.isDarkMode, true);
    expect(provider.isPremium, false);

    await provider.toggleTheme();
    expect(provider.isDarkMode, false);
    expect(provider.user!.darkModeEnabled, false);

    await provider.setPremium(true);
    expect(provider.isPremium, true);

    final hour = DateTime.now().hour;
    if (hour < 12) {
      expect(provider.greeting, 'Good Morning');
    } else if (hour < 17) {
      expect(provider.greeting, 'Good Afternoon');
    } else {
      expect(provider.greeting, 'Good Evening');
    }
  });
}
