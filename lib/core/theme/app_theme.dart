import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const ink = Color(0xFF4B3FA0);
  static const muted = Color(0xFF77728F);
  static const background = Color(0xFFEEF0FC);
  static const line = Color(0xFFE6E2F4);
  static const green = Color(0xFF368468);
  static const amber = Color(0xFF986048);
  static const red = Color(0xFFC65C69);
  static const darkRed = Color(0xFFA44358);
}

abstract final class AppTheme {
  static final ThemeData light = _build();

  static ThemeData _build() {
    // Set this before any GoogleFonts style is created, including in tests.
    GoogleFonts.config.allowRuntimeFetching = false;
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ink,
        primary: AppColors.ink,
        surface: Colors.white,
        error: AppColors.red,
      ),
    );
    // Weights are selected before GoogleFonts creates its variant-specific
    // families. All fifteen Material text roles use bundled 400/500/600/700.
    final textTheme = GoogleFonts.poppinsTextTheme(
      base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontSize: 48,
          height: 1.15,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        displayMedium: const TextStyle(
          fontSize: 40,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        displaySmall: const TextStyle(
          fontSize: 28,
          height: 1.3,
          fontWeight: FontWeight.w600,
          letterSpacing: 3,
          color: AppColors.ink,
        ),
        headlineLarge: const TextStyle(
          fontSize: 34,
          height: 1.25,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
          color: AppColors.ink,
        ),
        headlineMedium: const TextStyle(
          fontSize: 28,
          height: 1.3,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: AppColors.ink,
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        titleLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: AppColors.ink,
        ),
        titleMedium: const TextStyle(
          fontSize: 15,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        titleSmall: const TextStyle(
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
        ),
        bodyLarge: const TextStyle(
          fontSize: 15,
          height: 1.6,
          fontWeight: FontWeight.w400,
          color: AppColors.muted,
        ),
        bodyMedium: const TextStyle(
          fontSize: 13,
          height: 1.6,
          fontWeight: FontWeight.w400,
          color: AppColors.muted,
        ),
        bodySmall: const TextStyle(
          fontSize: 11,
          height: 1.6,
          fontWeight: FontWeight.w400,
          color: AppColors.muted,
        ),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: const TextStyle(
          fontSize: 12,
          height: 1.4,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        labelSmall: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.1,
          color: AppColors.muted,
        ),
      ),
    );
    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: const Color(0xFF8C9AAE),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const StadiumBorder(),
          disabledBackgroundColor: const Color(0xFFE0DDF3),
          disabledForegroundColor: const Color(0xFF81799C),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          side: const BorderSide(color: Color(0xFFCDD6E2)),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
