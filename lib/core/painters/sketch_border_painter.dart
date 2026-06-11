import 'dart:math' as math;
import 'package:flutter/material.dart';

class SketchBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  const SketchBorderPainter({
    this.color = const Color(0xFF2A2A2A),
    this.strokeWidth = 1.5,
    this.radius = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final random = math.Random(42);
    double w(double max) => (random.nextDouble() - 0.5) * max;

    final path = Path()
      ..moveTo(radius + w(1.5), w(1.5))
      ..lineTo(size.width - radius + w(1.5), w(1.5))
      ..quadraticBezierTo(size.width + w(1), w(1), size.width + w(1.5), radius + w(1.5))
      ..lineTo(size.width + w(1.5), size.height - radius + w(1.5))
      ..quadraticBezierTo(size.width + w(1), size.height + w(1), size.width - radius + w(1.5), size.height + w(1.5))
      ..lineTo(radius + w(1.5), size.height + w(1.5))
      ..quadraticBezierTo(w(1), size.height + w(1), w(1.5), size.height - radius + w(1.5))
      ..lineTo(w(1.5), radius + w(1.5))
      ..quadraticBezierTo(w(1), w(1), radius + w(1.5), w(1.5));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
