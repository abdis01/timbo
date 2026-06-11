import 'package:flutter/material.dart';

class TimboColors {
  // Backgrounds
  static const appBackground = Color(0xFFF5F0E8);
  static const surface = Color(0xFFFEFCF7);
  static const surfaceAlt = Color(0xFFFFFDE8);

  // Text (ink)
  static const ink = Color(0xFF1A1A1A);
  static const inkLight = Color(0xFF5A5A5A);
  static const inkFaint = Color(0xFFA0A0A0);

  // Borders
  static const border = Color(0xFF2A2A2A);
  static const borderLight = Color(0xFFC8C0B0);

  // Notebook lines
  static const notebookLine = Color(0xFFE8E4DA);

  // Dark mode
  static const darkBackground = Color(0xFF1C1A17);
  static const darkSurface = Color(0xFF2A2620);
  static const darkText = Color(0xFFF0EDE8);

  // Functional
  static const checked = Color(0xFF888888);
  static const reminderBadge = Color(0xFF1A1A1A);

  // Backward-compatible aliases (for existing screen imports)
  static const primary = ink;
  static const textPrimary = ink;
  static const textSecondary = inkLight;
  static const primaryLight = Color(0xFF4A4A4A);
}
