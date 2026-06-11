import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/painters/onboarding_illustrations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  int _currentPage = 0;
  final _granted = <Permission, bool>{};
  AnimationController? _dotsController;

  final _pages = const [
    _OnboardingPageData('Welcome', ''),
    _OnboardingPageData('Folders', ''),
    _OnboardingPageData('Canvas', ''),
    _OnboardingPageData('AI', ''),
    _OnboardingPageData('Permissions', ''),
  ];

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _dotsController?.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _complete();
    }
  }

  void _skip() {
    _controller.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    if (!mounted) return;
    context.go('/auth');
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted) {
      setState(() => _granted[permission] = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _currentPage < _pages.length - 1 ? _skip : null,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF9A9A9A),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(),
                  _FoldersPage(),
                  _CanvasPage(),
                  _AIPage(dotsController: _dotsController!),
                  _PermissionsPage(
                    granted: _granted,
                    onRequest: _requestPermission,
                  ),
                ],
              ),
            ),
            _OnboardingDots(current: _currentPage, total: _pages.length),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: _next,
                  style: TextButton.styleFrom(
                    backgroundColor: _currentPage == _pages.length - 1
                        ? const Color(0xFF1A1A1A)
                        : Colors.transparent,
                    foregroundColor: _currentPage == _pages.length - 1
                        ? Colors.white
                        : const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(
                        color: _currentPage == _pages.length - 1
                            ? Colors.transparent
                            : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: GoogleFonts.caveat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String subtitle;
  const _OnboardingPageData(this.title, this.subtitle);
}

class _OnboardingDots extends StatelessWidget {
  final int current;
  final int total;
  const _OnboardingDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomPaint(
            size: const Size(10, 10),
            painter: _DotPainter(isActive: i == current),
          ),
        );
      }),
    );
  }
}

class _DotPainter extends CustomPainter {
  final bool isActive;
  _DotPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 1.5
      ..style = isActive ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), isActive ? 5 : 4, paint);
  }

  @override
  bool shouldRepaint(covariant _DotPainter old) => old.isActive != isActive;
}

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 300,
            child: CustomPaint(painter: PhoneNotebookPainter()),
          ),
          const SizedBox(height: 32),
          Text(
            'Your thoughts, captured instantly.',
            style: GoogleFonts.caveat(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Shake your phone anytime to open a new page and write whatever is on your mind.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF5A5A5A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FoldersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(painter: FolderStackPainter()),
          ),
          const SizedBox(height: 32),
          Text(
            'Organized by day, automatically.',
            style: GoogleFonts.caveat(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Every Timbo you create is saved into today\'s folder. No filing needed. Just write.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF5A5A5A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CanvasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 260,
            child: CustomPaint(painter: CanvasBlocksPainter()),
          ),
          const SizedBox(height: 32),
          Text(
            'Write, snap, record. All in one.',
            style: GoogleFonts.caveat(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Mix text, photos, voice notes, and checklists inside every Timbo however you like.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF5A5A5A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AIPage extends StatelessWidget {
  final AnimationController dotsController;
  const _AIPage({required this.dotsController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 240,
            height: 180,
            child: CustomPaint(painter: AIChatPainter()),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: dotsController,
            builder: (_, __) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final opacity = ((dotsController.value * 3 - i).clamp(0.0, 1.0) * 1.5).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A).withValues(alpha: opacity),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'An AI that actually reads your notes.',
            style: GoogleFonts.caveat(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Ask Timbo AI anything. It reads your notebooks and answers with real context.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF5A5A5A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  final Map<Permission, bool> granted;
  final Future<void> Function(Permission) onRequest;
  const _PermissionsPage({required this.granted, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Before we begin...',
            style: GoogleFonts.caveat(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Timbo needs a few things to work its best.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9A9A9A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _PermissionRow(
            icon: Icons.notifications_outlined,
            name: 'Notifications',
            reason: 'So Timbo can remind you when it matters.',
            permission: Permission.notification,
            granted: granted,
            onRequest: onRequest,
          ),
          const SizedBox(height: 12),
          _PermissionRow(
            icon: Icons.mic_outlined,
            name: 'Microphone',
            reason: 'To record voice notes inside your Timbos.',
            permission: Permission.microphone,
            granted: granted,
            onRequest: onRequest,
          ),
          const SizedBox(height: 12),
          _PermissionRow(
            icon: Icons.camera_alt_outlined,
            name: 'Camera & Photos',
            reason: 'To capture and add images to your Timbos.',
            permission: Permission.camera,
            granted: granted,
            onRequest: onRequest,
          ),
          const SizedBox(height: 12),
          _ShakePermissionRow(),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final IconData icon;
  final String name;
  final String reason;
  final Permission permission;
  final Map<Permission, bool> granted;
  final Future<void> Function(Permission) onRequest;

  const _PermissionRow({
    required this.icon,
    required this.name,
    required this.reason,
    required this.permission,
    required this.granted,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final isGranted = granted[permission] ?? false;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1A1A1A), width: 1.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: const Color(0xFF1A1A1A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.caveat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  reason,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF9A9A9A),
                  ),
                ),
              ],
            ),
          ),
          if (isGranted)
            const Icon(Icons.check_circle_rounded,
              color: Color(0xFF3A7D44), size: 22,
            )
          else
            TextButton(
              onPressed: () => onRequest(permission),
              style: TextButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1A1A1A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: Text(
                'Allow',
                style: GoogleFonts.caveat(
                  fontSize: 14,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShakePermissionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1A1A1A), width: 1.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.vibration, size: 28, color: Color(0xFF1A1A1A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shake to Capture',
                  style: GoogleFonts.caveat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  'Shake your phone anywhere to instantly open a new Timbo.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF9A9A9A),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF3A7D44), size: 14),
              const SizedBox(width: 4),
              const Text(
                'Always on',
                style: TextStyle(
                  color: Color(0xFF3A7D44),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
