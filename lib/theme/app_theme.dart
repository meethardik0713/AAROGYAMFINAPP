import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Dark Colors ──────────────────────────────
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8CC7A);

  static const Color darkBg = Color(0xFF060810);
  static const Color darkText = Color(0xFFE8E4D9);
  static const Color darkMuted = Color(0x73E8E4D9);
  static const Color darkBorder = Color(0x26C9A84C);
  static const Color darkSurface = Color(0x08FFFFFF);

  // ── Light Colors ─────────────────────────────
  static const Color lightBg = Color(0xFFF8F6F0);
  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightMuted = Color(0xFF888880);
  static const Color lightBorder = Color(0x40C9A84C);
  static const Color lightSurface = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF4ADE80);
  static const Color error = Color(0xFFF87171);

  // ── TextStyles ───────────────────────────────
  static TextStyle heading(double size, {bool isDark = true}) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: FontWeight.w300,
        color: isDark ? darkText : lightText,
        letterSpacing: 0.5,
      );

  static TextStyle body(double size, {bool isDark = true}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: FontWeight.w300,
        color: isDark ? darkText : lightText,
      );

  static TextStyle mutedStyle(double size, {bool isDark = true}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: FontWeight.w300,
        color: isDark ? darkMuted : lightMuted,
      );

  static TextStyle label(double size) => GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: gold,
        letterSpacing: 2,
      );

  // ── ThemeData ────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      surface: darkBg,
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: gold,
      surface: lightBg,
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );
}
