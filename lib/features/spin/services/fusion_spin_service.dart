import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/pokedex_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../models/fusion_entry.dart';
import '../../../core/constants/pokedex_constants.dart';
import '../widgets/fusion_spin_dialog/fusion_spin_dialog_widget.dart';

class FusionSpinService {
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

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (_) {
        return FusionSpinDialog(
          allPokemon: pool,
          result1: p1,
          result2: p2,
          ball: ball,
          onFinished: () {
            // Store fusion in collection
            fusionCollection.addFusion(
              FusionEntry(
                p1: p1,
                p2: p2,
                ball: ball,
                rarity: fusionProbability,
              ),
            );

            Navigator.pop(context);
          },
        );
      },
    );
  }
}
