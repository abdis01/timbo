import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

ThemeData timboLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: TimboColors.appBackground,
  colorScheme: const ColorScheme.light(
    primary: TimboColors.ink,
    surface: TimboColors.surface,
    onPrimary: Colors.white,
    onSurface: TimboColors.ink,
  ),
  textTheme: GoogleFonts.interTextTheme(),
  appBarTheme: const AppBarTheme(
    backgroundColor: TimboColors.appBackground,
    elevation: 0,
    scrolledUnderElevation: 0,
    foregroundColor: TimboColors.ink,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: TimboColors.border, width: 1.5),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: TimboColors.borderLight, width: 1.5),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: TimboColors.border, width: 2),
    ),
    labelStyle: GoogleFonts.inter(color: TimboColors.inkLight),
    hintStyle: GoogleFonts.inter(color: TimboColors.inkFaint),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: TimboColors.ink,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      minimumSize: const Size(double.infinity, 52),
      textStyle: GoogleFonts.caveat(fontSize: 17, fontWeight: FontWeight.w600),
    ),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);
