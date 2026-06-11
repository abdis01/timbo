import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class TimboTypography {
  static TextStyle heading1 = GoogleFonts.caveat(
    fontSize: 28, fontWeight: FontWeight.w700, color: TimboColors.ink,
  );
  static TextStyle heading2 = GoogleFonts.caveat(
    fontSize: 22, fontWeight: FontWeight.w700, color: TimboColors.ink,
  );
  static TextStyle heading3 = GoogleFonts.caveat(
    fontSize: 18, fontWeight: FontWeight.w600, color: TimboColors.ink,
  );
  static TextStyle folderTitle = GoogleFonts.caveat(
    fontSize: 20, fontWeight: FontWeight.w700, color: TimboColors.ink,
  );
  static TextStyle timboTitle = GoogleFonts.caveat(
    fontSize: 20, fontWeight: FontWeight.w600, color: TimboColors.ink,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w400, color: TimboColors.ink,
  );
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w400, color: TimboColors.inkLight,
  );
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400, color: TimboColors.inkLight,
  );
  static TextStyle label = GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w500, color: TimboColors.inkLight,
  );
  static TextStyle button = GoogleFonts.caveat(
    fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white,
  );
  static TextStyle buttonOutlined = GoogleFonts.caveat(
    fontSize: 17, fontWeight: FontWeight.w600, color: TimboColors.ink,
  );
}
