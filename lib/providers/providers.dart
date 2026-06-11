import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../database/database.dart';
import '../services/capture_service.dart';
import '../services/sync_service.dart';

final databaseProvider = Provider<TimboDatabase>((ref) => TimboDatabase());

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final conn = ref.watch(connectivityProvider);
  return !(conn.valueOrNull?.contains(ConnectivityResult.none) ?? true);
});

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final authStateProvider = StreamProvider<auth.User?>((ref) {
  return auth.FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<auth.User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPrefsProvider.future);
  return prefs.getBool('hasSeenOnboarding') ?? false;
});

final capturesProvider = StreamProvider<List<Capture>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllCaptures();
});

final filteredCapturesProvider = Provider.family<AsyncValue<List<Capture>>, String>((ref, filter) {
  final all = ref.watch(capturesProvider);
  return all.whenData((list) {
    if (filter == 'all') return list;
    return list.where((c) => c.type == filter).toList();
  });
});

final todayRemindersProvider = FutureProvider<List<Capture>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getTodayReminders();
});

final todayCaptureCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getTodayCaptureCount();
});

final recentCapturesProvider = FutureProvider<List<Capture>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getRecentCaptures();
});

final dailySummaryProvider = FutureProvider<String>((ref) async {
  final db = ref.watch(databaseProvider);
  final count = await db.getTodayCaptureCount();
  final reminders = await db.getTodayReminders();
  if (count == 0) return 'Ready when you are. Start capturing below.';
  final reminderText = reminders.isNotEmpty
      ? '${reminders.length} reminder${reminders.length > 1 ? 's' : ''} coming up.'
      : 'No reminders today.';
  return "You've captured $count thought${count > 1 ? 's' : ''} today. $reminderText";
});

final captureTypeProvider = StateProvider<String?>((ref) => null);

final isRecordingProvider = StateProvider<bool>((ref) => false);

final captureServiceProvider = Provider<CaptureService>((ref) {
  final db = ref.watch(databaseProvider);
  return CaptureService(db);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db);
});

final userGreetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
});

final formattedDateProvider = Provider<String>((ref) {
  final now = DateTime.now();
  final months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
});

final userNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.displayName ?? user?.email?.split('@').first ?? 'Friend';
});

final themeModeProvider = StateProvider<bool>((ref) => false);
