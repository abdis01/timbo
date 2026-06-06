import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignSystemColors {
  // DARK MODE
  static const darkBackground = Color(0xFF0F1117);
  static const darkSurface = Color(0xFF1A1D27);
  static const darkCard = Color(0xFF212435);
  static const darkPrimary = Color(0xFF4F8EF7);
  static const darkSecondary = Color(0xFF7C5CFC);
  static const darkSuccess = Color(0xFF34D399);
  static const darkDanger = Color(0xFFF87171);
  static const darkWarning = Color(0xFFFBBF24);
  static const darkTextPrimary = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFF94A3B8);

  // LIGHT MODE
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightPrimary = Color(0xFF3B82F6);
  static const lightSecondary = Color(0xFF7C3AED);
  static const lightSuccess = Color(0xFF10B981);
  static const lightDanger = Color(0xFFEF4444);
  static const lightWarning = Color(0xFFF59E0B);
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
}

extension ThemeColors on BuildContext {
  Color get successColor => Theme.of(this).brightness == Brightness.dark
      ? DesignSystemColors.darkSuccess
      : DesignSystemColors.lightSuccess;
  Color get warningColor => Theme.of(this).brightness == Brightness.dark
      ? DesignSystemColors.darkWarning
      : DesignSystemColors.lightWarning;
  Color get dangerColor => colorScheme.error;
  Color get cardColor => Theme.of(this).brightness == Brightness.dark
      ? DesignSystemColors.darkCard
      : DesignSystemColors.lightCard;
  Color get surfaceColor => colorScheme.surface;
  Color get textPrimaryColor => colorScheme.onSurface;
  Color get textSecondaryColor => colorScheme.onSurfaceVariant;
  Color get primaryColor => colorScheme.primary;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

class AppTypography {
  static TextStyle displayLarge = GoogleFonts.sora(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static TextStyle displayMedium = GoogleFonts.sora(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headingLarge = GoogleFonts.sora(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headingMedium = GoogleFonts.sora(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const full = 100.0;
}

class AppShadows {
  static List<BoxShadow> cardLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevatedDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

class CategoryColors {
  static const note = Color(0xFF4F8EF7);
  static const expense = Color(0xFFF87171);
  static const income = Color(0xFF34D399);
  static const reminder = Color(0xFFFBBF24);
  static const capture = Color(0xFF7C5CFC);
  static const video = Color(0xFFF472B6);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: DesignSystemColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: DesignSystemColors.lightPrimary,
      secondary: DesignSystemColors.lightSecondary,
      surface: DesignSystemColors.lightBackground,
      error: DesignSystemColors.lightDanger,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: DesignSystemColors.lightTextPrimary,
      onSurfaceVariant: DesignSystemColors.lightTextSecondary,
      surfaceContainerHighest: DesignSystemColors.lightCard,
      outline: Color(0xFFE2E8F0),
      outlineVariant: Color(0xFFCBD5E1),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(
        color: DesignSystemColors.lightTextPrimary,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: DesignSystemColors.lightTextPrimary,
      ),
      headlineLarge: AppTypography.headingLarge.copyWith(
        color: DesignSystemColors.lightTextPrimary,
      ),
      headlineMedium: AppTypography.headingMedium.copyWith(
        color: DesignSystemColors.lightTextPrimary,
      ),
      bodyLarge: AppTypography.bodyLarge.copyWith(
        color: DesignSystemColors.lightTextPrimary,
      ),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: DesignSystemColors.lightTextSecondary,
      ),
      bodySmall: AppTypography.caption.copyWith(
        color: DesignSystemColors.lightTextSecondary,
      ),
      labelLarge: AppTypography.label.copyWith(
        color: DesignSystemColors.lightTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: DesignSystemColors.lightCard,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: DesignSystemColors.lightBackground,
      foregroundColor: DesignSystemColors.lightTextPrimary,
      titleTextStyle: AppTypography.headingMedium.copyWith(
        color: DesignSystemColors.lightTextPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DesignSystemColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: DesignSystemColors.lightTextSecondary.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: DesignSystemColors.lightTextSecondary.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: DesignSystemColors.lightPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignSystemColors.lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: DesignSystemColors.lightPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DesignSystemColors.lightSurface,
      selectedItemColor: DesignSystemColors.lightPrimary,
      unselectedItemColor: DesignSystemColors.lightTextSecondary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: DividerThemeData(
      color: DesignSystemColors.lightTextSecondary.withValues(alpha: 0.15),
      thickness: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: DesignSystemColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: DesignSystemColors.lightBackground,
      selectedColor: DesignSystemColors.lightPrimary.withValues(alpha: 0.15),
      labelStyle: AppTypography.label.copyWith(
        color: DesignSystemColors.lightTextPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return DesignSystemColors.lightPrimary;
        return DesignSystemColors.lightTextSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return DesignSystemColors.lightPrimary.withValues(alpha: 0.3);
        return DesignSystemColors.lightTextSecondary.withValues(alpha: 0.2);
      }),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: DesignSystemColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: DesignSystemColors.darkPrimary,
      secondary: DesignSystemColors.darkSecondary,
      surface: DesignSystemColors.darkBackground,
      error: DesignSystemColors.darkDanger,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: DesignSystemColors.darkTextPrimary,
      onSurfaceVariant: DesignSystemColors.darkTextSecondary,
      surfaceContainerHighest: DesignSystemColors.darkCard,
      outline: Color(0xFF2A2D3A),
      outlineVariant: Color(0xFF3A3D4A),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(
        color: DesignSystemColors.darkTextPrimary,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: DesignSystemColors.darkTextPrimary,
      ),
      headlineLarge: AppTypography.headingLarge.copyWith(
        color: DesignSystemColors.darkTextPrimary,
      ),
      headlineMedium: AppTypography.headingMedium.copyWith(
        color: DesignSystemColors.darkTextPrimary,
      ),
      bodyLarge: AppTypography.bodyLarge.copyWith(
        color: DesignSystemColors.darkTextPrimary,
      ),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: DesignSystemColors.darkTextSecondary,
      ),
      bodySmall: AppTypography.caption.copyWith(
        color: DesignSystemColors.darkTextSecondary,
      ),
      labelLarge: AppTypography.label.copyWith(
        color: DesignSystemColors.darkTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: DesignSystemColors.darkCard,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: DesignSystemColors.darkBackground,
      foregroundColor: DesignSystemColors.darkTextPrimary,
      titleTextStyle: AppTypography.headingMedium.copyWith(
        color: DesignSystemColors.darkTextPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DesignSystemColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: DesignSystemColors.darkTextSecondary.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: DesignSystemColors.darkTextSecondary.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: DesignSystemColors.darkPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignSystemColors.darkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: DesignSystemColors.darkPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DesignSystemColors.darkSurface,
      selectedItemColor: DesignSystemColors.darkPrimary,
      unselectedItemColor: DesignSystemColors.darkTextSecondary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: DividerThemeData(
      color: DesignSystemColors.darkTextSecondary.withValues(alpha: 0.15),
      thickness: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: DesignSystemColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: DesignSystemColors.darkCard,
      selectedColor: DesignSystemColors.darkPrimary.withValues(alpha: 0.2),
      labelStyle: AppTypography.label.copyWith(
        color: DesignSystemColors.darkTextPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return DesignSystemColors.darkPrimary;
        return DesignSystemColors.darkTextSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return DesignSystemColors.darkPrimary.withValues(alpha: 0.3);
        return DesignSystemColors.darkTextSecondary.withValues(alpha: 0.2);
      }),
    ),
  );
}
