import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background   = Color(0xFF080A0C);
  static const Color surface      = Color(0xFF12161F);
  static const Color surfaceAlt   = Color(0xFF1B212D);
  static const Color border       = Color(0xFF252C3A);

  static const Color accent       = Color(0xFF3E63FF);
  static const Color accentGlow   = Color(0xFF5374FF);
  static const Color success      = Color(0xFF00F5D4);
  static const Color error        = Color(0xFFFF3B6B);

  static const Color textPrimary  = Color(0xFFFFFFFF);
  static const Color textSecond   = Color(0xFFA0AABF);
  static const Color textMuted    = Color(0xFF5C667A);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: accent,
        secondary: success,
        error: error,
        onSurface: textPrimary,
        primaryContainer: surfaceAlt,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.dmSans(
          color: textPrimary,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: textSecond,
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      useMaterial3: true,
    );
  }
}