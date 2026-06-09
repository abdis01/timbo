import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../core/utils/image_assets.dart';
import '../providers/user_provider.dart';
import '../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bgFade;
  late Animation<double> _bgScale;
  late Animation<double> _textReveal;
  late Animation<double> _lineExpand;
  late Animation<double> _taglineFade;
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _bgFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _bgScale = Tween<double>(begin: 1.05, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _textReveal = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.23, 0.46, curve: Curves.easeInOut),
      ),
    );
    _lineExpand = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.42, 0.61, curve: Curves.easeOut),
      ),
    );
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.54, 0.73, curve: Curves.easeIn),
      ),
    );
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.77, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateAfterDelay();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

      if (!onboardingComplete) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        return;
      }

      final pendingRoute = NotificationService.consumePendingRoute();
      if (pendingRoute != null && mounted) {
        Navigator.pushReplacementNamed(context, pendingRoute);
        return;
      }

      if (!mounted) return;
      await context.read<UserProvider>().loadUser();
      if (!mounted) return;
      final user = context.read<UserProvider>().user;

      if (user == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              Opacity(
                opacity: _bgFade.value,
                child: Transform.scale(
                  scale: _bgScale.value,
                  child: Image.asset(
                    TimboImages.splashBackground,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              // Dark overlay
              Container(color: Colors.black.withValues(alpha: 0.3)),
              // Exit fade overlay
              Opacity(
                opacity: _exitFade.value == 0 ? 0 : 1 - _exitFade.value,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text reveal with line sweep
                      ClipRect(
                        child: Stack(
                          children: [
                            Opacity(
                              opacity: _textReveal.value,
                              child: const Text(
                                'Timbo',
                                style: TextStyle(fontFamily: 'Satoshi', 
                                  fontSize: 72,
                                  color: Colors.white,
                                  letterSpacing: 8.0,
                                ),
                              ),
                            ),
                            // Reveal sweep line
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: IgnorePointer(
                                child: Container(
                                  width: 4,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Divider line
                      ClipRect(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 120 * _lineExpand.value,
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tagline
                      Opacity(
                        opacity: _taglineFade.value,
                        child: Text(
                          'Capture Everything. Forget Nothing.',
                          style: TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // by abdi
                      Opacity(
                        opacity: _taglineFade.value,
                        child: Text(
                          'by abdi.',
                          style: TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.4),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Shake hint
                      Opacity(
                        opacity: _taglineFade.value,
                        child: Text(
                          'Shake to capture anything',
                          style: TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.3),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
