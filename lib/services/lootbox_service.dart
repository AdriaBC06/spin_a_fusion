import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokedex_provider.dart';
import '../providers/game_provider.dart';
import '../widgets/widgets.dart';
import '../constants/pokedex_constants.dart';

class LootboxService {
  static Future<void> open({
    required BuildContext context,
    required BallType ball,
  }) async {
    final game = context.read<GameProvider>();
    final pokedex = context.read<PokedexProvider>();

    if (!game.useBall(ball)) return;
    if (!pokedex.isLoaded) return;

    final pool = List.of(pokedex.pokemonList)..shuffle();

    final p1 = pokedex.getRandomPokemon(ball: ball);
    final p2 = pokedex.getRandomPokemon(ball: ball);

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (_) {
        return FusionLootbox(
          allPokemon: pool,
          result1: p1,
          result2: p2,
          onFinished: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
