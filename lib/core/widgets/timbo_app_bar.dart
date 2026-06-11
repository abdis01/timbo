import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class TimboAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: TimboColors.appBackground,
        border: Border(
          bottom: BorderSide(color: TimboColors.borderLight, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: TimboColors.ink,
              child: Text('F', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Caveat', fontWeight: FontWeight.w700)),
            ),
          ),
          Expanded(
            child: Center(
              child: Text('Timbo', style: TimboTypography.heading2),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: TimboColors.ink),
            onPressed: () => context.push('/search'),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => context.push('/ai-chat'),
            child: Stack(
              children: [
                const Icon(Icons.chat_bubble_outline, color: TimboColors.ink, size: 24),
                Positioned(
                  top: 0, right: 0,
                  child: Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
