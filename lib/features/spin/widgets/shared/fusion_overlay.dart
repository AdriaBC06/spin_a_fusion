import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../models/pokemon.dart';
import '../../../../core/constants/pokedex_constants.dart';
import 'fusion_particles.dart';
import 'fusion_card.dart';

class FusionOverlay extends StatelessWidget {
  final bool showFusion;
  final bool showCard;
  final Pokemon p1;
  final Pokemon p2;
  final BallType ball;
  final FusionModifier? modifier;

  final Animation<double> mergeRotate;
  final Animation<double> mergeScale;
  final Animation<double> mergeBrightness;
  final Animation<Offset> moveUp;
  final Animation<Offset> moveDown;

  final Animation<double> fusionRotate;
  final Animation<double> fusionScale;
  final Animation<double> fusionBrightness;
  final Animation<double> fusionFlash;
  final Animation<double> fusionTint;

  final AnimationController mergeController;
  final AnimationController fusionController;

  const FusionOverlay({
    super.key,
    required this.showFusion,
    required this.showCard,
    required this.p1,
    required this.p2,
    required this.ball,
    required this.modifier,
    required this.mergeRotate,
    required this.mergeScale,
    required this.mergeBrightness,
    required this.moveUp,
    required this.moveDown,
    required this.fusionRotate,
    required this.fusionScale,
    required this.fusionBrightness,
    required this.fusionFlash,
    required this.fusionTint,
    required this.mergeController,
    required this.fusionController,
  });

  ColorFilter _brightness(double value) {
    final v = value * 255;
    return ColorFilter.matrix([
      1, 0, 0, 0, v,
      0, 1, 0, 0, v,
      0, 0, 1, 0, v,
      0, 0, 0, 1, 0,
    ]);
  }

  ColorFilter _tint(Color color, double strength) {
    return ColorFilter.mode(
      color.withOpacity(0.45 * strength),
      BlendMode.srcATop,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!showFusion) return const SizedBox.shrink();

    final modifierColor = modifier == null
        ? null
        : fusionModifierColors[modifier!];
    final fusionUrl =
        'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
        'pokemon/custom-fusion-sprites-main/CustomBattlers/'
        '${p1.fusionId}.${p2.fusionId}.png';

    final autoGenUrl =
        'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
        'pokemon/autogen-fusion-sprites-master/Battlers/'
        '${p1.fusionId}/${p1.fusionId}.${p2.fusionId}.png';

    return AnimatedBuilder(
      animation: Listenable.merge([mergeController, fusionController]),
      builder: (_, __) {
        final flash = modifier == null ? 0.0 : fusionFlash.value;
        final brightness =
            (fusionBrightness.value + flash).clamp(0.0, 1.0)
                as double;
        final tintStrength =
            modifier == null ? 0.0 : fusionTint.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Color(0x332B0F46),
                        Color(0x00151E2C),
                      ],
                      radius: 0.8,
                    ),
                  ),
                ),
              ),
            ),
            // ----------------------------
            // MERGING POKÉMON
            // ----------------------------
            if (fusionController.value == 0)
              FractionalTranslation(
                translation: moveUp.value,
                child: Transform.rotate(
                  angle: mergeRotate.value,
                  child: Transform.scale(
                    scale: mergeScale.value,
                    child: ColorFiltered(
                      colorFilter: _brightness(mergeBrightness.value),
                      child: Image.network(
                        p1.pokemonSprite,
                        width: 110,
                      ),
                    ),
                  ),
                ),
              ),
            if (fusionController.value == 0)
              FractionalTranslation(
                translation: moveDown.value,
                child: Transform.rotate(
                  angle: -mergeRotate.value,
                  child: Transform.scale(
                    scale: mergeScale.value,
                    child: ColorFiltered(
                      colorFilter: _brightness(mergeBrightness.value),
                      child: Image.network(
                        p2.pokemonSprite,
                        width: 110,
                      ),
                    ),
                  ),
                ),
              ),

            // ----------------------------
            // PARTICLES
            // ----------------------------
            if (fusionController.value > 0 &&
                fusionController.value < 0.4)
              FusionParticles(
                progress: fusionController.value,
                color: modifierColor,
              ),

            // ----------------------------
            // FUSED SPRITE (PRE-CARD)
            // ----------------------------
            if (!showCard && fusionController.value > 0)
              Transform.rotate(
                angle: fusionRotate.value,
                child: Transform.scale(
                  scale: fusionScale.value,
                  child: ColorFiltered(
                    colorFilter: _brightness(brightness),
                    child: modifierColor == null
                        ? Image.network(
                            fusionUrl,
                            width: 160,
                            errorBuilder: (_, __, ___) {
                              return Image.network(
                                autoGenUrl,
                                width: 160,
                              );
                            },
                          )
                        : ColorFiltered(
                            colorFilter: _tint(
                              modifierColor,
                              tintStrength,
                            ),
                            child: Image.network(
                              fusionUrl,
                              width: 160,
                              errorBuilder: (_, __, ___) {
                                return Image.network(
                                  autoGenUrl,
                                  width: 160,
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ),


            // ----------------------------
            // FINAL CARD
            // ----------------------------
            if (showCard)
              FusionCard(
                p1: p1,
                p2: p2,
                autoGenUrl: autoGenUrl,
                ball: ball,
                modifier: modifier,
              ),
          ],
        );
      },
    );
  }
}
