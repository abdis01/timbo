import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';
import '../../services/gemini_service.dart';
import '../../services/premium_service.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/premium_lock_widget.dart';
import '../../widgets/premium_upgrade_sheet.dart';
import '../../services/firebase_service.dart';
import '../../services/hive_service.dart';

class _InsightData {
  final InsightType type;
  final String text;
  final DateTime generatedAt;

  const _InsightData({
    required this.type,
    required this.text,
    required this.generatedAt,
  });
}

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  List<_InsightData> _insights = [];
  bool _loading = true;
  bool _refreshing = false;
  final Map<int, AnimationController> _animControllers = {};
  final Map<int, Animation<double>> _animations = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generateInsights());
  }

  @override
  void dispose() {
    for (final c in _animControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _setupAnimations() {
    for (final c in _animControllers.values) {
      c.dispose();
    }
    _animControllers.clear();
    _animations.clear();

    for (int i = 0; i < _insights.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      _animControllers[i] = ctrl;
      _animations[i] = CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic);

      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) ctrl.forward();
      });
    }
  }

  Future<void> _generateInsights() async {
    if (_refreshing) return;
    setState(() => _loading = _insights.isEmpty ? true : _refreshing = true);

    List<String> results;
    try {
      results = await Future.wait([
        GeminiService.instance.generateDailyInsight('finance'),
        GeminiService.instance.generateDailyInsight('reminder'),
        GeminiService.instance.generateDailyInsight('note'),
        GeminiService.instance.generateDailyInsight('general'),
      ]);
    } catch (_) {
      if (mounted) {
        setState(() { _loading = false; _refreshing = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timbo is thinking... try again in a moment.')),
        );
      }
      return;
    }

    await PremiumService.instance.useInteraction();

    final now = DateTime.now();
    const types = InsightType.values;
    if (!mounted) return;
    setState(() {
      _insights = List.generate(4, (i) => _InsightData(
        type: types[i],
        text: results[i],
        generatedAt: now,
      ));
      _loading = false;
      _refreshing = false;
    });
    _setupAnimations();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('Timbo Insights',
            style: GoogleFonts.sora(
                fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface)),
        actions: [
          if (!_loading)
            IconButton(
              onPressed: _refreshing ? null : _generateInsights,
                  icon: _refreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white54))
                      : Icon(Icons.refresh_rounded, color: cs.onSurfaceVariant),
              tooltip: 'Refresh insights',
            ),
        ],
      ),
      body: _loading ? _shimmerList() : _insightsList(cs.onSurface, cs.onSurfaceVariant),
    );
  }

  Widget _shimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withValues(alpha: 0.15),
      highlightColor: Colors.grey.withValues(alpha: 0.05),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => _shimmerCard(),
      ),
    );
  }

  Widget _shimmerCard() {
    final cardColor = context.cardColor;
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 32, height: 32, decoration: const BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(8)),
              )),
              const SizedBox(width: 10),
              Container(width: 120, height: 14, decoration: const BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(4)),
              )),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 12,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(4))),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 12,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(4))),
          ),
        ],
      ),
    );
  }

  Widget _insightsList(Color textPrimary, Color textSecondary) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Text(
          'Personalized insights based on your data',
          style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          _formatLastRefresh(),
          style: GoogleFonts.inter(
              fontSize: 11, color: textSecondary.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < _insights.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildAnimatedCard(i, textPrimary, textSecondary),
          ),
      ],
    );
  }

  Widget _buildAnimatedCard(int index,
      Color textPrimary, Color textSecondary) {
    final anim = _animations[index];
    if (anim == null) {
      return _buildCard(index, textPrimary, textSecondary);
    }

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return Opacity(
          opacity: anim.value,
          child: Transform(
            transform: Matrix4.identity()
              ..translate(0.0, 30.0 * (1.0 - anim.value))
              ..rotateZ(0.02 * (1.0 - anim.value)),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: _buildCard(index, textPrimary, textSecondary),
    );
  }

  String _formatLastRefresh() {
    final now = DateTime.now();
    return 'Last refreshed ${DateFormat('MMMM d').format(now)} at ${DateFormat('h:mm a').format(now)}';
  }

  Widget _buildCard(int index, Color textPrimary,
      Color textSecondary) {
    final data = _insights[index];
    final isPremium = PremiumService.instance.isPremium();
    final locked = index > 0 && !isPremium;

    if (locked) {
      return PremiumLockWidget(
        feature: 'Insights',
        description: 'Unlock premium insights with Timbo Premium',
        onUpgrade: () => _showUpgradeSheet(),
        child: InsightCard(
          type: data.type,
          text: data.text,
          generatedAt: data.generatedAt,
          isLocked: true,
          onCtaTap: null,
        ),
      );
    }

    return InsightCard(
      type: data.type,
      text: data.text,
      generatedAt: data.generatedAt,
      onCtaTap: data.type.ctaRoute != null
          ? () => Navigator.pushNamed(context, data.type.ctaRoute!)
          : null,
    );
  }

  void _showUpgradeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PremiumUpgradeSheet(onJoinWaitlist: _joinWaitlist),
    );
  }

  Future<void> _joinWaitlist() async {
    final user = HiveService.instance.getUser();
    final email = user?.email;
    if (email == null || email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please set your email in profile first')),
        );
      }
      return;
    }
    try {
      await FirebaseService.instance.waitlistSignup(email);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You\'re on the waitlist! We\'ll notify you.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Try again.')),
        );
      }
    }
  }
}
