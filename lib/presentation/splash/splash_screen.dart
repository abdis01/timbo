import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/providers.dart';
import '../../core/painters/notebook_splash_painter.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _textController;
  late AnimationController _subtitleController;
  late AnimationController _signatureController;

  late Animation<double> _drawAnim;
  late Animation<double> _textOpacity;
  late Animation<double> _textScale;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _signatureOpacity;
  late Animation<Offset> _signatureSlide;

  @override
  void initState() {
    super.initState();

    _drawController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _subtitleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _signatureController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _drawAnim = CurvedAnimation(parent: _drawController, curve: Curves.easeInOut);
    _textOpacity = CurvedAnimation(parent: _textController, curve: Curves.easeOut);
    _textScale = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );
    _subtitleOpacity = CurvedAnimation(parent: _subtitleController, curve: Curves.easeOut);
    _signatureOpacity = CurvedAnimation(parent: _signatureController, curve: Curves.easeOut);
    _signatureSlide = Tween<Offset>(
      begin: const Offset(0, 20), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _signatureController, curve: Curves.easeOutCubic));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _drawController.forward();
    await _textController.forward();
    await _subtitleController.forward();
    _signatureController.forward();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    _navigate();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await ref.read(sharedPrefsProvider.future);
    if (!mounted) return;
    final hasOnboarded = prefs.getBool('hasCompletedOnboarding') ?? false;

    if (!hasOnboarded) {
      context.go('/onboarding');
      return;
    }
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        context.go('/home');
      } else {
        context.go('/auth');
      }
    } catch (_) {
      if (!mounted) return;
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _drawController.dispose();
    _textController.dispose();
    _subtitleController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _drawAnim,
              builder: (_, __) => CustomPaint(
                size: const Size(220, 160),
                painter: NotebookSplashPainter(_drawAnim.value),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _textController,
              builder: (_, __) => Opacity(
                opacity: _textOpacity.value,
                child: Transform.scale(
                  scale: _textScale.value,
                  child: Text(
                    'Timbo',
                    style: GoogleFonts.caveat(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _subtitleController,
              builder: (_, __) => Opacity(
                opacity: _subtitleOpacity.value,
                child: Text(
                  'your smart notebook',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF5A5A5A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _signatureController,
              builder: (_, __) => Opacity(
                opacity: _signatureOpacity.value,
                child: SlideTransition(
                  position: _signatureSlide,
                  child: Transform.rotate(
                    angle: -0.08,
                    child: Text(
                      'ABDI',
                      style: GoogleFonts.caveat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8A8A8A),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
