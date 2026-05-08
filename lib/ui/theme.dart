import 'package:flutter/material.dart';

/// Global design system for Kitchen Catalogue.
/// Matches the high‑fidelity prototype exactly.
class AppTheme {
  // -----------------------------
  // COLORS
  // -----------------------------
  static const Color bgLight = Color(0xFFF1F5F9);      // Slate‑100
  static const Color textDark = Color(0xFF0F172A);     // Slate‑900
  static const Color textMedium = Color(0xFF475569);   // Slate‑600
  static const Color textLight = Color(0xFF94A3B8);    // Slate‑400

  static const Color border = Color(0xFFE2E8F0);       // Slate‑200
  static const Color card = Color(0xFFF8FAFC);         // Slate‑50

  static const Color primary = Color(0xFF0F172A);      // Dark slate
  static const Color accentBlue = Color(0xFF0EA5E9);   // Sky‑500
  static const Color accentGreen = Color(0xFF059669);  // Emerald‑600
  static const Color accentAmber = Color(0xFFF59E0B);  // Amber‑500

  // -----------------------------
  // TYPOGRAPHY
  // -----------------------------
  static const String fontFamily = 'SF Pro Text';

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: textMedium,
  );

  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: textLight,
  );

  // -----------------------------
  // RADIUS
  // -----------------------------
  static const double radiusLarge = 24;
  static const double radiusMedium = 16;
  static const double radiusSmall = 12;

  // -----------------------------
  // SHADOWS
  // -----------------------------
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // -----------------------------
  // THEME DATA (optional)
  // -----------------------------
  static ThemeData themeData = ThemeData(
    fontFamily: fontFamily,
    scaffoldBackgroundColor: bgLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );
}
