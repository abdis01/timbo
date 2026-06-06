import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class PremiumUpgradeData {
  final IconData icon;
  final String title;
  final String subtitle;
  const PremiumUpgradeData(this.icon, this.title, this.subtitle);
}

class PremiumUpgradeSheet extends StatelessWidget {
  final VoidCallback onJoinWaitlist;

  const PremiumUpgradeSheet({
    super.key,
    required this.onJoinWaitlist,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final gold = context.warningColor;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurfaceVariant;

    const comparisons = [
      _ComparisonData('AI Conversations', '5/day', '50/day'),
      _ComparisonData('Insights', '1/day', 'All unlocked'),
      _ComparisonData('Quick Captures', '20/day', 'Unlimited'),
      _ComparisonData('Cloud Sync', '\u2717', '\u2713'),
      _ComparisonData('Spending Analysis', '\u2717', '\u2713'),
    ];

    final features = [
      PremiumUpgradeData(Icons.chat_rounded, 'Unlimited AI Conversations',
          'Chat with Timbo as much as you want'),
      PremiumUpgradeData(Icons.insights_rounded, 'Advanced Finance Insights',
          'Detailed spending analysis and trends'),
      PremiumUpgradeData(Icons.cloud_rounded, 'Cloud Backup & Sync',
          'Your data safe across all devices'),
      PremiumUpgradeData(Icons.auto_awesome_rounded, 'Priority Insights',
          'Auto-refreshed daily with smart suggestions'),
      PremiumUpgradeData(Icons.bolt_rounded, 'Unlimited Quick Captures',
          'Capture anything, anytime, no limits'),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(Icons.workspace_premium_rounded,
              size: 48, color: gold),
          const SizedBox(height: 12),
          Text(
            'Timbo Premium',
            style: GoogleFonts.sora(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Unlock the full Timbo experience',
            style: GoogleFonts.inter(fontSize: 14, color: textSecondary),
          ),
          const SizedBox(height: 20),
          _ComparisonTable(comparisons: comparisons, gold: gold, cs: cs),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: features.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final f = features[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 20, color: context.successColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.title,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary)),
                          Text(f.subtitle,
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: textSecondary)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gold, gold.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: onJoinWaitlist,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Coming Soon — Join Waitlist',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Maybe Later',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: textSecondary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonData {
  final String feature;
  final String free;
  final String premium;
  const _ComparisonData(this.feature, this.free, this.premium);
}

class _ComparisonTable extends StatelessWidget {
  final List<_ComparisonData> comparisons;
  final Color gold;
  final ColorScheme cs;

  const _ComparisonTable({
    required this.comparisons,
    required this.gold,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: gold.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text('Feature',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('You',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Premium',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black)),
                        ),
                        const SizedBox(height: 2),
                        Text('Most Popular',
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: gold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ...comparisons.map((c) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(c.feature,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: cs.onSurface)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(c.free,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: Colors.grey)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(c.premium,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: gold)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
