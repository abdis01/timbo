import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';
import '../models/note_model.dart';
import '../models/expense_model.dart';
import '../models/reminder_model.dart';
import '../models/quick_capture_model.dart';
import '../models/user_model.dart';
import '../models/chat_message.dart';

class HiveService {
  HiveService._();

  static final HiveService _instance = HiveService._();
  static HiveService get instance => _instance;

  late Box<NoteModel> _notesBox;
  late Box<ExpenseModel> _expensesBox;
  late Box<ReminderModel> _remindersBox;
  late Box<QuickCaptureModel> _capturesBox;
  late Box<UserModel> _userBox;
  late Box<ChatMessage> _chatBox;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init({String? testPath}) async {
    if (_initialized) return;
    if (testPath != null) {
      Hive.init(testPath);
    } else {
      await Hive.initFlutter();
    }

    _registerAdapter(NoteModelAdapter());
    _registerAdapter(ExpenseModelAdapter());
    _registerAdapter(ReminderModelAdapter());
    _registerAdapter(QuickCaptureModelAdapter());
    _registerAdapter(UserModelAdapter());
    _registerAdapter(ChatMessageAdapter());

    _notesBox = await Hive.openBox<NoteModel>(AppConstants.hiveNotesBox);
    _expensesBox =
        await Hive.openBox<ExpenseModel>(AppConstants.hiveExpensesBox);
    _remindersBox =
        await Hive.openBox<ReminderModel>(AppConstants.hiveRemindersBox);
    _capturesBox =
        await Hive.openBox<QuickCaptureModel>(AppConstants.hiveCapturesBox);
    _userBox = await Hive.openBox<UserModel>(AppConstants.hiveUserBox);
    _chatBox = await Hive.openBox<ChatMessage>(AppConstants.hiveChatBox);

    _initialized = true;
  }

  // --- NOTES ---

  Future<void> saveNote(NoteModel note) async {
    await _notesBox.put(note.id, note);
  }

  NoteModel? getNote(String id) => _notesBox.get(id);

