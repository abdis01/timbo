import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/hive_service.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'providers/notes_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/reminders_provider.dart';
import 'providers/user_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.instance.init();

  try {
    await FirebaseService.init();
  } catch (_) {}

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
      child: const TimboApp(),
    ),
  );
}
