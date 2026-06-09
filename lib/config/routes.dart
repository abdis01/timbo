import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/notes/note_detail_screen.dart';
import '../screens/finance/finance_screen.dart';
import '../screens/reminders/reminders_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/insights/insights_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/search_screen.dart';
import '../screens/onboarding/name_input_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String notes = '/notes';
  static const String noteDetail = '/notes/detail';
  static const String finance = '/finance';
  static const String reminders = '/reminders';
  static const String chat = '/chat';
  static const String insights = '/insights';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String privacy = '/privacy';
  static const String nameInput = '/name-input';

  static const _duration = Duration(milliseconds: 350);

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder == null) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))),
      );
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final routeName = settings.name ?? '';

        // Fade through for most screens
        if (routeName == AppRoutes.home || routeName == AppRoutes.notes || routeName == AppRoutes.reminders ||
            routeName == AppRoutes.settings || routeName == AppRoutes.search || routeName == AppRoutes.insights) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeIn),
            ),
            child: child,
          );
        }

        // Sliding transition for detail screens
        if (routeName == AppRoutes.noteDetail || routeName == AppRoutes.chat) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        }

        // Default: subtle slide + fade
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeIn),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: _duration,
    );
  }

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    login: (_) => const LoginScreen(),
    home: (_) => const HomeScreen(),
    notes: (_) => const NotesScreen(),
    noteDetail: (_) => const NoteDetailScreen(),
    finance: (_) => const FinanceScreen(),
    reminders: (_) => const RemindersScreen(),
    chat: (_) => const ChatScreen(),
    insights: (_) => const InsightsScreen(),
    settings: (_) => const SettingsScreen(),
    search: (_) => const SearchScreen(),
    privacy: (_) => const PrivacyScreen(),
    nameInput: (_) => const NameInputScreen(),
  };
}
