import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF101413);
  static const panel = Color(0xFF1A201E);
  static const panelSoft = Color(0xFF242B28);
  static const paper = Color(0xFFF4F0E8);
  static const coral = Color(0xFFFF725E);
  static const lime = Color(0xFFC8F560);
  static const sky = Color(0xFF72C7E7);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.coral,
    brightness: Brightness.dark,
    surface: AppColors.ink,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.ink,
    fontFamily: 'Arial',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 50,
        height: .95,
        fontWeight: FontWeight.w900,
        letterSpacing: -2,
      ),
      headlineLarge: TextStyle(
        fontSize: 34,
        height: 1,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(fontSize: 16, height: 1.55),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: Color(0xFFB6BFBB),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.panel,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: AppColors.lime),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
    ),
  );
}
