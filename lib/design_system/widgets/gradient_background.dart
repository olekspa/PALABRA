import 'package:flutter/material.dart';
import 'package:palabra/design_system/tokens/color_tokens.dart';

/// Background container that applies the core gradient used across screens.
class GradientBackground extends StatelessWidget {
  /// Creates a gradient-backed container.
  const GradientBackground({required this.child, super.key});

  /// Foreground content rendered atop the gradient.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: child,
    );
  }
}
