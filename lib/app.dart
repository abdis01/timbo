import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/user_provider.dart';
import 'services/notification_service.dart';
import 'services/shake_service.dart';
import 'services/sync_service.dart';
import 'services/widget_service.dart';
import 'widgets/quick_capture_popup.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class TimboApp extends StatefulWidget {
  const TimboApp({super.key});

  @override
  State<TimboApp> createState() => _TimboAppState();
}

class _TimboAppState extends State<TimboApp> with WidgetsBindingObserver {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService.navigatorKey = navigatorKey;

    try {
      ShakeService.instance.navigatorKey = navigatorKey;
      ShakeService.instance.initialize();
    } catch (_) {}

    SyncService.instance.initialize();
    SyncService.instance.addListener(_onSyncChanged);

    try {
      WidgetService.instance.initialize();
    } catch (_) {}

    _listenForWidgetClicks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialLaunch();
      try {
        NotificationService.navigateToPendingRoute();
      } catch (_) {}
    });
  }

  Future<void> _checkInitialLaunch() async {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      _handleDeepLink(uri);
    } catch (_) {}
  }

  void _listenForWidgetClicks() {
    try {
      final platform = defaultTargetPlatform;
      if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) return;
      HomeWidget.widgetClicked.listen((Uri? uri) {
        _handleDeepLink(uri);
      }).onError((_) {});
    } catch (_) {}
  }

  void _handleDeepLink(Uri? uri) {
    if (uri == null) return;
    final route = uri.toString();
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    if (route == 'timbo://quick_capture' || route == 'timbo://capture') {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) QuickCapturePopup.show(ctx);
    } else if (route == 'timbo://finance') {
      nav.pushNamedAndRemoveUntil(AppRoutes.finance, (r) => r.settings.name == AppRoutes.home);
    } else if (route == 'timbo://chat') {
      nav.pushNamedAndRemoveUntil(AppRoutes.chat, (r) => r.settings.name == AppRoutes.home);
    } else if (route == 'timbo://home' || route == 'timbo://') {
      nav.pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
    } else if (route == 'timbo://notes') {
      nav.pushNamedAndRemoveUntil(AppRoutes.notes, (r) => r.settings.name == AppRoutes.home);
    } else if (route == 'timbo://reminders') {
      nav.pushNamedAndRemoveUntil(AppRoutes.reminders, (r) => r.settings.name == AppRoutes.home);
    } else if (route == 'timbo://settings') {
      nav.pushNamedAndRemoveUntil(AppRoutes.settings, (r) => r.settings.name == AppRoutes.home);
    } else if (route == 'timbo://insights') {
      nav.pushNamedAndRemoveUntil(AppRoutes.insights, (r) => r.settings.name == AppRoutes.home);
    }
  }

  void _onSyncChanged() {
    setState(() => _isOnline = SyncService.instance.isOnline);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      ShakeService.instance.dispose();
    } catch (_) {}
    SyncService.instance.removeListener(_onSyncChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      try {
        ShakeService.instance.startListening();
      } catch (_) {}
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      try {
        ShakeService.instance.stopListening();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Stack(
          alignment: Alignment.topLeft,
          clipBehavior: Clip.none,
          children: [
            MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Timbo',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode:
                  userProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              initialRoute: AppRoutes.splash,
              onGenerateRoute: AppRoutes.onGenerateRoute,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: child!,
                );
              },
            ),
            Directionality(
              textDirection: TextDirection.ltr,
              child: AnimatedSlide(
                offset: _isOnline ? const Offset(0, -1) : Offset.zero,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: _isOnline ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 350),
                  child: Material(
                    child: Container(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 6),
                      color: Colors.orange.shade800,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'No internet connection',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
