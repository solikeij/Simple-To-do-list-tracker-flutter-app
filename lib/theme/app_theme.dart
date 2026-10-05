import 'package:flutter/material.dart';

class AppColors {
  static const ink = Color(0xFF0A1128);
  static const navy = Color(0xFF001F54);
  static const blue = Color(0xFF034078);
  static const teal = Color(0xFF1282A2);
  static const paper = Color(0xFFFEFCFB);
}

ThemeData buildAppTheme() {
  const colors = ColorScheme.dark(
    primary: AppColors.teal,
    onPrimary: AppColors.paper,
    secondary: AppColors.teal,
    onSecondary: AppColors.paper,
    surface: AppColors.navy,
    onSurface: AppColors.paper,
    error: AppColors.paper,
    onError: AppColors.ink,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colors,
    scaffoldBackgroundColor: AppColors.ink,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.ink,
      foregroundColor: AppColors.paper,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.teal,
      foregroundColor: AppColors.paper,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.ink,
      labelStyle: const TextStyle(color: AppColors.paper),
      hintStyle: TextStyle(color: AppColors.paper.withAlpha(165)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.teal),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.paper),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(foregroundColor: AppColors.paper,
          side: const BorderSide(color: AppColors.teal)),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.navy,
      contentTextStyle: TextStyle(color: AppColors.paper),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
