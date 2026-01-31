import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/spin_data.dart';
import 'spin_roulette_tile.dart';

class SpinRoulette extends StatefulWidget {
  final AnimationController controller;
  final SpinData data;
  final bool hapticsEnabled;

  const SpinRoulette({
    super.key,
    required this.controller,
    required this.data,
    required this.hapticsEnabled,
  });

  static const double itemWidth = 120;

  @override
  State<SpinRoulette> createState() => _SpinRouletteState();
}

class _SpinRouletteState extends State<SpinRoulette> {
  int? _lastCenterIndex;
  int _lastVibrationMs = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTick);
    debugPrint('🎰 FusionRoulette init');
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTick);
    debugPrint('🎰 FusionRoulette dispose');
    super.dispose();
  }

  void _handleTick() {
    if (!widget.hapticsEnabled) return;

    final data = widget.data;
    final controller = widget.controller;

    final eased = Curves.easeOutQuart.transform(controller.value);

    final start = data.startIndex * SpinRoulette.itemWidth;
    final end = data.resultIndex * SpinRoulette.itemWidth;

    final scrollOffset = lerpDouble(start, end, eased)!;

    // 🎯 VISUAL CENTER INDEX (DIRECTION SAFE)
    final centerIndex =
        ((scrollOffset + SpinRoulette.itemWidth / 2) / SpinRoulette.itemWidth)
            .floor()
            .clamp(0, data.items.length - 1);

    if (_lastCenterIndex == centerIndex) return;
    _lastCenterIndex = centerIndex;

    final now = DateTime.now().millisecondsSinceEpoch;

    // 🛑 THROTTLE (prevents vibration spam)
    if (now - _lastVibrationMs < 30) return;
    _lastVibrationMs = now;

    debugPrint('🎯 CENTER = $centerIndex');

    // 🔔 REAL DEVICE VIBRATION (WORKS)
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 26,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final centerOffset =
                (constraints.maxWidth - SpinRoulette.itemWidth) / 2;

            final start = widget.data.startIndex * SpinRoulette.itemWidth;
            final end = widget.data.resultIndex * SpinRoulette.itemWidth;

            return AnimatedBuilder(
              animation: widget.controller,
              builder: (_, __) {
                final eased = Curves.easeOutQuart.transform(
                  widget.controller.value,
                );

                final dx = centerOffset - lerpDouble(start, end, eased)!;

                return ClipRect(
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(dx, 0),
                          child: OverflowBox(
                            alignment: Alignment.centerLeft,
                            minWidth: 0,
                            maxWidth: double.infinity,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: widget.data.items
                                  .map((p) => SpinRouletteTile(pokemon: p))
                                  .toList(),
                            ),
                          ),
                        ),
                        Container(
                          width: SpinRoulette.itemWidth,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.amber, width: 3),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
