import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'providers/providers.dart';
import 'theme/theme.dart';
import 'screens/profile_screen.dart';
import 'screens/auth_screen.dart';
import 'presentation/splash/splash_screen.dart';
import 'presentation/onboarding/onboarding_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/home/folder_detail_screen.dart';
import 'presentation/timbo/timbo_canvas_screen.dart';
import 'presentation/ai_chat/ai_chat_screen.dart';
import 'presentation/search/search_screen.dart';
import 'presentation/main_shell.dart';
import 'presentation/capture/quick_capture_sheet.dart';
import 'services/sync_service.dart';
import 'services/foreground_shake_detector.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

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
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, __) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (_, __) => const NoTransitionPage(child: SearchScreen()),
          ),
          GoRoute(
            path: '/ai-chat',
            pageBuilder: (_, __) => const NoTransitionPage(child: AiChatScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, __) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/folder/:id',
        parentNavigatorKey: _rootNavigatorKey,
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
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (_, state) => CustomTransitionPage(
          child: TimboCanvasScreen(
            timboId: int.parse(state.pathParameters['id']!),
          ),
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
  ForegroundShakeDetector? _shakeDetector;
  static const _captureChannel = MethodChannel('com.timbo.app/capture');
  static const _shakeChannel = MethodChannel('com.timbo.app/shake');

  @override
  void initState() {
    super.initState();
    _captureChannel.setMethodCallHandler((call) async {
      if (call.method == 'onCapture') {
        _showQuickCapture();
      } else if (call.method == 'onShare') {
        _showQuickCapture(initialText: call.arguments as String?);
      }
      return null;
    });

    // Initialize foreground shake detector
    _shakeDetector = ForegroundShakeDetector(onShakeDetected: _handleForegroundShake);
  }

  Future<void> _handleForegroundShake() async {
    if (!mounted) return;
    
    // Show haptic feedback (already done in detector, but adding snackbar for visibility)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shake detected! Opening new Timbo...'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      // Create a new Timbo in today's folder
      final folder = await ref.read(folderRepositoryProvider).getOrCreateTodayFolder();
      final timboId = await ref.read(timboRepositoryProvider).createTimbo(
        folderId: folder.id,
        title: 'New Timbo',
      );
      
      // Navigate to the new Timbo
      if (mounted) {
        context.go('/timbo/$timboId');
      }
    } catch (e) {
      debugPrint('Error creating Timbo on shake: $e');
    }
  }

  void _showQuickCapture({String? initialText}) {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => QuickCaptureSheet(initialText: initialText),
      );
    }
  }

  @override
  void dispose() {
    _captureChannel.setMethodCallHandler(null);
    _shakeDetector?.dispose();
    _syncService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Start/stop foreground shake detector based on preference
    final shakeEnabled = ref.watch(shakeEnabledProvider);
    if (shakeEnabled) {
      _shakeDetector?.startListening(ref);
    } else {
      _shakeDetector?.stopListening();
    }

    ref.listen(shakeEnabledProvider, (prev, next) {
      if (next) {
        _shakeChannel.invokeMethod('start');
      } else {
        _shakeChannel.invokeMethod('stop');
      }
    });
    ref.listen(isOnlineProvider, (prev, next) {
      if (next && _syncService == null) {
        _syncService = SyncService();
        _syncService!.initialize();
      } else if (!next && _syncService != null) {
        _syncService!.dispose();
        _syncService = null;
      }
    });

    final font = ref.watch(userFontFamilyProvider);
    final router = ref.watch(routerProvider);

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.getFont(font, fontSize: 28, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.getFont(font, fontSize: 22, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.getFont(font, fontSize: 20, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.getFont(font, fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.getFont(font, fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.getFont(font, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.getFont(font, fontSize: 15, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.getFont(font, fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.getFont(font, fontSize: 13, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.getFont(font, fontSize: 14, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.getFont(font, fontSize: 11, fontWeight: FontWeight.w500),
    );
    final theme = timboLightTheme.copyWith(textTheme: textTheme);

    return MaterialApp.router(
      title: 'Timbo',
      debugShowCheckedModeBanner: false,
      theme: theme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
