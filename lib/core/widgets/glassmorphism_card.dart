import 'dart:io' show Platform;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blurAmount;
  final double opacity;
  final EdgeInsetsGeometry? margin;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.blurAmount = 12,
    this.opacity = 0.08,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? Colors.white.withValues(alpha: opacity)
        : Colors.black.withValues(alpha: opacity * 0.75);

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.3 : 0.2),
            Colors.transparent,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                width: 1,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (!kIsWeb && Platform.isIOS) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }
    return card;
  }
}
