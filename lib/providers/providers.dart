import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../database/database.dart';
import '../services/sync_service.dart';
import '../services/preferences_service.dart';

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

final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPrefsProvider.future);
  return prefs.getBool('hasCompletedOnboarding') ?? false;
});

final isRecordingProvider = StateProvider<bool>((ref) => false);

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
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

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw Exception('PreferencesService not initialized — override in ProviderScope');
});

final userFontFamilyProvider = Provider<String>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return prefs.defaultFont;
});


