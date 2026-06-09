import 'package:flutter/material.dart';
import '../config/theme.dart';

class RetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  const RetryWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.cloud_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 40,
                color: context.warningColor,
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
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? DesignSystemColors.darkWarning.withValues(alpha: 0.2)
                    : DesignSystemColors.lightWarning.withValues(alpha: 0.15),
                foregroundColor: isDark
                    ? DesignSystemColors.darkWarning
                    : DesignSystemColors.lightWarning,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  side: BorderSide(
                    color: isDark
                        ? DesignSystemColors.darkWarning.withValues(alpha: 0.3)
                        : DesignSystemColors.lightWarning.withValues(alpha: 0.3),
                  ),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
