// ignore_for_file: public_member_api_docs

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
                tone: widget.effect.tone,
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
    required this.tone,
  });

  final double progress;
  final int seed;
  final double intensity;
  final ConfettiTone tone;

  static const Map<ConfettiTone, List<Color>> _palettes =
      <ConfettiTone, List<Color>>{
    ConfettiTone.streak: <Color>[
      Color(0xFF7C3AED),
      Color(0xFF22D3EE),
      Color(0xFFEC4899),
      Color(0xFF14B8A6),
    ],
    ConfettiTone.tier: <Color>[
      Color(0xFFF97316),
      Color(0xFFFACC15),
      Color(0xFFFB7185),
      Color(0xFF2DD4BF),
    ],
    ConfettiTone.finishWin: <Color>[
      Color(0xFF34D399),
      Color(0xFF0EA5E9),
      Color(0xFFF59E0B),
      Color(0xFFE879F9),
    ],
    ConfettiTone.finishFail: <Color>[
      Color(0xFF94A3B8),
      Color(0xFF38BDF8),
      Color(0xFF22D3EE),
      Color(0xFFE2E8F0),
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final count = (120 * intensity).round().clamp(40, 160);
    final paint = Paint();
    final fallProgress = progress.clamp(0.0, 1.0);
    final colors = _palettes[tone] ?? _palettes[ConfettiTone.streak]!;
    final sparkleChance = switch (tone) {
      ConfettiTone.streak => 0.05,
      ConfettiTone.tier => 0.12,
      ConfettiTone.finishWin => 0.2,
      ConfettiTone.finishFail => 0.08,
    };
    final flutterChance = tone == ConfettiTone.finishWin ? 0.35 : 0.2;

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
          colors[random.nextInt(colors.length)].withValues(alpha: 0.9);

      final rect = Rect.fromCenter(
        center: Offset(dx, dy),
        width: baseSize * (0.5 + (1 - fallProgress) * 0.7),
        height: baseSize * (0.3 + (1 - fallProgress) * 0.6),
      );

      final shapeRoll = random.nextDouble();
      if (shapeRoll < sparkleChance) {
        _drawSparkle(canvas, Offset(dx, dy), depth, random);
        continue;
      }
      if (shapeRoll < sparkleChance + flutterChance) {
        _drawPetal(canvas, Offset(dx, dy), baseSize, paint.color, random,
            fallProgress);
        continue;
      }

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

  void _drawSparkle(
    Canvas canvas,
    Offset center,
    double depth,
    math.Random random,
  ) {
    final sparklePaint = Paint()
      ..color = Colors.white
          .withValues(alpha: (0.65 + depth * 0.25).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5 + depth;
    final length = 6 + depth * 12;
    final angle = random.nextDouble() * math.pi;
    final dx = math.cos(angle) * length;
    final dy = math.sin(angle) * length;
    canvas.drawLine(
      center.translate(-dx, -dy),
      center.translate(dx, dy),
      sparklePaint,
    );
    canvas.drawLine(
      center.translate(-dy * 0.6, dx * 0.6),
      center.translate(dy * 0.6, -dx * 0.6),
      sparklePaint,
    );
  }

  void _drawPetal(
    Canvas canvas,
    Offset center,
    double baseSize,
    Color color,
    math.Random random,
    double fallProgress,
  ) {
    final petalPaint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          color.withValues(alpha: 0.95),
          color.withValues(alpha: 0.4),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: baseSize),
      );
    final petalPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: center,
          width: baseSize * (0.4 + (1 - fallProgress) * 0.5),
          height: baseSize * (0.9 + random.nextDouble() * 0.6),
        ),
      );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((random.nextDouble() - 0.5) * math.pi);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawPath(petalPath, petalPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.seed != seed ||
        oldDelegate.intensity != intensity ||
        oldDelegate.tone != tone;
  }
}
