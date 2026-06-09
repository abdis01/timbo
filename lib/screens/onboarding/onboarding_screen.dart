import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/image_assets.dart';
import '../../core/widgets/glassmorphism_card.dart';
import '../../config/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  int _currentPage = 0;

  late AnimationController _checkmarkController;
  bool _hasAnimatedCheckmark = false;
  bool _shakeEnabled = false;

  final _pageData = const [
    _PageData(
      image: TimboImages.onboardingCapture,
      title: 'Notes & Quick Capture',
      body: 'Jot down thoughts, snap photos, or record voice memos — even when your phone is locked. Timbo keeps it all organized.',
      icon: Icons.edit_note_rounded,
    ),
    _PageData(
      image: TimboImages.onboardingAi,
      title: 'AI That Knows You',
      body: 'Chat with Timbo about anything. It reads your notes, tracks your spending, and gives insights that actually matter.',
      icon: Icons.psychology_rounded,
    ),
    _PageData(
      image: TimboImages.onboardingRemember,
      title: 'Finance & Reminders',
      body: 'Track expenses by category, set budgets, and never miss a bill. Timbo reminds you so you don\'t have to remember.',
      icon: Icons.account_balance_wallet_rounded,
    ),
    _PageData(
      image: TimboImages.onboarding4,
      title: 'Shake to Capture',
      body: 'Shake your phone anytime to instantly open Quick Capture. No taps, no searching — just shake and capture.',
      icon: Icons.gesture_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < _pageData.length) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _saveShakePref();
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Future<void> _saveShakePref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('shake_to_capture_enabled', _shakeEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageData.length + 1,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  if (i == _pageData.length && !_hasAnimatedCheckmark) {
                    _hasAnimatedCheckmark = true;
                    _checkmarkController.forward();
                  }
                },
                itemBuilder: (context, index) {
                  if (index < _pageData.length) {
                    final isShakePage = index == 3;
                    return _OnboardingPage(
                      data: _pageData[index],
                      pageController: _controller,
                      pageIndex: index,
                      totalPages: _pageData.length,
                      isShakePage: isShakePage,
                      shakeEnabled: _shakeEnabled,
                      onShakeToggle: (v) {
                        setState(() => _shakeEnabled = v);
                        HapticFeedback.lightImpact();
                      },
                    );
                  }
                  return _ReadyPage(
                    checkmarkController: _checkmarkController,
                    onGetStarted: () {
                      try { HapticFeedback.lightImpact(); } catch (_) {}
                      _saveShakePref();
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                  );
                },
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_currentPage < _pageData.length) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
        child: Column(
          children: [
            SmoothPageIndicator(
              controller: _controller,
              count: _pageData.length + 1,
              effect: const ExpandingDotsEffect(
                activeDotColor: Colors.white,
                dotColor: Colors.white30,
                dotWidth: 8,
                dotHeight: 8,
                expansionFactor: 4,
                spacing: 6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _goNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage == _pageData.length - 1 ? 'Ready?' : 'Next',
                  style: const TextStyle(fontFamily: 'Satoshi', 
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _PageData {
  final String image;
  final String title;
  final String body;
  final IconData icon;
  const _PageData({
    required this.image,
    required this.title,
    required this.body,
    required this.icon,
  });
}

class _OnboardingPage extends StatefulWidget {
  final _PageData data;
  final PageController pageController;
  final int pageIndex;
  final int totalPages;
  final bool isShakePage;
  final bool shakeEnabled;
  final ValueChanged<bool> onShakeToggle;

  const _OnboardingPage({
    required this.data,
    required this.pageController,
    required this.pageIndex,
    required this.totalPages,
    required this.isShakePage,
    required this.shakeEnabled,
    required this.onShakeToggle,
  });

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _textAnimController;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _bodySlide;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textAnimController, curve: Curves.easeOut),
    );
    _bodySlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textAnimController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textAnimController.forward();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _textAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 55,
          child: ClipRect(
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        _floatController.value * -12,
                      ),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    widget.data.image,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                if (widget.pageIndex == 1)
                  _PulsingOverlay(controller: _floatController),
                if (widget.pageIndex == 2)
                  _ShimmerTimelineOverlay(),
                if (widget.isShakePage)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Text(
                        '⇆',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 45,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GlassmorphismCard(
              borderRadius: 24,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.data.icon,
                          color: const Color(0xFF149E53),
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: FadeTransition(
                            opacity: _titleOpacity,
                            child: Text(
                              widget.data.title,
                              style: const TextStyle(fontFamily: 'Satoshi', 
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SlideTransition(
                      position: _bodySlide,
                      child: FadeTransition(
                        opacity: _titleOpacity,
                        child: Text(
                          widget.data.body,
                          style: TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    if (widget.isShakePage) ...[
                      const SizedBox(height: 20),
                      _ShakeToggleCard(
                        enabled: widget.shakeEnabled,
                        onToggle: widget.onShakeToggle,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShakeToggleCard extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _ShakeToggleCard({
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? const Color(0xFF149E53).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle_rounded :             Icons.gesture_rounded,
            color: enabled
                ? const Color(0xFF149E53)
                : Colors.white.withValues(alpha: 0.5),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              enabled ? 'Enabled' : 'Enable Shake to Capture',
              style: TextStyle(fontFamily: 'Satoshi', 
                fontSize: 14,
                color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.6),
                fontWeight: enabled ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeThumbColor: const Color(0xFF149E53),
            activeTrackColor: const Color(0xFF149E53).withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _PulsingOverlay extends AnimatedWidget {
  final AnimationController controller;

  const _PulsingOverlay({required this.controller}) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.3,
      child: Transform.scale(
        scale: 0.98 + controller.value * 0.04,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.15),
                blurRadius: 40 * (0.8 + controller.value * 0.2),
                spreadRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerTimelineOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 40,
      top: 20,
      child: Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.3),
        highlightColor: Colors.white.withValues(alpha: 0.6),
        period: const Duration(seconds: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) => Container(
            width: 40,
            height: 8,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          )),
        ),
      ),
    );
  }
}

class _ReadyPage extends StatelessWidget {
  final AnimationController checkmarkController;
  final VoidCallback onGetStarted;

  const _ReadyPage({
    required this.checkmarkController,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 55),
        SizedBox(
          width: 120,
          height: 120,
          child: AnimatedBuilder(
            animation: checkmarkController,
            builder: (context, child) {
              return CustomPaint(
                painter: _CheckmarkPainter(
                  progress: checkmarkController.value,
                ),
                size: const Size(120, 120),
              );
            },
          ),
        ),
        const Spacer(flex: 45),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassmorphismCard(
            borderRadius: 24,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: checkmarkController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: ((checkmarkController.value - 0.8) / 0.2).clamp(0.0, 1.0),
                        child: child,
                      );
                    },
                    child: const Text(
                      'You\'re All Set',
                      style: TextStyle(fontFamily: 'Satoshi', 
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: checkmarkController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: ((checkmarkController.value - 0.85) / 0.15).clamp(0.0, 1.0),
                        child: Text(
                          'Timbo is ready when you are.',
                          style: TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: checkmarkController,
                    builder: (context, child) {
                      final delay = ((checkmarkController.value - 0.85) / 0.15).clamp(0.0, 1.0);
                      return Opacity(
                        opacity: delay,
                        child: Transform.translate(
                          offset: Offset(0, 15 * (1 - delay)),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: onGetStarted,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Let's Go",
                                style: TextStyle(fontFamily: 'Satoshi', 
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;

  _CheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    if (progress < 0.6) {
      final circleProgress = (progress / 0.6).clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * circleProgress,
        false,
        paint,
      );
    }

    if (progress >= 0.6) {
      final checkProgress = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final startX = center.dx - radius * 0.3;
      final startY = center.dy;
      final midX = center.dx - radius * 0.05;
      final midY = center.dy + radius * 0.3;
      final endX = center.dx + radius * 0.4;
      final endY = center.dy - radius * 0.25;

      if (checkProgress < 0.5) {
        final t = checkProgress / 0.5;
        path.moveTo(startX, startY);
        path.lineTo(
          startX + (midX - startX) * t,
          startY + (midY - startY) * t,
        );
      } else {
        final t = (checkProgress - 0.5) / 0.5;
        path.moveTo(startX, startY);
        path.lineTo(midX, midY);
        path.lineTo(
          midX + (endX - midX) * t,
          midY + (endY - midY) * t,
        );
      }
      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
