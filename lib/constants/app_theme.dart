import 'package:flutter/material.dart';

/// App Theme Configuration
class AppTheme {
  // Font Family
  static const String fontFamily = 'Nunito';

  // Primary - Terracotta
  static const Color primary50 = Color(0xFFfaf3f0);
  static const Color primary100 = Color(0xFFeed7cc);
  static const Color primary200 = Color(0xFFe0bbaa);
  static const Color primary300 = Color(0xFFd19f89);
  static const Color primary400 = Color(0xFFc2846a);
  static const Color primary500 = Color(0xFFb06a4c);
  static const Color primary600 = Color(0xFF8c5740);
  static const Color primary700 = Color(0xFF6a4333);
  static const Color primary800 = Color(0xFF482f25);
  static const Color primary900 = Color(0xFF281b15);

  // Charcoal (text / contrast)
  static const Color char50 = Color(0xFFf5f5f5);
  static const Color char100 = Color(0xFFdddddd);
  static const Color char200 = Color(0xFFc5c5c5);
  static const Color char300 = Color(0xFFadadad);
  static const Color char400 = Color(0xFF969696);
  static const Color char500 = Color(0xFF7e7e7e);
  static const Color char600 = Color(0xFF666666);
  static const Color char700 = Color(0xFF4e4e4e);
  static const Color char800 = Color(0xFF363636);
  static const Color char900 = Color(0xFF1f1f1f);

  // Beige (background / surfaces)
  static const Color beige50 = Color(0xFFf8f5f2);
  static const Color beige100 = Color(0xFFe6dfd4);
  static const Color beige200 = Color(0xFFd4c8b6);
  static const Color beige300 = Color(0xFFc1b29a);
  static const Color beige400 = Color(0xFFae9b7d);
  static const Color beige500 = Color(0xFF998462);
  static const Color beige600 = Color(0xFF7b6b51);
  static const Color beige700 = Color(0xFF5d523f);
  static const Color beige800 = Color(0xFF40392d);
  static const Color beige900 = Color(0xFF242019);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.light(
      primary: primary500,
      onPrimary: Colors.white,
      primaryContainer: primary100,
      onPrimaryContainer: primary900,
      secondary: beige500,
      onSecondary: Colors.white,
      secondaryContainer: beige100,
      onSecondaryContainer: beige900,
      surface: beige50,
      onSurface: char900,
      error: error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: beige50,
    appBarTheme: AppBarTheme(
      backgroundColor: primary500,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary500,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary500,
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary500,
        side: BorderSide(color: primary500, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: char300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: char300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary500, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: error),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(
        fontFamily: fontFamily,
        color: char400,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: fontFamily, fontSize: 57, fontWeight: FontWeight.w400, color: char900),
      displayMedium: TextStyle(fontFamily: fontFamily, fontSize: 45, fontWeight: FontWeight.w400, color: char900),
      displaySmall: TextStyle(fontFamily: fontFamily, fontSize: 36, fontWeight: FontWeight.w400, color: char900),
      headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 32, fontWeight: FontWeight.w600, color: char900),
      headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w600, color: char900),
      headlineSmall: TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w600, color: char900),
      titleLarge: TextStyle(fontFamily: fontFamily, fontSize: 22, fontWeight: FontWeight.w600, color: char900),
      titleMedium: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: char900),
      titleSmall: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: char900),
      bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, color: char800),
      bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, color: char800),
      bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400, color: char700),
      labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: char900),
      labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: char800),
      labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: char700),
    ),
  );
}
