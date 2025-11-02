import 'package:flutter/material.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';

/// Finish screen shown after the run completes.
class FinishScreen extends StatelessWidget {
  /// Creates a [FinishScreen].
  const FinishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Run Complete',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
