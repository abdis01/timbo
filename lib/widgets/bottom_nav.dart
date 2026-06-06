import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/routes.dart';
import '../config/theme.dart';

class AppBottomNav extends StatelessWidget {
  final String activeRoute;

  const AppBottomNav({super.key, required this.activeRoute});

  static const _tabs = [
    (Icons.home_rounded, 'Home', AppRoutes.home),
    (Icons.description_outlined, 'Notes', AppRoutes.notes),
    (Icons.bar_chart_rounded, 'Finance', AppRoutes.finance),
    (Icons.notifications_outlined, 'Reminders', AppRoutes.reminders),
    (Icons.settings_outlined, 'Settings', AppRoutes.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final isActive = activeRoute == _tabs[i].$3;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (isActive) return;
                  HapticFeedback.lightImpact();
                  Navigator.pushReplacementNamed(context, _tabs[i].$3);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    color: isActive
                        ? cs.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: isActive ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: Icon(
                          _tabs[i].$1,
                          size: 22,
                          color: isActive ? cs.primary : cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 16 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
