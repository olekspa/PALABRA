import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:palabra/feature_run/application/run_state.dart';

/// Visual overlay that renders animated confetti bursts.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({required this.effect, super.key});

  final ConfettiEffect effect;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effect.token != widget.effect.token) {
      _controller
        ..duration = const Duration(milliseconds: 1800)
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ConfettiPainter(
                progress: Curves.easeOut.transform(_controller.value),
                seed: widget.effect.token,
                intensity: widget.effect.intensity,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.progress,
    required this.seed,
    required this.intensity,
  });

  final double progress;
  final int seed;
  final double intensity;

  static const List<Color> _palette = <Color>[
    Color(0xFF7C3AED),
    Color(0xFF22D3EE),
    Color(0xFFFB7185),
    Color(0xFFF59E0B),
    Color(0xFF34D399),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final count = (120 * intensity).round().clamp(40, 160);
    final paint = Paint();
    final fallProgress = progress.clamp(0.0, 1.0);

    for (var i = 0; i < count; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height * 0.3;
      final horizontalDrift = (random.nextDouble() - 0.5) * size.width * 0.1;
      final depth = random.nextDouble();
      final baseSize = 6 + depth * 8;
      final rotation = (random.nextDouble() - 0.5) * math.pi;
      final sway = math.sin((progress * 10) + depth * 20) * 12;
      final dx = startX + horizontalDrift * fallProgress + sway;
      final dy = startY + size.height * fallProgress + depth * 20;

      paint.color =
          _palette[random.nextInt(_palette.length)].withOpacity(0.85);

      final rect = Rect.fromCenter(
        center: Offset(dx, dy),
        width: baseSize * (0.5 + (1 - fallProgress) * 0.7),
        height: baseSize * (0.3 + (1 - fallProgress) * 0.6),
      );

      final path = Path()
        ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)));

      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(rotation * (1 - fallProgress));
      canvas.translate(-rect.center.dx, -rect.center.dy);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.seed != seed ||
        oldDelegate.intensity != intensity;
  }
}
