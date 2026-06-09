import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'services/hive_service.dart';
import 'services/firebase_service.dart';
import 'services/gemini_service.dart';
import 'services/notification_service.dart';
import 'config/constants.dart';
import 'providers/notes_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/reminders_provider.dart';
import 'providers/user_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await HiveService.instance.init();
  } catch (e) {
    debugPrint('Hive init error: $e');
  }

  try {
    await FirebaseService.init();
  } catch (_) {}

  // Configure Gemini API proxy (set geminiProxyUrl in constants.dart for production)
  GeminiService.instance.configure(
    proxyUrl: AppConstants.geminiProxyUrl,
  );

  // Set up Crashlytics only if Firebase is available
  if (FirebaseService.instance.isAvailable) {
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } else {
    FlutterError.onError = (details) {
      debugPrint('FlutterError: ${details.exception}\n${details.stack}');
    };
  }

  try {
    await NotificationService.initialize();
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => RemindersProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const CrashGuard(child: TimboApp()),
    ),
  );
}

class CrashGuard extends StatefulWidget {
  final Widget child;
  const CrashGuard({super.key, required this.child});

  @override
  State<CrashGuard> createState() => _CrashGuardState();
}

class _CrashGuardState extends State<CrashGuard> {
  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (details) {
      return Material(
        color: const Color(0xFF1A1D27),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  details.exception.toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.yellowAccent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  details.stack?.toString().split('\n').take(10).join('\n') ?? '',
                  style: const TextStyle(fontSize: 10, color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
