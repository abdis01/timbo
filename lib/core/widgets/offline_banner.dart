import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider);
    if (online) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: TimboColors.ink.withValues(alpha: 0.85),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 14, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            'You\'re offline. Changes will sync when connected.',
            style: TimboTypography.caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
