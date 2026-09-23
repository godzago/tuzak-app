import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF0A2540);
  static const muted = Color(0xFF64748B);
  static const background = Color(0xFFEEF1F8);
  static const line = Color(0xFFE5EAF1);
  static const green = Color(0xFF15803D);
  static const amber = Color(0xFF9A5A08);
  static const red = Color(0xFFDC2626);
  static const darkRed = Color(0xFF991B1B);
}

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.ink,
      primary: AppColors.ink,
      surface: Colors.white,
      error: AppColors.red,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: AppColors.ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: AppColors.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
        color: AppColors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: TextStyle(fontSize: 15, height: 1.65, color: AppColors.muted),
      bodyMedium: TextStyle(fontSize: 13, height: 1.6, color: AppColors.muted),
      bodySmall: TextStyle(fontSize: 11, height: 1.6, color: AppColors.muted),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: AppColors.muted,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: const StadiumBorder(),
        disabledBackgroundColor: const Color(0xFFDCE3ED),
        disabledForegroundColor: const Color(0xFF77869A),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: const BorderSide(color: Color(0xFFCDD6E2)),
        shape: const StadiumBorder(),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
