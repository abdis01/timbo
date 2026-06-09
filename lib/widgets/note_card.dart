import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onTap;

  const NoteCard({super.key, required this.note, this.onTap});

  Color _categoryColor(Color defaultColor) {
    switch (note.category.toLowerCase()) {
      case 'personal':
        return CategoryColors.note;
      case 'work':
        return CategoryColors.expense;
      case 'idea':
        return CategoryColors.capture;
      case 'reminder':
        return CategoryColors.reminder;
      default:
        return defaultColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurfaceVariant;
    final cardColor = context.cardColor;
    final accentColor = _categoryColor(cs.primary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: isDark ? AppShadows.cardDark : AppShadows.cardLight,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.md),
                    bottomLeft: Radius.circular(AppRadius.md),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              note.title.isEmpty ? 'Untitled' : note.title,
                              style: TextStyle(fontFamily: 'Satoshi', 
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (note.isPinned)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.push_pin_rounded,
                                  size: 14, color: textSecondary),
                            ),
                        ],
                      ),
                      if (note.content.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          note.content,
                          style: TextStyle(fontFamily: 'Satoshi', 
                            fontSize: 13,
                            color: textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy').format(note.updatedAt),
                            style: TextStyle(fontFamily: 'Satoshi', 
                              fontSize: 11,
                              color: textSecondary.withValues(alpha: 0.7),
                            ),
                          ),
                          const Spacer(),
                          if (note.mediaPaths.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.image_rounded,
                                      size: 14,
                                      color: textSecondary.withValues(alpha: 0.7)),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${note.mediaPaths.length}',
                                    style: TextStyle(fontFamily: 'Satoshi', 
                                      fontSize: 11,
                                      color: textSecondary.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (note.voiceNotePath != null)
                            Icon(Icons.mic_rounded,
                                size: 14,
                                color: textSecondary.withValues(alpha: 0.7)),
                        ],
                      ),
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
}
