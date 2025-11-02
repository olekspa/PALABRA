import 'package:flutter/material.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';

/// Entry gate screen presented before the Palabra flow.
class GateScreen extends StatelessWidget {
  /// Creates a [GateScreen].
  const GateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Palabra Gate',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
