import 'package:flutter/material.dart';
import '../config/theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? imagePath;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.imagePath,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 40,
                  color: cs.primary.withValues(alpha: 0.5),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 15,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
