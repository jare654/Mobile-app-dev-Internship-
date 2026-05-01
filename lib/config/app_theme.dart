import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Shared Brand Colors ────────────────────────────────────────────────
  static const Color pulseRed = Color(0xFFB72223);
  static const Color success = Color(0xFF10B981);
  
  // Aliases for backward compatibility with existing widgets
  static const Color accent = pulseRed;
  static const Color accentMuted = Color(0x1FB72223);

  // ── Colors: Pro Light (From Design System) ─────────────────────────────
  static const Color lightBackground = Color(0xFFF9F9F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF000000);
  static const Color lightSecondary = pulseRed;
  static const Color lightOnSurface = Color(0xFF1A1C1C);
  static const Color lightOnSurfaceVariant = Color(0xFF444748);
  static const Color lightOutline = Color(0xFFE2E8F0);
  static const Color lightSurfaceContainer = Color(0xFFEEEEEE);

  // ── Colors: Pro Dark (Refined Slate) ───────────────────────────────────
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkPrimary = Color(0xFFF8FAFC);
  static const Color darkSecondary = Color(0xFF38BDF8); // Sky Blue for Dark
  static const Color darkAccent = pulseRed;
  static const Color darkBorder = Color(0xFF334155);

  // ── Backward Compatibility Static Members (Mapping to defaults) ────────
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color elevated = lightSurfaceContainer;
  static const Color textPrimary = lightOnSurface;
  static const Color textSecond = lightOnSurfaceVariant;
  static const Color textCaption = lightOnSurfaceVariant;
  static const Color border = lightOutline;

  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
        onSurface: lightOnSurface,
        onSurfaceVariant: lightOnSurfaceVariant,
        outline: lightOutline,
      ),
      
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.newsreader(
          color: lightOnSurface,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          height: 1.1,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.newsreader(
          color: lightOnSurface,
          fontWeight: FontWeight.w600,
          fontSize: 22,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.workSans(
          color: lightOnSurface,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          height: 1.3,
        ),
        bodyLarge: GoogleFonts.workSans(
          color: lightOnSurface,
          fontSize: 15,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.workSans(
          color: lightOnSurfaceVariant,
          fontSize: 13,
          height: 1.5,
        ),
        labelSmall: GoogleFonts.workSans(
          color: lightOnSurfaceVariant,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
      ),

      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: lightOutline, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: lightOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
          fontStyle: FontStyle.italic,
        ),
        iconTheme: IconThemeData(color: lightOnSurface),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: lightSecondary.withAlpha(20),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimary,
          side: const BorderSide(color: lightPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkSecondary,
        secondary: darkSecondary,
        surface: darkSurface,
        onSurface: darkPrimary,
      ),
      
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.newsreader(
          color: darkPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          height: 1.1,
        ),
        headlineMedium: GoogleFonts.newsreader(
          color: darkPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 22,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.workSans(
          color: darkPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          height: 1.3,
        ),
        bodyLarge: GoogleFonts.workSans(
          color: darkPrimary,
          fontSize: 15,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.workSans(
          color: Colors.white70,
          fontSize: 13,
          height: 1.5,
        ),
        labelSmall: GoogleFonts.workSans(
          color: Colors.white60,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
      ),

      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: darkPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
          fontStyle: FontStyle.italic,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkBackground,
        indicatorColor: darkSecondary.withAlpha(40),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkSecondary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: const BorderSide(color: darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  static Color getAccent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkSecondary : lightSecondary;
  }
}
