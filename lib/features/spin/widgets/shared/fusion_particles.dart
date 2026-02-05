import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class FusionParticles extends StatelessWidget {
  final double progress;
  final Color? color;

  const FusionParticles({
    super.key,
    required this.progress,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: const Size(260, 260),
        painter: FusionParticlesPainter(progress, color),
      ),
    );
  }
}

class FusionParticlesPainter extends CustomPainter {
  final double progress;
  final Color? color;
  final Random _rng = Random(1337);

  FusionParticlesPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress > 0.7) return;

    final center = Offset(size.width / 2, size.height / 2);
    final t = Curves.easeOutCubic.transform(progress / 0.7);

    for (int i = 0; i < 48; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final spread = lerpDouble(40, 140, t)!;
      final offset = Offset(cos(angle) * spread, sin(angle) * spread);

      final particleColor = color == null
          ? HSVColor.fromAHSV(
              1.0,
              _rng.nextDouble() * 360,
              0.35,
              1.0,
            ).toColor()
          : _tintedColor(color!);

      final paint = Paint()
        ..color = particleColor.withOpacity(1.0 - t)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      final radius = lerpDouble(14, 0, t)!;
      canvas.drawCircle(center + offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FusionParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color;

  Color _tintedColor(Color base) {
    final hsl = HSLColor.fromColor(base);
    final hueJitter = (_rng.nextDouble() * 12) - 6;
    final hue = (hsl.hue + hueJitter) % 360;
    final saturation =
        (hsl.saturation * 0.9).clamp(0.08, 0.9)
            as double;
    final lightness =
        (hsl.lightness + 0.1).clamp(0.35, 0.9)
            as double;

    return HSLColor.fromAHSL(
      1.0,
      hue,
      saturation,
      lightness,
    ).toColor();
  }
}
