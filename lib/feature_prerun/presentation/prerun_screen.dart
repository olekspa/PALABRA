import 'package:flutter/material.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';

/// Pre-run staging screen where the player configures the run.
class PreRunScreen extends StatelessWidget {
  /// Creates a [PreRunScreen].
  const PreRunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Pre-run Setup',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
