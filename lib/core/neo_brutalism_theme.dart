import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Neo-Brutalism Theme (2025 Style)
/// High contrast, thick borders, hard shadows, bold typography
class NeoBrutalismTheme {
  NeoBrutalismTheme._();

  // ── Neo-Brutalism Color Palette ───────────────────────────────────────────
  static const Color yellow = Color(0xFFFFD600);
  static const Color red = Color(0xFFFF3B3B);
  static const Color blue = Color(0xFF0057FF);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color green = Color(0xFF00FF00);
  static const Color purple = Color(0xFF9D00FF);
  static const Color orange = Color(0xFFFF6B00);

  // ── Border & Shadow Constants ─────────────────────────────────────────────
  static const double borderWidth = 4.0;
  static const double borderWidthThin = 3.0;
  static const double borderRadius = 0.0; // Minimal radius
  static const double borderRadiusSmall = 4.0;

  // Hard shadow (no blur)
  static BoxShadow hardShadow({
    Color color = black,
    double offsetX = 4.0,
    double offsetY = 4.0,
  }) {
    return BoxShadow(
      color: color,
      offset: Offset(offsetX, offsetY),
      blurRadius: 0,
      spreadRadius: 0,
    );
  }

  // Pressed effect (no shadow, slight offset)
  static BoxShadow pressedShadow() {
    return const BoxShadow(
      color: Colors.transparent,
      offset: Offset(0, 0),
      blurRadius: 0,
    );
  }

  // ── Typography ─────────────────────────────────────────────────────────────
  static TextStyle heading1() => GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: black,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle heading2() => GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: black,
        letterSpacing: -0.3,
        height: 1.2,
      );

  static TextStyle heading3() => GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: black,
        letterSpacing: 0,
        height: 1.3,
      );

  static TextStyle bodyBold() => GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: black,
        height: 1.5,
      );

  static TextStyle body() => GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: black,
        height: 1.6,
      );

  static TextStyle bodySmall() => GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: black,
        height: 1.5,
      );

  static TextStyle label() => GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: black,
        letterSpacing: 0.5,
      );

  static TextStyle labelUppercase() => GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: black,
        letterSpacing: 1.0,
      );

  
  static const Color gray = Colors.grey;
  static const Color lightGray = Color(0xFFE0E0E0);

  static final TextTheme textTheme = TextTheme(
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: Colors.black54,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

  // ── Button Styles ──────────────────────────────────────────────────────────
  static BoxDecoration buttonDecoration({
    required Color bgColor,
    bool pressed = false,
  }) {
    return BoxDecoration(
      color: bgColor,
      border: Border.all(color: black, width: borderWidth),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: pressed ? [] : [hardShadow()],
    );
  }

  // ── Card Styles ────────────────────────────────────────────────────────────
  static BoxDecoration cardDecoration({
    Color bgColor = white,
    bool pressed = false,
  }) {
    return BoxDecoration(
      color: bgColor,
      border: Border.all(color: black, width: borderWidth),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: pressed ? [] : [hardShadow()],
    );
  }

  // ── Input Field Styles ─────────────────────────────────────────────────────
  static InputDecoration inputDecoration({
    required String hint,
    IconData? icon,
    Widget? suffixIcon,
    bool focused = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: black.withOpacity(0.4),
      ),
      prefixIcon: icon != null
          ? Icon(icon, color: black, size: 22)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: black, width: borderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: black, width: borderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: blue, width: borderWidth),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: red, width: borderWidth),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: red, width: borderWidth),
      ),
      errorStyle: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: red,
      ),
    );
  }

  // ── Theme Data ─────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: white,
        colorScheme: const ColorScheme.light(
          primary: blue,
          secondary: yellow,
          tertiary: red,
          surface: white,
          surfaceContainerLowest: white,
          surfaceContainer: white,
          surfaceContainerHighest: white,
          onSurface: black,
          error: red,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: white,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: heading2(),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: const BorderSide(color: black, width: borderWidth),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: black, width: borderWidth),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: black, width: borderWidth),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: blue, width: borderWidth),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: yellow,
            foregroundColor: black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: const BorderSide(color: black, width: borderWidth),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: labelUppercase(),
            elevation: 0,
          ),
        ),
      );
}
