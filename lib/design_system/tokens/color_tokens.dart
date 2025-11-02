// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Centralized color palette for the Palabra design system.
abstract final class AppColors {
  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFF22D3EE);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);
  static const Color surface = Color(0xFF0F172A);
  static const Color surfaceVariant = Color(0xFF1E293B);
  static const Color outline = Color(0xFF334155);
  static const Color textPrimary = Color(0xFFFBFBFB);
  static const Color textMuted = Color(0xFF94A3B8);
}

/// Procedural gradients used app-wide.
abstract final class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFF0B1224), Color(0xFF111B33), Color(0xFF16213F)],
  );
}
