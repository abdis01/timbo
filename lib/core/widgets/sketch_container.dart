import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class SketchContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const SketchContainer({
    required this.child,
    this.backgroundColor = TimboColors.surface,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 14,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: TimboColors.ink.withValues(alpha: 0.08)),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
