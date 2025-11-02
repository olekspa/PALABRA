import 'package:flutter/material.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';

/// Core timed run experience view.
class RunScreen extends StatelessWidget {
  /// Creates a [RunScreen].
  const RunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Run Session',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