  List<NoteModel> getAllNotes() =>
      _notesBox.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<NoteModel> getPinnedNotes() =>
      _notesBox.values.where((n) => n.isPinned).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<NoteModel> searchNotes(String query) {
    final q = query.toLowerCase();
    return _notesBox.values.where((n) {
      return n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  Stream<BoxEvent> get notesStream => _notesBox.watch();

  // --- EXPENSES ---

  Future<void> saveExpense(ExpenseModel expense) async {
    await _expensesBox.put(expense.id, expense);
  }

  List<ExpenseModel> getAllExpenses() =>
      _expensesBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));

  List<ExpenseModel> getExpensesByMonth(int month, int year) =>
      _expensesBox.values.where((e) {
        return e.date.month == month && e.date.year == year;
      }).toList();

  double getTotalIncome(int month, int year) {
    return getExpensesByMonth(month, year)
        .where((e) => e.type == 'income')
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double getTotalExpenses(int month, int year) {
    return getExpensesByMonth(month, year)
        .where((e) => e.type == 'expense')
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double getBalance(int month, int year) {
    final income = getTotalIncome(month, year);
    final expenses = getTotalExpenses(month, year);
    return income - expenses;
  }

  Future<void> deleteExpense(String id) async {
    await _expensesBox.delete(id);
  }

  Map<String, double> getExpensesByCategory(int month, int year) {
    final map = <String, double>{};
    for (final e in getExpensesByMonth(month, year)) {
      if (e.type == 'expense') {
        map[e.category] = (map[e.category] ?? 0) + e.amount;
      }
    }
    return map;
  }

  Stream<BoxEvent> get expensesStream => _expensesBox.watch();

  // --- REMINDERS ---

  Future<void> saveReminder(ReminderModel reminder) async {
    await _remindersBox.put(reminder.id, reminder);
  }

  List<ReminderModel> getAllReminders() =>
      _remindersBox.values.toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  List<ReminderModel> getUpcomingReminders() {
    final now = DateTime.now();
    return _remindersBox.values.where((r) {
      return r.isActive && r.scheduledAt.isAfter(now);
    }).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  List<ReminderModel> getTodayReminders() {
    final now = DateTime.now();
    return _remindersBox.values.where((r) {
      return r.isActive &&
          r.scheduledAt.year == now.year &&
          r.scheduledAt.month == now.month &&
          r.scheduledAt.day == now.day;
    }).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  Future<void> markReminderComplete(String id) async {
    final reminder = _remindersBox.get(id);
    if (reminder != null) {
      reminder.isCompleted = true;
      await reminder.save();
    }
  }

  Future<void> deleteReminder(String id) async {
    await _remindersBox.delete(id);
  }

  Stream<BoxEvent> get remindersStream => _remindersBox.watch();

  // --- QUICK CAPTURES ---

  Future<void> saveCapture(QuickCaptureModel capture) async {
    await _capturesBox.put(capture.id, capture);
  }

  List<QuickCaptureModel> getAllCaptures() =>
      _capturesBox.values.toList()
        ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));

  Future<void> deleteCapture(String id) async {
    await _capturesBox.delete(id);
  }

  int getTodayCaptureCount() {
    final now = DateTime.now();
    return _capturesBox.values.where((c) {
      return c.capturedAt.year == now.year &&
          c.capturedAt.month == now.month &&
          c.capturedAt.day == now.day;
    }).length;
  }

  Stream<BoxEvent> get capturesStream => _capturesBox.watch();

  // --- USER ---

  Future<void> saveUser(UserModel user) async {
    await _userBox.put(AppConstants.userKey, user);
  }

  UserModel? getUser() => _userBox.get(AppConstants.userKey);

  Future<void> clearUser() async {
    await _userBox.delete(AppConstants.userKey);
  }

  Future<void> updateAIInteractionCount() async {
    final user = getUser();
    if (user != null) {
      await resetDailyLimitsIfNeeded();
      user.aiInteractionsToday++;
      await user.save();
    }
  }

  bool canUserUseAI() {
    final user = getUser();
    if (user == null) return false;
    final limit =
        user.isPremium ? AppConstants.premiumAiDailyLimit : AppConstants.freeAiDailyLimit;
    return user.aiInteractionsToday < limit;
  }

  Future<void> resetDailyLimitsIfNeeded() async {
    final user = getUser();
    if (user == null) return;
    final now = DateTime.now();
    final lastReset = user.lastInteractionReset;
    if (now.year != lastReset.year ||
        now.month != lastReset.month ||
        now.day != lastReset.day) {
      user.aiInteractionsToday = 0;
      user.lastInteractionReset = now;
      await user.save();
    }
  }

  Stream<BoxEvent> get userStream => _userBox.watch();

  // --- CHAT ---

  Future<void> saveChatMessage(ChatMessage msg) async {
    await _chatBox.put(msg.id, msg);
  }

  List<ChatMessage> getChatHistory() {
    final messages = _chatBox.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (messages.length > 100) {
      return messages.sublist(messages.length - 100);
    }
    return messages;
  }

  Future<void> clearChatHistory() async {
    await _chatBox.clear();
  }

  bool isTrialActive() {
    final user = getUser();
    if (user == null) return false;
    if (user.isPremium) return false;
    final trialStart = user.trialStartDate;
    if (trialStart == null) return false;
    final now = DateTime.now();
    return now.difference(trialStart).inDays < 3;
  }

  Future<void> dispose() async {
    await _notesBox.close();
    await _expensesBox.close();
    await _remindersBox.close();
    await _capturesBox.close();
    await _userBox.close();
    await _chatBox.close();
    await Hive.close();
    _initialized = false;
  }

  Future<void> clearAll() async {
    await _notesBox.clear();
    await _expensesBox.clear();
    await _remindersBox.clear();
    await _capturesBox.clear();
    await _userBox.clear();
    await _chatBox.clear();
  }

  void _registerAdapter<T>(TypeAdapter<T> adapter) {
    try {
      Hive.registerAdapter<T>(adapter);
    } catch (_) {}
  }
}
