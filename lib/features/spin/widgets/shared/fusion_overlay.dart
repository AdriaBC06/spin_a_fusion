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

  final Animation<double> mergeRotate;
  final Animation<double> mergeScale;
  final Animation<double> mergeBrightness;
  final Animation<Offset> moveUp;
  final Animation<Offset> moveDown;

  final Animation<double> fusionRotate;
  final Animation<double> fusionScale;
  final Animation<double> fusionBrightness;

  final AnimationController mergeController;
  final AnimationController fusionController;

  const FusionOverlay({
    super.key,
    required this.showFusion,
    required this.showCard,
    required this.p1,
    required this.p2,
    required this.ball,
    required this.mergeRotate,
    required this.mergeScale,
    required this.mergeBrightness,
    required this.moveUp,
    required this.moveDown,
    required this.fusionRotate,
    required this.fusionScale,
    required this.fusionBrightness,
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

  @override
  Widget build(BuildContext context) {
    if (!showFusion) return const SizedBox.shrink();

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
        return Stack(
          alignment: Alignment.center,
          children: [
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
              FusionParticles(progress: fusionController.value),

            // ----------------------------
            // FUSED SPRITE (PRE-CARD)
            // ----------------------------
            if (!showCard && fusionController.value > 0)
              Transform.rotate(
                angle: fusionRotate.value,
                child: Transform.scale(
                  scale: fusionScale.value,
                  child: ColorFiltered(
                    colorFilter:
                        _brightness(fusionBrightness.value),
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

            // ----------------------------
            // FINAL CARD
            // ----------------------------
            if (showCard)
              FusionCard(
                p1: p1,
                p2: p2,
                autoGenUrl: autoGenUrl,
                ball: ball,
              ),
          ],
        );
      },
    );
  }
}
