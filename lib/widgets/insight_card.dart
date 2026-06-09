import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';

enum InsightType {
  finance,
  reminder,
  notePattern,
  generalAdvice,
}

extension InsightTypeDisplay on InsightType {
  String get label {
    switch (this) {
      case InsightType.finance:
        return 'Finance Insight';
      case InsightType.reminder:
        return 'Reminder Insight';
      case InsightType.notePattern:
        return 'Note Pattern';
      case InsightType.generalAdvice:
        return 'General Advice';
    }
  }

  IconData get icon {
    switch (this) {
      case InsightType.finance:
        return Icons.wallet_rounded;
      case InsightType.reminder:
        return Icons.notifications_rounded;
      case InsightType.notePattern:
        return Icons.edit_note_rounded;
      case InsightType.generalAdvice:
        return Icons.psychology_rounded;
    }
  }

  Color get color {
    switch (this) {
      case InsightType.finance:
        return const Color(0xFFF59E0B);
      case InsightType.reminder:
        return const Color(0xFF3B82F6);
      case InsightType.notePattern:
        return const Color(0xFF7C5CFC);
      case InsightType.generalAdvice:
        return const Color(0xFF34D399);
    }
  }

  String? get ctaLabel {
    switch (this) {
      case InsightType.finance:
        return 'View Finance →';
      case InsightType.reminder:
        return 'View Reminders →';
      case InsightType.notePattern:
        return 'View Notes →';
      case InsightType.generalAdvice:
        return null;
    }
  }

  String? get ctaRoute {
    switch (this) {
      case InsightType.finance:
        return '/finance';
      case InsightType.reminder:
        return '/reminders';
      case InsightType.notePattern:
        return '/notes';
      case InsightType.generalAdvice:
        return null;
    }
  }
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
                            style: TextStyle(fontFamily: 'Satoshi', 
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
                      style: TextStyle(fontFamily: 'Satoshi', 
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
                          style: TextStyle(fontFamily: 'Satoshi', 
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
                              style: TextStyle(fontFamily: 'Satoshi', 
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
