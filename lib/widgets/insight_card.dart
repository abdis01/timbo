import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';

class InsightType {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String? ctaLabel;
  final String? ctaRoute;

  const InsightType({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.ctaLabel,
    this.ctaRoute,
  });

  static const finance = InsightType(
    id: 'finance',
    label: 'Finance Insight',
    icon: Icons.wallet_rounded,
    color: Color(0xFFF59E0B),
    ctaLabel: 'View Finance →',
    ctaRoute: '/finance',
  );

  static const reminder = InsightType(
    id: 'reminder',
    label: 'Reminder Insight',
    icon: Icons.notifications_rounded,
    color: Color(0xFF3B82F6),
    ctaLabel: 'View Reminders →',
    ctaRoute: '/reminders',
  );

  static const notePattern = InsightType(
    id: 'note_pattern',
    label: 'Note Pattern',
    icon: Icons.edit_note_rounded,
    color: Color(0xFF7C5CFC),
    ctaLabel: 'View Notes →',
    ctaRoute: '/notes',
  );

  static const generalAdvice = InsightType(
    id: 'general_advice',
    label: 'General Advice',
    icon: Icons.lightbulb_rounded,
    color: Color(0xFF34D399),
  );

  static const values = [finance, reminder, notePattern, generalAdvice];
}

class InsightCard extends StatelessWidget {
  final InsightType type;
  final String text;
  final DateTime generatedAt;
  final VoidCallback? onCtaTap;
  final bool isLocked;

  const InsightCard({
    super.key,
    required this.type,
    required this.text,
    required this.generatedAt,
    this.onCtaTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final cardColor = context.cardColor;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: isLocked ? cardColor.withValues(alpha: 0.5) : cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: type.color.withValues(alpha: isLocked ? 0.15 : 0.3),
          width: 1,
        ),
        boxShadow: isDark ? AppShadows.cardDark : AppShadows.cardLight,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isLocked
                    ? type.color.withValues(alpha: 0.3)
                    : type.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  bottomLeft: Radius.circular(AppRadius.md),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: type.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(type.icon, size: 18, color: type.color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            type.label,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textPrimary.withValues(alpha: isLocked ? 0.5 : 1),
                            ),
                          ),
                        ),
                        if (isLocked)
                          Icon(Icons.lock_rounded,
                              size: 16, color: textSecondary.withValues(alpha: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.45,
                        color: isLocked
                            ? textSecondary.withValues(alpha: 0.4)
                            : textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Generated ${DateFormat('MMMM d').format(generatedAt)} at ${DateFormat('h:mm a').format(generatedAt)}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                        const Spacer(),
                        if (type.ctaLabel != null && !isLocked)
                          GestureDetector(
                            onTap: onCtaTap,
                            child: Text(
                              type.ctaLabel!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: type.color,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
