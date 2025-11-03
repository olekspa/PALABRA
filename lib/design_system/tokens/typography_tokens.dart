import 'package:flutter/material.dart';

/// Type scale for Palabra.
abstract final class AppTypography {
  /// Standardized text theme matching the Palabra design system.
  static final TextTheme textTheme = TextTheme(
    displayLarge: _textStyle(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      height: 1.1,
    ),
    displayMedium: _textStyle(
      fontSize: 40,
      fontWeight: FontWeight.w600,
      height: 1.1,
    ),
    displaySmall: _textStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.1,
    ),
    headlineLarge: _textStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.15,
    ),
    headlineMedium: _textStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    headlineSmall: _textStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    titleLarge: _textStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    titleMedium: _textStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    titleSmall: _textStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    bodyLarge: _textStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodyMedium: _textStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodySmall: _textStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    labelLarge: _textStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0.3,
    ),
    labelMedium: _textStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0.3,
    ),
    labelSmall: _textStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0.3,
    ),
  );

  static TextStyle _textStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: 'NotoSans',
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
