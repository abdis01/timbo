import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/reminder_model.dart';

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onToggleComplete,
    this.onDelete,
  });

  Color _priorityColor(BuildContext context) {
    switch (reminder.priority) {
      case 'high':
        return context.dangerColor;
      case 'medium':
        return context.warningColor;
      default:
        return context.textSecondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurfaceVariant;
    final cardColor = context.cardColor;
    final priorityColor = _priorityColor(context);

    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: context.dangerColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: isDark ? AppShadows.cardDark : AppShadows.cardLight,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggleComplete,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: reminder.isCompleted
                        ? context.successColor
                        : textSecondary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  color: reminder.isCompleted
                      ? context.successColor
                      : Colors.transparent,
                ),
                child: reminder.isCompleted
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: priorityColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(fontFamily: 'Satoshi', 
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: reminder.isCompleted
                          ? textSecondary
                          : textPrimary,
                      decoration: reminder.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        DateFormat('h:mm a').format(reminder.scheduledAt),
                        style: TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 12, color: textSecondary),
                      ),
                      if (reminder.isRecurring) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.repeat_rounded,
                            size: 14, color: textSecondary),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
