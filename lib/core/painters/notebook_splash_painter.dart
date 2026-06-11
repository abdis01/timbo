import 'package:flutter/material.dart';

class NotebookSplashPainter extends CustomPainter {
  final double progress;

  const NotebookSplashPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final faintInk = Paint()
      ..color = const Color(0xFFE0D8CC)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    final bookW = w * 0.65;
    final bookH = bookW * 0.72;
    final bookL = (w - bookW) / 2;
    final bookT = (h - bookH) / 2 - 30;

    _drawAnimatedRect(canvas, ink, Rect.fromLTWH(bookL, bookT, bookW / 2, bookH), progress, 0.0, 0.25);

    _drawAnimatedRect(canvas, ink, Rect.fromLTWH(bookL + bookW / 2, bookT, bookW / 2, bookH), progress, 0.25, 0.5);

    if (progress > 0.5) {
      final spineProgress = ((progress - 0.5) / 0.1).clamp(0.0, 1.0);
      canvas.drawLine(
        Offset(bookL + bookW / 2, bookT),
        Offset(bookL + bookW / 2, bookT + bookH * spineProgress),
        ink,
      );
    }

    if (progress > 0.6) {
      final lineProgress = ((progress - 0.6) / 0.25).clamp(0.0, 1.0);
      for (int i = 1; i <= 4; i++) {
        final y = bookT + (bookH / 5) * i;
        final lineEnd = bookL + (bookW / 2 - 16) * lineProgress;
        canvas.drawLine(Offset(bookL + 12, y), Offset(lineEnd, y), faintInk);
      }
    }

    if (progress > 0.85) {
      final pencilProgress = ((progress - 0.85) / 0.15).clamp(0.0, 1.0);
      _drawPencil(canvas, ink, Offset(bookL + bookW - 30, bookT + bookH - 20), pencilProgress);
    }
  }

  void _drawAnimatedRect(Canvas canvas, Paint paint, Rect rect, double progress, double start, double end) {
    if (progress <= start) return;
    final t = ((progress - start) / (end - start)).clamp(0.0, 1.0);
    final perimeter = (rect.width + rect.height) * 2;
    final drawn = perimeter * t;

    final path = Path()..addRect(rect);
    final pathMetrics = path.computeMetrics().first;
    canvas.drawPath(
      pathMetrics.extractPath(0, drawn < pathMetrics.length ? drawn : pathMetrics.length),
      paint,
    );
  }

  void _drawPencil(Canvas canvas, Paint paint, Offset center, double progress) {
    if (progress <= 0) return;
    final start = center;
    final end = Offset(center.dx - 20 * progress, center.dy - 20 * progress);
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant NotebookSplashPainter old) => old.progress != progress;
}
