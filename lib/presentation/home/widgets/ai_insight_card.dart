import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../core/widgets/sketch_container.dart';

class AiInsightCard extends StatelessWidget {
  final String insight;

  const AiInsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return SketchContainer(
      onTap: () => context.push('/ai-chat'),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD700), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Timbo AI', style: TimboTypography.label),
                const SizedBox(height: 2),
                Text(
                  insight.isEmpty ? "Start writing — I'll share thoughts as I learn you." : insight,
                  style: GoogleFonts.inter(fontSize: 14, color: TimboColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
