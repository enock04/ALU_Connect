import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ALU brand colors – pulled from alueducation.com
class ALUColors {
  static const Color navy = Color(0xFF002E6D);
  static const Color navyLight = Color(0xFF1A4FA0);
  static const Color navyDim = Color(0xFF001A42);
  static const Color red = Color(0xFFD00D2D);
  static const Color redLight = Color(0xFFE8304A);
  static const Color redDim = Color(0xFF6B0616);

  // dark backgrounds
  static const Color background = Color(0xFF00112E);
  static const Color surface = Color(0xFF001A42);
  static const Color card = Color(0xFF002359);
  static const Color border = Color(0xFF1A3A6B);

  // text
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF90AACC);
  static const Color textMuted = Color(0xFF4D6A99);

  // misc
  static const Color gold = Color(0xFFF0A500);
  static const Color goldDim = Color(0xFF3D2900);
  static const Color teal = Color(0xFF0E9E8A);
  static const Color blue = Color(0xFF3B82F6);
}

class AppTheme {
  // shorthand helpers so other files can do AppTheme.montserrat(...)
  static TextStyle montserrat({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color color = ALUColors.textPrimary,
  }) =>
      GoogleFonts.montserrat(fontSize: fontSize, fontWeight: fontWeight, color: color);

  static TextStyle openSans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = ALUColors.textPrimary,
  }) =>
      GoogleFonts.openSans(fontSize: fontSize, fontWeight: fontWeight, color: color);

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: ALUColors.background,
      colorScheme: const ColorScheme.dark(
        primary: ALUColors.red,
        secondary: ALUColors.navy,
        surface: ALUColors.surface,
        error: ALUColors.redLight,
        onPrimary: Colors.white,
        onSurface: ALUColors.textPrimary,
      ),
      textTheme: GoogleFonts.openSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: ALUColors.textPrimary),
        displayMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: ALUColors.textPrimary),
        headlineLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: ALUColors.textPrimary, fontSize: 22),
        headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: ALUColors.textPrimary, fontSize: 18),
        titleLarge: GoogleFonts.openSans(fontWeight: FontWeight.w700, color: ALUColors.textPrimary, fontSize: 16),
        titleMedium: GoogleFonts.openSans(fontWeight: FontWeight.w600, color: ALUColors.textPrimary, fontSize: 14),
        bodyLarge: GoogleFonts.openSans(color: ALUColors.textPrimary, fontSize: 15),
        bodyMedium: GoogleFonts.openSans(color: ALUColors.textSecondary, fontSize: 13),
        bodySmall: GoogleFonts.openSans(color: ALUColors.textMuted, fontSize: 11),
        labelLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.3),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ALUColors.surface,
        foregroundColor: ALUColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: ALUColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ALUColors.surface,
        selectedItemColor: ALUColors.red,
        unselectedItemColor: ALUColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: ALUColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: ALUColors.border),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ALUColors.card,
        hintStyle: GoogleFonts.openSans(color: ALUColors.textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: ALUColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: ALUColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: ALUColors.navyLight, width: 1.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ALUColors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ALUColors.navyLight,
          side: const BorderSide(color: ALUColors.navyLight, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ALUColors.card,
        labelStyle: GoogleFonts.openSans(color: ALUColors.textSecondary, fontSize: 12),
        side: const BorderSide(color: ALUColors.border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        selectedColor: ALUColors.navyDim,
      ),
      dividerTheme: const DividerThemeData(color: ALUColors.border, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ALUColors.card,
        contentTextStyle: GoogleFonts.openSans(color: ALUColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
