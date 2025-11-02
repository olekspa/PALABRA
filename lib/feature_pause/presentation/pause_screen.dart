import 'package:flutter/material.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';

/// Pause overlay stub for milestone interruptions.
class PauseScreen extends StatelessWidget {
  /// Creates a [PauseScreen].
  const PauseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Paused',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
