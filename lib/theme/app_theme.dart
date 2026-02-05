import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const primary = Color(0xFF00D1FF);
  static const secondary = Color(0xFFFF2D95);
  static const tertiary = Color(0xFFFFD645);
  static const background = Color(0xFF0B1020);
  static const surface = Color(0xFF111C33);
  static const surfaceAlt = Color(0xFF182647);

  static ThemeData themeData() {
    final baseTextTheme = GoogleFonts.fredokaTextTheme();
    final displayStyle = GoogleFonts.fredoka(
      fontWeight: FontWeight.w700,
    );
    final textTheme = baseTextTheme.copyWith(
      displayLarge:
          displayStyle.copyWith(fontSize: 36, color: Colors.white),
      displayMedium:
          displayStyle.copyWith(fontSize: 30, color: Colors.white),
      displaySmall:
          displayStyle.copyWith(fontSize: 24, color: Colors.white),
      headlineMedium:
          displayStyle.copyWith(fontSize: 22, color: Colors.white),
      titleLarge:
          displayStyle.copyWith(fontSize: 20, color: Colors.white),
      titleMedium:
          displayStyle.copyWith(fontSize: 18, color: Colors.white),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: Colors.white70,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: Colors.white70,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );

    final colorScheme = const ColorScheme.dark().copyWith(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface: surface,
      background: background,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: surfaceAlt,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceAlt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          textStyle: textTheme.labelLarge,
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: primary, width: 1.2),
          textStyle: textTheme.labelLarge,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: surfaceAlt),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white38,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: Colors.white54,
        selectedLabelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge
            ?.copyWith(color: Colors.white54),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white10,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }
}
