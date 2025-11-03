import 'package:flutter/material.dart';

/// Centralized color palette for the Palabra design system.
abstract final class AppColors {
  /// Brand purple used for primary accents and CTAs.
  static const Color primary = Color(0xFF7C3AED);
  /// Aqua accent applied to interactive secondary components.
  static const Color secondary = Color(0xFF22D3EE);
  /// Success green for positive statuses.
  static const Color success = Color(0xFF34D399);
  /// Warning amber for cautionary messaging.
  static const Color warning = Color(0xFFFBBF24);
  /// Error red for destructive or error states.
  static const Color danger = Color(0xFFF87171);
  /// Default dark surface background.
  static const Color surface = Color(0xFF0F172A);
  /// Secondary surface tone used for cards and panels.
  static const Color surfaceVariant = Color(0xFF1E293B);
  /// Divider outline used for subtle borders.
  static const Color outline = Color(0xFF334155);
  /// Primary text color on dark surfaces.
  static const Color textPrimary = Color(0xFFFBFBFB);
  /// Muted text color for labels and secondary copy.
  static const Color textMuted = Color(0xFF94A3B8);
}

/// Procedural gradients used app-wide.
abstract final class AppGradients {
  /// Default background gradient spanning the experience.
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFF0B1224), Color(0xFF111B33), Color(0xFF16213F)],
  );
}
