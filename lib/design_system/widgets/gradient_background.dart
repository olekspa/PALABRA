import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:palabra/design_system/tokens/color_tokens.dart';

/// Background container that applies the core animated gradient used across screens.
class GradientBackground extends StatefulWidget {
  /// Creates a gradient-backed container.
  const GradientBackground({required this.child, super.key});

  /// Foreground content rendered atop the gradient.
  final Widget child;

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_SparklePoint> _sparkles;

  static const List<List<Color>> _gradientPalettes = <List<Color>>[
    <Color>[
      Color(0xFF0B1224),
      Color(0xFF111B33),
      Color(0xFF16213F),
    ],
    <Color>[
      Color(0xFF1B1136),
      Color(0xFF231C4A),
      Color(0xFF1B2D50),
    ],
    <Color>[
      Color(0xFF101A32),
      Color(0xFF10283D),
      Color(0xFF123F4F),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();

    final random = math.Random(42);
    _sparkles = List<_SparklePoint>.generate(28, (index) {
      return _SparklePoint(
        position: Offset(random.nextDouble(), random.nextDouble()),
        phaseOffset: random.nextDouble(),
        radius: 0.004 + random.nextDouble() * 0.012,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final gradient = _interpolatedGradient(t);
        return Container(
          decoration: BoxDecoration(gradient: gradient),
          child: CustomPaint(
            painter: _SparklePainter(
              sparkles: _sparkles,
              progress: t,
              color: AppColors.secondary.withValues(alpha: 0.18),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }

  LinearGradient _interpolatedGradient(double t) {
    final scaled = t * _gradientPalettes.length;
    final index = scaled.floor() % _gradientPalettes.length;
    final nextIndex = (index + 1) % _gradientPalettes.length;
    final localT = scaled - scaled.floor();

    final current = _gradientPalettes[index];
    final next = _gradientPalettes[nextIndex];
    final colors = List<Color>.generate(
      current.length,
      (i) => Color.lerp(current[i], next[i], _easeInOut(localT)) ??
          current[i],
    );

    final shift = math.sin(t * math.pi * 2) * 0.45;
    return LinearGradient(
      begin: Alignment(-0.6 + shift, -1),
      end: Alignment(0.6 - shift, 1),
      colors: colors,
    );
  }

  double _easeInOut(double value) {
    return value < 0.5
        ? 4 * value * value * value
        : 1 - math.pow(-2 * value + 2, 3) / 2;
  }
}

class _SparklePoint {
  const _SparklePoint({
    required this.position,
    required this.phaseOffset,
    required this.radius,
  });

  final Offset position;
  final double phaseOffset;
  final double radius;
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter({
    required this.sparkles,
    required this.progress,
    required this.color,
  });

  final List<_SparklePoint> sparkles;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final spark in sparkles) {
      final phase = (progress + spark.phaseOffset) % 1.0;
      final intensity = (math.sin(phase * math.pi * 2) + 1) / 2;
      final radius = spark.radius * size.shortestSide * (0.4 + intensity * 0.6);
      paint.color = color.withValues(alpha: intensity * 0.8);
      final offset = Offset(
        spark.position.dx * size.width,
        spark.position.dy * size.height,
      );
      canvas.drawCircle(offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
