import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimboColors {
  static const background = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFF4CAF50);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF757575);
  static const aiAccent = Color(0xFFFFD700);
  static const darkBackground = Color(0xFF1A1A1A);
  static const darkSurface = Color(0xFF2A2A2A);
}

class TimboTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: TimboColors.background,
    colorScheme: const ColorScheme.light(
      primary: TimboColors.primary,
      secondary: TimboColors.primaryLight,
      surface: TimboColors.background,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: TimboColors.textPrimary,
      onSurfaceVariant: TimboColors.textSecondary,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: TimboColors.textPrimary),
      headlineMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: TimboColors.textPrimary),
      bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: TimboColors.textPrimary),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: TimboColors.textSecondary),
    ),
    cardTheme: CardThemeData(
      color: TimboColors.surface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TimboColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: TimboColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TimboColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: TimboColors.surface,
      selectedItemColor: TimboColors.primary,
      unselectedItemColor: TimboColors.textSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: TimboColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: TimboColors.primaryLight,
      secondary: TimboColors.primary,
      surface: TimboColors.darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onSurfaceVariant: TimboColors.textSecondary,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
      headlineMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: TimboColors.textSecondary),
    ),
    cardTheme: CardThemeData(
      color: TimboColors.darkSurface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: TimboColors.darkSurface,
      selectedItemColor: TimboColors.primaryLight,
      unselectedItemColor: TimboColors.textSecondary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
