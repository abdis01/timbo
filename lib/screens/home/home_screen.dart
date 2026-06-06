import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../providers/finance_provider.dart';
import '../../providers/reminders_provider.dart';
import '../../providers/user_provider.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  late AnimationController _fabPulseController;

  final List<QuickCaptureModel> _recentCaptures = [];

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<FinanceProvider>().loadFinanceData();
    await context.read<RemindersProvider>().loadReminders();

    final captures = HiveService.instance.getAllCaptures();
    setState(() {
      _recentCaptures.clear();
      _recentCaptures.addAll(
        captures.length > 3 ? captures.sublist(0, 3) : captures,
      );
    });

    WidgetService.instance.updateWidget(context.read<FinanceProvider>());
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _fabPulseController.dispose();
    super.dispose();
  }

  void _openQuickCapture() {
    QuickCapturePopup.show(context);
  }
  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final primary = cs.primary;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurfaceVariant;
    final cardColor = context.cardColor;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _buildTopBar(textPrimary, textSecondary, primary, isDark),
                _buildAiMessageCard(primary, cardColor, isDark),
                _buildFinanceCard(primary, cardColor, textPrimary, textSecondary, isDark),
                _buildTodayReminders(cardColor, textPrimary, textSecondary, primary, isDark),
                _buildRecentCaptures(cardColor, textPrimary, textSecondary, primary, isDark),
                _buildInsightsPreview(primary, cardColor, textPrimary, textSecondary, isDark),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
            _buildStackedFab(primary),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(activeRoute: AppRoutes.home),
    );
  }

  Widget _buildTopBar(
    Color textPrimary,
    Color textSecondary,
    Color primary,
    bool isDark,
  ) {
    final user = context.watch<UserProvider>().user;
    final name = user?.name ?? 'Friend';
    final greeting = context.watch<UserProvider>().greeting;
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
              offset: Offset(0, 20 * (1 - anim.clamp(0, 1))),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $name',
                      style: GoogleFonts.sora(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.search_rounded, color: textSecondary),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
              ),
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: textSecondary),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiMessageCard(Color primary, Color cardColor, bool isDark) {
    final messages = [
      'You\'ve got 3 things to tackle today. Let\'s go!',
      'Your spending is 15% lower than last week. Nice!',
      'Don\'t forget to review your budget before the weekend.',
      'You captured 5 ideas yesterday. Great flow!',
    ];
    final msg = messages[DateTime.now().day % messages.length];

    return SliverToBoxAdapter(
        child: _AnimatedCard(
          controller: _staggerController,
          delay: 0.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [primary.withValues(alpha: 0.2), cardColor]
                  : [primary.withValues(alpha: 0.1), cardColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  msg,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceCard(
    Color primary,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
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
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            0,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isDark ? AppShadows.cardDark : AppShadows.cardLight,
          ),
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
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                        Icon(Icons.trending_up_rounded,
                            size: 18, color: textSecondary),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${balance.toStringAsFixed(0)}',
                      style: GoogleFonts.sora(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: balance >= 0
                            ? context.successColor
                            : context.dangerColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _financeLabel(
                          Icons.arrow_upward_rounded,
                          'Income',
                          '\$${income.toStringAsFixed(0)}',
                          context.successColor,
                          textSecondary,
                        ),
                        const SizedBox(width: 24),
                        _financeLabel(
                          Icons.arrow_downward_rounded,
                          'Expenses',
                          '\$${expenses.toStringAsFixed(0)}',
                          context.dangerColor,
                          textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: budgetProgress,
                        backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: isDark ? 0.2 : 0.15),
                        color: budgetProgress > 0.8
                            ? context.dangerColor
                            : primary,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _financeLabel(
    IconData icon,
    String label,
    String amount,
    Color valueColor,
    Color textSecondary,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: valueColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: textSecondary),
        ),
        const SizedBox(width: 6),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayReminders(
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color primary,
    bool isDark,
  ) {
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
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today',
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.reminders),
                    child: Text(
                      'See all',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: todayList.isEmpty
                  ? Center(
                      child: Text(
                        'No reminders today \u{1F389}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: todayList.length,
                      itemBuilder: (_, i) {
                        final r = todayList[i];
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            boxShadow: isDark
                                ? AppShadows.cardDark
                                : AppShadows.cardLight,
                          ),
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
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: textPrimary,
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
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCaptures(
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    Color primary,
    bool isDark,
  ) {
    return SliverToBoxAdapter(
      child: _AnimatedCard(
        controller: _staggerController,
        delay: 0.2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                'Recent Captures',
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ),
            if (_recentCaptures.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  'No captures yet \u{1F4E7}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              )
            else
              ...List.generate(_recentCaptures.length, (i) {
                final c = _recentCaptures[i];
                return Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: i < _recentCaptures.length - 1 ? 8 : 0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: isDark
                          ? AppShadows.cardDark
                          : AppShadows.cardLight,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          c.type == 'voice'
                              ? Icons.mic_rounded
                              : c.type == 'photo'
                                  ? Icons.camera_alt_rounded
                                  : Icons.text_fields_rounded,
                          size: 18,
                          color: primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c.content,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(c.capturedAt),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: textSecondary,
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

  Widget _buildInsightsPreview(
    Color primary,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return SliverToBoxAdapter(
      child: _AnimatedCard(
        controller: _staggerController,
        delay: 0.3,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Timbo Says',
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.insights),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow:
                        isDark ? AppShadows.cardDark : AppShadows.cardLight,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: context.warningColor,
                          size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your most productive time is mornings',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to see full insights',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: textSecondary, size: 20),
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



  Widget _buildStackedFab(Color primary) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FabButton(
            icon: Icons.auto_awesome_rounded,
            color: primary,
            onTap: _openChat,
          ),
          const SizedBox(height: 12),
          _FabButton(
            icon: Icons.add_rounded,
            color: primary,
            onTap: () {
              HapticFeedback.lightImpact();
              _openQuickCapture();
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

// --- REUSABLE ANIMATED CARD ---

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
        final t = ((controller.value - delay) / 0.5).clamp(0.0, 1.0).toDouble();
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

// --- FAB BUTTON WITH SPRING ---

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
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    widget.onTap();
    _controller.forward(from: _controller.value.clamp(0.0, 0.5));
  }

  @override
  Widget build(BuildContext context) {
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
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
