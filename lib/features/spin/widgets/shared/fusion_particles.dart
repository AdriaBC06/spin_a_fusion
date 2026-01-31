import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class FusionParticles extends StatelessWidget {
  final double progress;

  const FusionParticles({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: const Size(260, 260),
        painter: FusionParticlesPainter(progress),
      ),
    );
  }
}

class FusionParticlesPainter extends CustomPainter {
  final double progress;
  final Random _rng = Random(1337);

  FusionParticlesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress > 0.7) return;

    final center = Offset(size.width / 2, size.height / 2);
    final t = Curves.easeOutCubic.transform(progress / 0.7);

    for (int i = 0; i < 48; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final spread = lerpDouble(40, 140, t)!;
      final offset = Offset(cos(angle) * spread, sin(angle) * spread);

      final color = HSVColor.fromAHSV(
        1.0,
        _rng.nextDouble() * 360,
        0.35,
        1.0,
      ).toColor();

      final paint = Paint()
        ..color = color.withOpacity(1.0 - t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      final radius = lerpDouble(14, 0, t)!;
      canvas.drawCircle(center + offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FusionParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
