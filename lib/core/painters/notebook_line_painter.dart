import 'package:flutter/material.dart';

class NotebookLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E4DA)
      ..strokeWidth = 0.8;
    double y = 28;
    while (y < size.height) {
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), paint);
      y += 28;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
