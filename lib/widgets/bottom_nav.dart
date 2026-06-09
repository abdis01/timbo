import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/routes.dart';
import '../config/theme.dart';

class AppBottomNav extends StatefulWidget {
  final String activeRoute;

  const AppBottomNav({super.key, required this.activeRoute});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav>
    with TickerProviderStateMixin {
  final Map<int, AnimationController> _scaleControllers = {};

  static const _tabs = [
    (Icons.home_rounded, 'Home', AppRoutes.home),
    (Icons.description_outlined, 'Notes', AppRoutes.notes),
    (Icons.bar_chart_rounded, 'Finance', AppRoutes.finance),
    (Icons.notifications_outlined, 'Reminders', AppRoutes.reminders),
    (Icons.settings_outlined, 'Settings', AppRoutes.settings),
  ];

  @override
  void dispose() {
    for (var c in _scaleControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  AnimationController _getController(int index) {
    if (!_scaleControllers.containsKey(index)) {
      _scaleControllers[index] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
    }
    return _scaleControllers[index]!;
  }

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
              final isActive = widget.activeRoute == _tabs[i].$3;
              final controller = _getController(i);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (isActive) return;
                  try { HapticFeedback.lightImpact(); } catch (_) {}
                  controller.forward().then((_) => controller.reverse());
                  Navigator.pushReplacementNamed(context, _tabs[i].$3);
                },
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    final scale = controller.value < 0.2
                        ? 1.0
                        : 0.85 + (1.0 - controller.value) * 0.15;
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
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
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
