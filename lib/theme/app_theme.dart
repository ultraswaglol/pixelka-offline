import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seedColor = Colors.deepOrange;

  static const double kDefaultPadding = 8.0;
  static const double kDefaultRadius = 16.0;

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: _seedColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      surfaceContainerHighest: const Color(0xFF4A4A4A),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: kDefaultPadding * 2,
        ),
        backgroundColor: _seedColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultRadius),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(kDefaultRadius)),
        borderSide: BorderSide.none,
      ),
      filled: true,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultRadius),
      ),
    ),
  );

  AppTheme._();
}
