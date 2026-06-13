import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'firebase_options.dart';
import 'app.dart';
import 'services/reminder_service.dart';
import 'services/preferences_service.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Set status bar color to match app background
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: const Color(0xFFF5F0E8), // TimboColors.appBackground
    ),
  );

  FlutterError.onError = (details) {
    debugPrint('\n===== FATAL FLUTTER ERROR =====');
    debugPrint('Exception: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
    debugPrint('===== END =====\n');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('\n===== PLATFORM ERROR =====');
    debugPrint('Error: $error');
    debugPrint('Stack: $stack');
    debugPrint('===== END =====\n');
    return true;
  };

  ErrorWidget.builder = (details) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 20),
                  const Text('ERROR', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 16),
                  Text('${details.exception}', style: const TextStyle(fontSize: 14, color: Colors.black87), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  tz_data.initializeTimeZones();
  await ReminderService.instance.initialize();

  if (Platform.isAndroid) {
    if (await Permission.notification.isGranted == false) {
      await Permission.notification.request();
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final prefsService = PreferencesService(prefs);

  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(prefsService),
      ],
      child: const TimboApp(),
    ),
  );
}
