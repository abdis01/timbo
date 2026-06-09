import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../core/widgets/glassmorphism_card.dart';
import '../../providers/finance_provider.dart';
import '../../providers/reminders_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/gemini_service.dart';
import '../../services/hive_service.dart';
import '../../services/widget_service.dart';
import '../../models/quick_capture_model.dart';
import '../../widgets/quick_capture_popup.dart';
import '../../widgets/bottom_nav.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late AnimationController _fabPulseController;
  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final Random _random = Random();
  StreamSubscription? _accelerometerSub;
  double _tiltX = 0;
  double _tiltY = 0;
  final List<QuickCaptureModel> _recentCaptures = [];
  String? _dailyInsight;
  bool _insightLoading = false;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initParticles();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
      _loadData();
    });

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        _accelerometerSub = accelerometerEventStream().listen((event) {
          if (mounted) {
            setState(() {
              _tiltX = (event.x.clamp(-5.0, 5.0) / 5.0) * 2;
              _tiltY = (event.y.clamp(-5.0, 5.0) / 5.0) * 2;
            });
          }
        });
      } catch (_) {
        _accelerometerSub = null;
      }
    }
  }

  void _initParticles() {
    _particles.addAll(List.generate(25, (i) => _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 2 + 1,
      speed: _random.nextDouble() * 0.002 + 0.001,
      opacity: _random.nextDouble() * 0.4 + 0.1,
    )));
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _fabPulseController.dispose();
    _particleController.dispose();
    _accelerometerSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await context.read<FinanceProvider>().loadFinanceData();
    if (!mounted) return;
    await context.read<RemindersProvider>().loadReminders();
    if (!mounted) return;
    final captures = HiveService.instance.getAllCaptures();
    setState(() {
      _recentCaptures.clear();
      _recentCaptures.addAll(
        captures.length > 3 ? captures.sublist(0, 3) : captures,
      );
    });
    WidgetService.instance.updateWidget(context.read<FinanceProvider>());

    await _loadDailyInsight();
  }

  Future<void> _loadDailyInsight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final cachedDate = prefs.getString('insight_date');
      final cachedInsight = prefs.getString('daily_insight');

      if (cachedDate == today && cachedInsight != null) {
        if (mounted) setState(() => _dailyInsight = cachedInsight);
        return;
      }

      setState(() => _insightLoading = true);
      final insight = await GeminiService.instance.generateDailyInsight('productivity');
      if (mounted) {
        await prefs.setString('insight_date', today);
        await prefs.setString('daily_insight', insight);
        setState(() {
          _dailyInsight = insight;
          _insightLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _insightLoading = false);
    }
  }

  void _openQuickCapture() => QuickCapturePopup.show(context);
  void _openChat() => Navigator.push(
    context, MaterialPageRoute(builder: (_) => const ChatScreen()),
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),
          // Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildTopBar(cs),
                _buildAiMessageCard(cs),
                _buildFinanceCard(cs),
                _buildTodayReminders(cs),
                _buildRecentCaptures(cs),
                _buildInsightsPreview(cs),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          ),
          _buildFab(cs),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(activeRoute: AppRoutes.home),
    );
  }

  Widget _buildAnimatedBackground() {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_tiltY * 0.0174533)
            ..rotateY(-_tiltX * 0.0174533),
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withValues(alpha: 0.05),
                      cs.surface,
                      cs.primary.withValues(alpha: 0.03),
                    ],
                  ),
                ),
              ),
              ..._particles.map((p) {
                p.y -= p.speed;
                if (p.y < -0.05) {
                  p.y = 1.05;
                  p.x = _random.nextDouble();
                }
                return Positioned(
                  left: p.x * screenSize.width,
                  top: p.y * screenSize.height,
                  child: Opacity(
                    opacity: p.opacity,
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(ColorScheme cs) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final name = user?.name ?? 'Friend';
    final greeting = userProvider.greeting;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _staggerController,
        builder: (context, child) {
          final anim = _staggerController.value;
          return Opacity(
            opacity: anim.clamp(0, 1),
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - anim.clamp(0, 1))),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: TextStyle(fontFamily: 'Satoshi', 
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Shimmer.fromColors(
                      baseColor: cs.onSurface.withValues(alpha: 0.2),
                      highlightColor: cs.onSurface.withValues(alpha: 0.6),
                      period: const Duration(seconds: 3),
                      direction: ShimmerDirection.ltr,
                      child: Text(
                        name,
                        style: TextStyle(fontFamily: 'Satoshi', 
                          fontSize: 32,
                          color: cs.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(fontFamily: 'Satoshi', 
                        fontSize: 12,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiMessageCard(ColorScheme cs) {
    final messages = [
      "You've got 3 things to tackle today. Let's go!",
      'Your spending is 15% lower than last week. Nice!',
      "Don't forget to review your budget before the weekend.",
      'You captured 5 ideas yesterday. Great flow!',
    ];
    final msg = messages[DateTime.now().day % messages.length];

    return SliverToBoxAdapter(
      child: _AnimatedCard(
        controller: _staggerController,
        delay: 0.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassmorphismCard(
            blurAmount: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.psychology_rounded, color: cs.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: _TypewriterText(
                      text: msg,
                      style: TextStyle(fontFamily: 'Satoshi', 
                        fontSize: 14,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceCard(ColorScheme cs) {
    final finance = context.watch<FinanceProvider>();
    final income = finance.monthlyIncome;
    final expenses = finance.monthlyExpenses;
    final balance = finance.balance;
    final budgetProgress = finance.getBudgetProgress(5000);
    final isLoading = finance.isLoading;

    return SliverToBoxAdapter(
      child: _AnimatedCard(
        controller: _staggerController,
        delay: 0.2,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: GlassmorphismCard(
            child: isLoading
                ? _buildShimmer()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'This Month',
                            style: TextStyle(fontFamily: 'Satoshi', 
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          Icon(Icons.trending_up_rounded,
                              size: 18, color: cs.onSurfaceVariant),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _CountUpNumber(
                        target: balance,
                        style: TextStyle(fontFamily: 'Satoshi', 
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: balance >= 0
                              ? context.successColor
                              : context.dangerColor,
                        ),
                        onComplete: () {},
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _financeLabel(
                            Icons.arrow_upward_rounded,
                            'Income',
                            _formatAmount(income),
                            context.successColor,
                            cs,
                          ),
                          const SizedBox(width: 24),
                          _financeLabel(
                            Icons.arrow_downward_rounded,
                            'Expenses',
                            _formatAmount(expenses),
                            context.dangerColor,
                            cs,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: budgetProgress,
                          backgroundColor: cs.onSurface.withValues(alpha: 0.1),
                          color: budgetProgress > 0.8
                              ? context.dangerColor
                              : cs.primary,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _financeLabel(IconData icon, String label, String amount, Color color, ColorScheme cs) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontFamily: 'Satoshi', fontSize: 12, color: cs.onSurfaceVariant.withValues(alpha: 0.7))),
        const SizedBox(width: 6),
        Text(amount,
            style: TextStyle(fontFamily: 'Satoshi', 
                fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  String _formatAmount(double amt) {
    if (amt >= 1000) {
      return '\$${(amt / 1000).toStringAsFixed(1)}k';
    }
    return '\$${amt.toStringAsFixed(0)}';
  }

  Widget _buildTodayReminders(ColorScheme cs) {
    final reminders = context.watch<RemindersProvider>();
    final todayList = reminders.todayReminders;

    return SliverToBoxAdapter(
      child: _AnimatedCard(
        controller: _staggerController,
        delay: 0.1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today',
                    style: TextStyle(fontFamily: 'Satoshi', 
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.reminders),
                    child: Text(
                      'See all',
                      style: TextStyle(fontFamily: 'Satoshi', 
                        fontSize: 13,
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: todayList.isEmpty
                    ? Center(
                        child: Text(
                          'No reminders today \u{1F389}',
                          style: TextStyle(fontFamily: 'Satoshi', 
                              fontSize: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: todayList.length,
                        itemBuilder: (_, i) {
                          final r = todayList[i];
                          return GlassmorphismCard(
                            borderRadius: 12,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(right: 12),
                            child: SizedBox(
                              width: 140,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: r.isCompleted
                                              ? context.successColor
                                              : context.warningColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          r.title,
                                          style: TextStyle(fontFamily: 'Satoshi', 
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: cs.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat('h:mm a').format(r.scheduledAt),
                                    style: TextStyle(fontFamily: 'Satoshi', 
                                      fontSize: 11,
                                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCaptures(ColorScheme cs) {
    return SliverToBoxAdapter(
      child: _AnimatedCard(
        controller: _staggerController,
        delay: 0.2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Text(
                'Recent Captures',
                style: TextStyle(fontFamily: 'Satoshi', 
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            if (_recentCaptures.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'No captures yet \u{1F4E7}',
                  style: TextStyle(fontFamily: 'Satoshi', 
                      fontSize: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
                ),
              )
            else
              ...List.generate(_recentCaptures.length, (i) {
                final c = _recentCaptures[i];
                return Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: i < _recentCaptures.length - 1 ? 8 : 0,
                  ),
                  child: GlassmorphismCard(
                    borderRadius: 12,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          c.type == 'voice'
                              ? Icons.mic_rounded
                              : c.type == 'photo'
                                  ? Icons.camera_alt_rounded
                                  : Icons.text_fields_rounded,
                          size: 18,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c.content,
                            style: TextStyle(fontFamily: 'Satoshi', 
                              fontSize: 13,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(c.capturedAt),
                          style: TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 11,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsPreview(ColorScheme cs) {
    return SliverToBoxAdapter(
      child: _AnimatedCard(
        controller: _staggerController,
        delay: 0.3,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Timbo Says',
                style: TextStyle(fontFamily: 'Satoshi', 
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.insights),
                child: GlassmorphismCard(
                  child: Row(
                    children: [
                      Icon(Icons.psychology_rounded,
                          color: context.warningColor, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _dailyInsight ?? (_insightLoading ? 'Thinking...' : 'Good morning! Start your day strong.'),
                              style: TextStyle(fontFamily: 'Satoshi', 
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap for more',
                              style: TextStyle(fontFamily: 'Satoshi', 
                                fontSize: 12,
                                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: cs.onSurfaceVariant, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab(ColorScheme cs) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FabButton(
            icon: Icons.psychology_rounded,
            color: cs.primary,
            onTap: _openChat,
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _fabPulseController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.2 * _fabPulseController.value),
                      blurRadius: 20 * _fabPulseController.value,
                      spreadRadius: 5 * _fabPulseController.value,
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: 1.0 + 0.02 * _fabPulseController.value,
                  child: _FabButton(
                    icon: Icons.add_rounded,
                    color: cs.primary,
                    onTap: () {
                      try { HapticFeedback.lightImpact(); } catch (_) {}
                      _openQuickCapture();
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 120,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          _shimmerBox(100, 14),
          const SizedBox(width: 24),
          _shimmerBox(100, 14),
        ]),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _shimmerBox(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  final double size;
  final double speed;
  double opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _AnimatedCard extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;
  const _AnimatedCard({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = ((controller.value - delay) / 0.5).clamp(0.0, 1.0);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 30.0 * (1.0 - Curves.easeOutCubic.transform(t))),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _CountUpNumber extends StatefulWidget {
  final double target;
  final TextStyle style;
  final VoidCallback onComplete;

  const _CountUpNumber({
    required this.target,
    required this.style,
    required this.onComplete,
  });

  @override
  State<_CountUpNumber> createState() => _CountUpNumberState();
}

class _CountUpNumberState extends State<_CountUpNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.addListener(() {
      if (_controller.isCompleted) widget.onComplete();
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = (widget.target * _animation.value).toInt();
        final prefix = widget.target >= 0 ? '\$' : '-\$';
        final display = value >= 1000
            ? '$prefix${(value / 1000).toStringAsFixed(1)}k'
            : '$prefix${value.toStringAsFixed(0)}';
        return Text(display, style: widget.style);
      },
    );
  }
}

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _TypewriterText({required this.text, required this.style});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _charsToShow = 0;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.text.length * 30),
    );
    _controller.addListener(() {
      setState(() {
        _charsToShow = (_controller.value * widget.text.length).ceil();
      });
    });
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showCursor = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayText = widget.text.substring(0, _charsToShow.clamp(0, widget.text.length));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(displayText, style: widget.style),
        if (_showCursor && _charsToShow < widget.text.length)
          Container(
            width: 2,
            height: 16,
            color: cs.onSurface,
          ),
      ],
    );
  }
}

class _FabButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FabButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_FabButton> createState() => _FabButtonState();
}

class _FabButtonState extends State<_FabButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.addListener(() {
      setState(() {
        _scale = _controller.value < 0.3
            ? 1.0 - (0.3 - _controller.value) / 0.3 * 0.1
            : 0.9 + (_controller.value - 0.3) / 0.7 * 0.2;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.value = 0.0;
    _controller.forward();
    try { HapticFeedback.lightImpact(); } catch (_) {}
  }

  void _onTapUp(TapUpDetails details) {
    widget.onTap();
    _controller.forward(from: _controller.value.clamp(0.0, 0.5));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(widget.icon, color: cs.onPrimary, size: 24),
        ),
      ),
    );
  }
}
