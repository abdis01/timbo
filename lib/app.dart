import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/providers.dart';
import 'config/theme.dart';
import 'screens/home_screen.dart';
import 'screens/vault_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'services/sync_service.dart';
import 'services/shake_service.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, __) => const AuthScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => _Shell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, __) => NoTransitionPage(child: const HomeScreen()),
          ),
          GoRoute(
            path: '/vault',
            pageBuilder: (_, __) => NoTransitionPage(child: const VaultScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, __) => NoTransitionPage(child: const ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});

class _Shell extends ConsumerWidget {
  final Widget child;
  const _Shell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    if (location.contains('/vault')) currentIndex = 1;
    if (location.contains('/profile')) currentIndex = 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/home');
            case 1: context.go('/vault');
            case 2: context.go('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.inbox_rounded), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: ''),
        ],
      ),
    );
  }
}

class TimboApp extends ConsumerStatefulWidget {
  const TimboApp({super.key});

  @override
  ConsumerState<TimboApp> createState() => _TimboAppState();
}

class _TimboAppState extends ConsumerState<TimboApp> {
  SyncService? _syncService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shake = ref.read(shakeServiceProvider);
      shake.onShake = () {
        final router = ref.read(routerProvider);
        router.go('/home');
      };
      shake.init().then((_) => shake.start());
    });
  }

  @override
  void dispose() {
    ref.read(shakeServiceProvider).dispose();
    _syncService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    final online = ref.watch(isOnlineProvider);

    if (online && _syncService == null) {
      final db = ref.read(databaseProvider);
      _syncService = SyncService(db);
      _syncService!.initialize();
    } else if (!online && _syncService != null) {
      _syncService!.dispose();
      _syncService = null;
    }

    return MaterialApp.router(
      title: 'Timbo',
      debugShowCheckedModeBanner: false,
      theme: TimboTheme.light,
      darkTheme: TimboTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
