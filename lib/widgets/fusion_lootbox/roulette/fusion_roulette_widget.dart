import 'dart:ui';
import 'package:flutter/material.dart';
import 'spin_data.dart';
import 'fusion_roulette_tile.dart';

class FusionRoulette extends StatelessWidget {
  final AnimationController controller;
  final SpinData data;

  const FusionRoulette({
    super.key,
    required this.controller,
    required this.data,
  });

  static const double itemWidth = 120;

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
                (constraints.maxWidth - itemWidth) / 2;
            final start = data.startIndex * itemWidth;
            final end = data.resultIndex * itemWidth;

            return AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                final eased =
                    Curves.easeOutQuart.transform(controller.value);
                final dx =
                    centerOffset - lerpDouble(start, end, eased)!;

                return ClipRect(
                  child: SizedBox(
                    width: constraints.maxWidth, // ✅ HARD CONSTRAINT (FIX)
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
                              children: data.items
                                  .map(
                                    (p) => FusionRouletteTile(
                                      pokemon: p,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),

                        // 🎯 Center highlight frame
                        Container(
                          width: itemWidth,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.amber,
                              width: 3,
                            ),
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
