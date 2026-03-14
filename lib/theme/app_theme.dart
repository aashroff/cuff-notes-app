import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CuffNotesTheme {
  static const _seedColor = Color(0xFF1B4F8A);

  static ThemeData light([ColorScheme? dynamicScheme]) {
    final scheme = dynamicScheme ??
        ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light);
    return _buildTheme(scheme);
  }

  static ThemeData dark([ColorScheme? dynamicScheme]) {
    final scheme = dynamicScheme ??
        ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark);
    return _buildTheme(scheme);
  }

  static ThemeData _buildTheme(ColorScheme scheme) {
    final textTheme = GoogleFonts.dmSansTextTheme(
      ThemeData(colorScheme: scheme).textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.brightness == Brightness.dark
          ? const Color(0xFF0B0E13)
          : const Color(0xFFF4F5F9),
      cardTheme: CardThemeData(
        color: scheme.brightness == Brightness.dark
            ? const Color(0xFF141820)
            : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.brightness == Brightness.dark
                ? const Color(0xFF222838)
                : const Color(0xFFDCDFE8),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.brightness == Brightness.dark
            ? const Color(0xFF0B0E13).withValues(alpha: 0.9)
            : const Color(0xFFF4F5F9).withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.brightness == Brightness.dark
            ? const Color(0xFF141820)
            : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.brightness == Brightness.dark
                ? const Color(0xFF222838)
                : const Color(0xFFDCDFE8),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.brightness == Brightness.dark
                ? const Color(0xFF222838)
                : const Color(0xFFDCDFE8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Extension for quick access to custom colours derived from the theme
extension CuffColors on BuildContext {
  Color get cardBg => Theme.of(this).cardTheme.color ?? Colors.white;
  Color get cardBg2 => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF1A1F2B)
      : const Color(0xFFEDEEF4);
  Color get borderColor => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF222838)
      : const Color(0xFFDCDFE8);
  Color get mutedText => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF8892A8)
      : const Color(0xFF666E84);
  Color get dimText => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFF565F75)
      : const Color(0xFF9DA3B5);
  Color get success => const Color(0xFF34D399);
  Color get danger => const Color(0xFFF87171);
  Color get warning => const Color(0xFFFBBF24);
}