import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/providers.dart';
import 'providers/folders_provider.dart';
import 'providers/timbos_provider.dart';
import 'config/theme.dart';
import 'screens/profile_screen.dart';
import 'screens/auth_screen.dart';
import 'presentation/splash/splash_screen.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/home/folder_detail_screen.dart';
import 'presentation/timbo/timbo_canvas_screen.dart';
import 'presentation/ai_chat/ai_chat_screen.dart';
import 'presentation/search/search_screen.dart';
import 'services/sync_service.dart';
import 'services/shake_service.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

Widget _slideUpTransition(Widget child, Animation<double> animation) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: FadeTransition(opacity: animation, child: child),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (_, __) => CustomTransitionPage(
          child: const SplashScreen(),
          transitionsBuilder: (_, a, __, c) => _slideUpTransition(c, a),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, __) => CustomTransitionPage(
          child: const OnboardingScreen(),
          transitionsBuilder: (_, a, __, c) => _slideUpTransition(c, a),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (_, __) => CustomTransitionPage(
          child: const AuthScreen(),
          transitionsBuilder: (_, a, __, c) => _slideUpTransition(c, a),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (_, __) => const NoTransitionPage(child: HomeScreen()),
      ),
      GoRoute(
        path: '/folder/:id',
        pageBuilder: (_, state) => CustomTransitionPage(
          child: FolderDetailScreen(
            folderId: int.parse(state.pathParameters['id']!),
          ),
          transitionsBuilder: (_, a, __, c) => _slideUpTransition(c, a),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/timbo/:id',
        pageBuilder: (_, state) => CustomTransitionPage(
          child: TimboCanvasScreen(
            timboId: int.parse(state.pathParameters['id']!),
          ),
          transitionsBuilder: (_, a, __, c) => _slideUpTransition(c, a),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/ai-chat',
        pageBuilder: (_, __) => CustomTransitionPage(
          child: const AiChatScreen(),
          transitionsBuilder: (_, a, __, c) => _slideUpTransition(c, a),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (_, __) => CustomTransitionPage(
          child: const SearchScreen(),
          transitionsBuilder: (_, a, __, c) => _slideUpTransition(c, a),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (_, __) => CustomTransitionPage(
          child: const ProfileScreen(),
          transitionsBuilder: (_, a, __, c) => _slideUpTransition(c, a),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
    ],
  );
});

class TimboApp extends ConsumerStatefulWidget {
  const TimboApp({super.key});

  @override
  ConsumerState<TimboApp> createState() => _TimboAppState();
}

class _TimboAppState extends ConsumerState<TimboApp> {
  SyncService? _syncService;
  StreamSubscription? _shakeSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shakeSubscription = ref.read(shakeServiceProvider).onShake.listen((_) async {
        _showShakeFlash();
        final folder = await ref.read(folderRepositoryProvider).getOrCreateTodayFolder();
        final timboId = await ref.read(timboRepositoryProvider).createTimbo(folderId: folder.id);
        if (mounted) ref.read(routerProvider).go('/timbo/$timboId');
      });
    });
  }

  void _showShakeFlash() {
    final context = _rootNavigatorKey.currentContext;
    if (context == null) return;
    try { HapticFeedback.lightImpact(); } catch (_) {}
    try {
      OverlayEntry entry = OverlayEntry(
        builder: (_) => IgnorePointer(
          child: AnimatedOpacity(
            opacity: 0.0,
            duration: const Duration(milliseconds: 80),
            child: Container(color: Colors.white.withValues(alpha: 0.15)),
          ),
        ),
      );
      Overlay.of(context).insert(entry);
      Future.delayed(const Duration(milliseconds: 80), entry.remove);
    } catch (_) {}
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    _syncService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(isOnlineProvider, (prev, next) {
      if (next && _syncService == null) {
        _syncService = SyncService();
        _syncService!.initialize();
      } else if (!next && _syncService != null) {
        _syncService!.dispose();
        _syncService = null;
      }
    });

    final isDark = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

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
