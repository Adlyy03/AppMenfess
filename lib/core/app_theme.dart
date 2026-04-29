import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Menfess SKANIC Premium Theme
class AppTheme {
  AppTheme._();

  // ── Brand palette ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF7000FF); // Deep Electric Purple
  static const Color secondary = Color(0xFF00D1FF); // Cyan Blue
  static const Color hotAccent = Color(0xFFFF4D00); // Hot Orange-Red
  
  static const Color bgDark = Color(0xFF060410); // Ultra Dark Blue-Black
  static const Color cardDark = Color(0xFF121026); // Deep Indigo
  
  static const Color bgLight = Color(0xFFF8F9FF);
  static const Color cardLight = Colors.white;

  // ── Dark theme (Default/Main) ─────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          surface: bgDark,
          surfaceContainerLowest: cardDark,
          surfaceContainer: const Color(0xFF1B1838),
          surfaceContainerHighest: const Color(0xFF24204A),
          primary: primary,
          secondary: secondary,
          tertiary: hotAccent,
          error: const Color(0xFFFF2E63),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: bgDark.withOpacity(0.8),
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.8,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: cardDark,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: bgDark.withOpacity(0.9),
          indicatorColor: primary.withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? secondary : Colors.white.withOpacity(0.4),
            );
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1B1838),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      );

  // ── Light theme ────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          surface: bgLight,
          surfaceContainerLowest: cardLight,
          primary: primary,
          secondary: secondary,
          tertiary: hotAccent,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: bgLight,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F0C1E),
            letterSpacing: -0.8,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: primary.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: cardLight,
        ),
      );
}
