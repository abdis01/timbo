import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../models/expense_model.dart';
import '../models/reminder_model.dart';
import '../models/quick_capture_model.dart';
import 'firebase_service.dart';
import 'hive_service.dart';
enum SyncStatus { idle, syncing, offline, error }

class SyncService extends ChangeNotifier {
  SyncService._();

  static final SyncService _instance = SyncService._();
  static SyncService get instance => _instance;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;
  
  String _statusMessage = '';
  String get statusMessage => _statusMessage;
  
  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;
  
  Timer? _autoSyncTimer;
  StreamSubscription<bool>? _connectivitySub;
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    final userId = FirebaseService.instance.currentUser?.uid;
    if (userId != null) {
      _lastSyncTime = await FirebaseService.instance.getLastSyncTime(userId);
    }
    
    _connectivitySub = FirebaseService.instance.onConnectivityChanged.listen((online) {
      _isOnline = online;
      if (online) {
        _setStatus(SyncStatus.idle, 'Connected');
        _attemptPendingSync();
      } else {
        _setStatus(SyncStatus.offline, 'Offline — changes saved locally');
      }
    });
    
    _isOnline = await FirebaseService.instance.isConnected();
    if (!_isOnline) {
      _setStatus(SyncStatus.offline, 'Offline — changes saved locally');
    }
    
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _autoSync();
    });
  }

  Future<void> _autoSync() async {
    final user = HiveService.instance.getUser();
    if (user == null) return;
    if (!user.cloudSyncEnabled || !user.isPremium || !_isOnline) return;
    await performSync();
  }

  Future<void> _attemptPendingSync() async {
    final user = HiveService.instance.getUser();
    if (user == null) return;
    if (!user.cloudSyncEnabled || !user.isPremium) return;
    await performSync();
  }

  Future<void> performSync() async {
    final user = HiveService.instance.getUser();
    if (user == null) return;
    final userId = FirebaseService.instance.currentUser?.uid;
    if (userId == null) return;
    
    _setStatus(SyncStatus.syncing, 'Syncing...');
    notifyListeners();
    
    try {
      final notes = HiveService.instance.getAllNotes();
      final expenses = HiveService.instance.getAllExpenses();
      final reminders = HiveService.instance.getAllReminders();
      final captures = HiveService.instance.getAllCaptures();
      
      if (_lastSyncTime == null) {
        await FirebaseService.instance.fullSync(userId, 
          notes: notes, expenses: expenses, reminders: reminders, captures: captures);
      } else {
        await FirebaseService.instance.incrementalSync(userId, _lastSyncTime!,
          notes: notes, expenses: expenses, reminders: reminders, captures: captures);
        
        final cloudData = await FirebaseService.instance.downloadFromCloud(userId);
        await _mergeCloudData(cloudData, notes, expenses, reminders, captures);
      }
      
      _lastSyncTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync_time_$userId', _lastSyncTime!.toIso8601String());
      
      _setStatus(SyncStatus.idle, _formatLastSync());
    } catch (e) {
      _setStatus(SyncStatus.error, 'Sync failed. Will retry.');
    }
    notifyListeners();
  }

  Future<void> _mergeCloudData(
    SyncCloudData cloudData,
    List<NoteModel> localNotes,
    List<ExpenseModel> localExpenses,
    List<ReminderModel> localReminders,
    List<QuickCaptureModel> localCaptures,
  ) async {
    for (final cloudNote in cloudData.notes) {
      final localNote = localNotes.where((n) => n.id == cloudNote.id).firstOrNull;
      if (localNote == null || cloudNote.updatedAt.isAfter(localNote.updatedAt)) {
        await HiveService.instance.saveNoteDirectly(cloudNote);
      }
    }
    for (final cloudExpense in cloudData.expenses) {
      final local = localExpenses.where((e) => e.id == cloudExpense.id).firstOrNull;
      if (local == null || cloudExpense.updatedAt.isAfter(local.updatedAt)) {
        await HiveService.instance.saveExpenseDirectly(cloudExpense);
      }
    }
    for (final cloudReminder in cloudData.reminders) {
      final local = localReminders.where((r) => r.id == cloudReminder.id).firstOrNull;
      if (local == null || cloudReminder.updatedAt.isAfter(local.updatedAt)) {
        await HiveService.instance.saveReminderDirectly(cloudReminder);
      }
    }
    for (final cloudCapture in cloudData.captures) {
      final local = localCaptures.where((c) => c.id == cloudCapture.id).firstOrNull;
      if (local == null || cloudCapture.updatedAt.isAfter(local.updatedAt)) {
        await HiveService.instance.saveCaptureDirectly(cloudCapture);
      }
    }
  }

  void _setStatus(SyncStatus newStatus, String message) {
    _status = newStatus;
    _statusMessage = message;
    notifyListeners();
  }

  String _formatLastSync() {
    if (_lastSyncTime == null) return '';
    final diff = DateTime.now().difference(_lastSyncTime!);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String get formattedLastSync {
    if (_lastSyncTime == null) return 'Never';
    return _formatLastSync();
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}
