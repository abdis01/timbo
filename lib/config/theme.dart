import 'package:flutter/material.dart';
import '../theme/theme.dart' as new_theme;

final TimboTheme = _TimboTheme();
final TimboColors = _TimboColors();

class _TimboColors {
  Color get primary => const Color(0xFF1A1A1A);
  Color get textPrimary => const Color(0xFF1A1A1A);
  Color get textSecondary => const Color(0xFF5A5A5A);
  Color get background => const Color(0xFFF5F0E8);
  Color get surface => const Color(0xFFFEFCF7);
}

class _TimboTheme {
  ThemeData get light => new_theme.timboLightTheme;
}
