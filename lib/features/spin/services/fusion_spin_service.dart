import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/pokedex_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../models/fusion_entry.dart';
import '../../../core/constants/pokedex_constants.dart';
import '../widgets/fusion_spin_dialog/fusion_spin_dialog_widget.dart';

class FusionSpinService {
  static double _modifierChance(BallType ball) {
    switch (ball) {
      case BallType.poke:
        return 0.0;
      case BallType.superBall:
        return 0.0001;
      case BallType.ultra:
        return 0.001;
      case BallType.master:
        return 0.01;
      case BallType.silver:
      case BallType.gold:
      case BallType.ruby:
      case BallType.sapphire:
      case BallType.emerald:
        return 1.0;
      case BallType.test:
        return 0.0;
    }
  }

  static FusionModifier? _rollModifier({
    required BallType ball,
    required double fusionProbability,
    required Random rng,
  }) {
    switch (ball) {
      case BallType.silver:
        return FusionModifier.silver;
      case BallType.gold:
        return FusionModifier.gold;
      case BallType.ruby:
        return FusionModifier.ruby;
      case BallType.sapphire:
        return FusionModifier.sapphire;
      case BallType.emerald:
        return FusionModifier.emerald;
      case BallType.poke:
      case BallType.superBall:
      case BallType.ultra:
      case BallType.master:
      case BallType.test:
        break;
    }

    final chance = _modifierChance(ball);
    if (chance <= 0 || rng.nextDouble() > chance) return null;

    final oneIn = fusionProbability <= 0
        ? double.infinity
        : 1 / fusionProbability;

    final rarityScore =
        (((log(oneIn) / ln10) - 2.0) / 3.0)
            .clamp(0.0, 1.0);

    if (rarityScore > 0.85) return FusionModifier.emerald;
    if (rarityScore > 0.7) {
      return rng.nextBool()
          ? FusionModifier.ruby
          : FusionModifier.sapphire;
    }
    if (rarityScore > 0.5) return FusionModifier.gold;

    return FusionModifier.silver;
  }

  static Future<void> open({
    required BuildContext context,
    required BallType ball,
  }) async {
    final game = context.read<GameProvider>();
    final pokedex = context.read<PokedexProvider>();
    final fusionCollection =
        context.read<FusionCollectionProvider>();

    // Consume ball
    if (!game.useBall(ball)) return;
    if (!pokedex.isLoaded) return;

    game.addSpin();

    final rng = Random();

    // Prepare pool
    final pool = List.of(pokedex.pokemonList)..shuffle();

    // Generate results
    final p1 = pokedex.getRandomPokemon(ball: ball);
    final p2 = pokedex.getRandomPokemon(ball: ball);

    // Calculate rarity once (single source of truth)
    final fusionProbability = pokedex.probabilityOfFusion(
      p1: p1,
      p2: p2,
      ball: ball,
    );

    final modifier = _rollModifier(
      ball: ball,
      fusionProbability: fusionProbability,
      rng: rng,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (_) {
        return Stack(
          children: [
            Center(
              child: FusionSpinDialog(
                allPokemon: pool,
                result1: p1,
                result2: p2,
                ball: ball,
                modifier: modifier,
                onFinished: () {
                  // Store fusion in collection
                  fusionCollection.addFusion(
                    FusionEntry(
                      p1: p1,
                      p2: p2,
                      ball: ball,
                      rarity: fusionProbability,
                      modifier: modifier,
                    ),
                  );

                  Navigator.pop(context);
                },
              ),
            ),
            Consumer<GameProvider>(
              builder: (context, game, _) {
                if (!game.autoSpinActive) return const SizedBox.shrink();

                return Positioned(
                  bottom: 20,
                  right: 20,
                  child: ElevatedButton.icon(
                    onPressed: game.autoSpinStopRequested
                        ? null
                        : () {
                            context
                                .read<GameProvider>()
                                .requestAutoSpinStop();
                          },
                    icon: const Icon(Icons.stop_circle, size: 18),
                    label: Text(
                      game.autoSpinStopRequested
                          ? 'Autospin Detenido'
                          : 'Detener Autospin',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF2D95),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF7A2A4A),
                      disabledForegroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
