import 'dart:math' as math;

import 'package:flutter/material.dart';

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
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _AuroraPainter(progress: t),
                ),
              ),
              widget.child,
            ],
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
      (i) => Color.lerp(current[i], next[i], _easeInOut(localT)) ?? current[i],
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

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({required this.progress});

  final double progress;

  static const List<List<Color>> _auroraPalettes = <List<Color>>[
    <Color>[
      Color(0x8813C6E8),
      Color(0x6634D399),
    ],
    <Color>[
      Color(0x8854F7C5),
      Color(0x665CBAFF),
    ],
    <Color>[
      Color(0x88F472B6),
      Color(0x66C084FC),
    ],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < _auroraPalettes.length; i++) {
      final colors = _auroraPalettes[i];
      paint.shader = LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      final path = Path();
      final baseY = size.height * (0.15 + 0.2 * i);
      final amplitude = size.height * (0.08 + 0.03 * i);
      final phase = progress * 2 * math.pi + (i * math.pi / 3);

      path.moveTo(0, size.height);
      path.lineTo(0, baseY);
      const int segments = 32;
      for (var s = 0; s <= segments; s++) {
        final double x = size.width * (s / segments);
        final double wave = math.sin((s / segments) * 2 * math.pi + phase);
        final double y = baseY + wave * amplitude;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
