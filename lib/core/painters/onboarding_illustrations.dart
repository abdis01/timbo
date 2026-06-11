import 'package:flutter/material.dart';

class PhoneNotebookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    final phoneW = w * 0.55;
    final phoneH = phoneW * 1.8;
    final phoneL = (w - phoneW) / 2;
    final phoneT = (h - phoneH) / 2;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(phoneL, phoneT, phoneW, phoneH),
      const Radius.circular(12),
    );
    canvas.drawRRect(rrect, ink);

    final notch = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(w / 2, phoneT + 18), 6, notch);

    final bookW = phoneW * 0.65;
    final bookH = bookW * 1.0;
    final bookL = (w - bookW) / 2;
    final bookT = phoneT + 40;
    final bookR = RRect.fromRectAndRadius(
      Rect.fromLTWH(bookL, bookT, bookW, bookH),
      const Radius.circular(4),
    );
    canvas.drawRRect(bookR, ink);

    final spine = Offset(w / 2, bookT);
    canvas.drawLine(spine, Offset(w / 2, bookT + bookH), ink);

    final faintInk = Paint()
      ..color = const Color(0xFFE0D8CC)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 4; i++) {
      final y = bookT + (bookH / 5) * i;
      canvas.drawLine(Offset(bookL + 8, y), Offset(w / 2 - 8, y), faintInk);
      canvas.drawLine(Offset(w / 2 + 8, y), Offset(bookL + bookW - 8, y), faintInk);
    }

    final bottomBtn = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(w / 2, phoneT + phoneH - 18), 8, bottomBtn);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class FolderStackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    final folderW = w * 0.55;
    final folderH = folderW * 0.7;
    final centerX = w / 2;

    for (int i = 2; i >= 0; i--) {
      final offsetY = i * 12.0;
      final folderL = centerX - folderW / 2 + i * 4;
      final folderT = h / 2 - folderH / 2 - offsetY;

      final body = Paint()
        ..color = const Color(0xFFF5F0E8)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(folderL, folderT + 20, folderW, folderH - 20),
          const Radius.circular(4),
        ),
        body,
      );

      final backLine = Paint()
        ..color = const Color(0xFFE8E4DA)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(folderL, folderT + 16),
        Offset(folderL + folderW, folderT + 16),
        backLine,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(folderL, folderT + 18, folderW, folderH - 18),
          const Radius.circular(4),
        ),
        ink,
      );

      final tabPath = Path()
        ..moveTo(folderL + 8, folderT + 18)
        ..lineTo(folderL + 8, folderT + 6)
        ..lineTo(folderL + folderW * 0.3, folderT + 6)
        ..lineTo(folderL + folderW * 0.3 + 8, folderT + 18);
      canvas.drawPath(tabPath, ink);
    }

    final textPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(centerX - 18, h / 2 + 6), Offset(centerX + 18, h / 2 + 6), textPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class CanvasBlocksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final faintInk = Paint()
      ..color = const Color(0xFFE0D8CC)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    final pageW = w * 0.55;
    final pageH = pageW * 1.3;
    final pageL = (w - pageW) / 2;
    final pageT = (h - pageH) / 2;

    final pageRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pageL, pageT, pageW, pageH),
      const Radius.circular(4),
    );
    canvas.drawRRect(pageRect, ink);

    for (int i = 1; i <= 6; i++) {
      final y = pageT + (pageH / 7) * i;
      canvas.drawLine(Offset(pageL + 12, y), Offset(pageL + pageW - 12, y), faintInk);
    }

    final innerL = pageL + 16;
    var currentY = pageT + 24;

    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(innerL, currentY + 4),
        Offset(innerL + pageW * 0.6, currentY + 4),
        ink,
      );
      currentY += 12;
    }

    currentY += 8;
    canvas.drawRect(
      Rect.fromLTWH(innerL, currentY, 28, 28),
      ink,
    );
    canvas.drawLine(
      Offset(innerL + 4, currentY + 14),
      Offset(innerL + 24, currentY + 14),
      ink,
    );
    currentY += 40;

    canvas.drawRect(
      Rect.fromLTWH(innerL, currentY, 14, 14),
      ink,
    );

    final check = Paint()
      ..color = Color(0xFF3A7D44)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(innerL + 3, currentY + 7),
      Offset(innerL + 6, currentY + 10),
      check,
    );
    canvas.drawLine(
      Offset(innerL + 6, currentY + 10),
      Offset(innerL + 11, currentY + 4),
      check,
    );
    currentY += 24;

    for (int i = 0; i < 5; i++) {
      final barH = [12, 18, 8, 22, 14][i].toDouble();
      canvas.drawRect(
        Rect.fromLTWH(innerL + i * 12, currentY + 16 - barH, 8, barH),
        ink,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class AIChatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    final bubbleW = w * 0.4;
    final bubbleH = bubbleW * 0.55;
    final bubbleL = w / 2 - bubbleW - 12;
    final bubbleT = h / 2 - bubbleH / 2;

    final bubblePath = Path()
      ..moveTo(bubbleL + 8, bubbleT)
      ..lineTo(bubbleL + bubbleW, bubbleT)
      ..quadraticBezierTo(bubbleL + bubbleW + 6, bubbleT, bubbleL + bubbleW + 6, bubbleT + 8)
      ..lineTo(bubbleL + bubbleW + 6, bubbleT + bubbleH - 12)
      ..quadraticBezierTo(bubbleL + bubbleW + 6, bubbleT + bubbleH - 6, bubbleL + bubbleW, bubbleT + bubbleH - 6)
      ..lineTo(bubbleL + 20, bubbleT + bubbleH - 6)
      ..lineTo(bubbleL + 10, bubbleT + bubbleH + 4)
      ..lineTo(bubbleL + 14, bubbleT + bubbleH - 6)
      ..lineTo(bubbleL + 8, bubbleT + bubbleH - 6)
      ..quadraticBezierTo(bubbleL, bubbleT + bubbleH - 6, bubbleL, bubbleT + bubbleH - 12)
      ..lineTo(bubbleL, bubbleT + 8)
      ..quadraticBezierTo(bubbleL, bubbleT, bubbleL + 8, bubbleT)
      ..close();
    canvas.drawPath(bubblePath, ink);

    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(bubbleL + 10, bubbleT + 12 + i * 14),
        Offset(bubbleL + bubbleW * 0.7 - 10, bubbleT + 12 + i * 14),
        ink,
      );
    }

    final starX = w / 2 + 20;
    final starY = h / 2;
    final starPath = Path()
      ..moveTo(starX, starY - 16)
      ..lineTo(starX + 4, starY - 6)
      ..lineTo(starX + 16, starY - 4)
      ..lineTo(starX + 6, starY + 4)
      ..lineTo(starX + 8, starY + 16)
      ..lineTo(starX, starY + 8)
      ..lineTo(starX - 8, starY + 16)
      ..lineTo(starX - 6, starY + 4)
      ..lineTo(starX - 16, starY - 4)
      ..lineTo(starX - 4, starY - 6)
      ..close();
    canvas.drawPath(starPath, ink);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
