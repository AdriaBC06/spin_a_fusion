import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../providers/pokedex_provider.dart';
import '../models/pokemon.dart';
import '../widgets/widgets.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Pokemon? pokemon1;
  Pokemon? pokemon2;
  bool _isSpinning = false;

  @override
  Widget build(BuildContext context) {
    final pokedex = context.watch<PokedexProvider>();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Pokémon cargados: ${pokedex.pokemonList.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (!_isSpinning && pokedex.isLoaded)
                  ? () {
                      final pool = List<Pokemon>.from(pokedex.pokemonList)
                        ..shuffle();

                      final p1 = pokedex.getRandomPokemon(
                        ball: BallType.master,
                      );
                      final p2 = pokedex.getRandomPokemon(
                        ball: BallType.master,
                      );

                      setState(() => _isSpinning = true);

                      showDialog(
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
                              setState(() {
                                pokemon1 = p1;
                                pokemon2 = p2;
                                _isSpinning = false;
                              });
                            },
                          );
                        },
                      );
                    }
                  : null,
              child: const Text('Generar Fusión'),
            ),
            const SizedBox(height: 32),
            if (pokemon1 != null && pokemon2 != null)
              _FusionResult(
                pokemon1: pokemon1!,
                pokemon2: pokemon2!,
              ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
/// RESULTADO DE LA FUSIÓN
/// ------------------------------------------------------
class _FusionResult extends StatelessWidget {
  final Pokemon pokemon1;
  final Pokemon pokemon2;

  const _FusionResult({
    required this.pokemon1,
    required this.pokemon2,
  });

  String get _customFusionUrl =>
      'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
      'pokemon/custom-fusion-sprites-main/CustomBattlers/'
      '${pokemon1.fusionId}.${pokemon2.fusionId}.png';

  String get _autoGenFusionUrl =>
      'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
      'pokemon/autogen-fusion-sprites-master/Battlers/'
      '${pokemon1.fusionId}/${pokemon1.fusionId}.${pokemon2.fusionId}.png';

  /// --------------------------------------------------
  /// PROBABILITY FORMAT: "1 in N" (ROUNDED)
  /// --------------------------------------------------
  String _formatOneIn(double probability) {
    if (probability <= 0) return '∞';

    final raw = 1 / probability;

    // number of digits
    final magnitude = pow(10, (log(raw) / ln10).floor());
    final rounded =
        (raw / magnitude).round() * magnitude;

    return '1 in ${rounded.toInt()}';
  }

  Widget _pokemonCard(
    Pokemon pokemon,
    String probabilityText,
  ) {
    return Column(
      children: [
        Image.network(
          pokemon.pokemonSprite,
          width: 96,
          height: 96,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 6),
        Text(
          pokemon.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Poké Ball',
          style: const TextStyle(fontSize: 11),
        ),
        Text(
          probabilityText,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pokedex = context.read<PokedexProvider>();

    final p1Prob = pokedex.probabilityOfPokemon(
      pokemon1,
      ball: BallType.poke,
    );

    final p2Prob = pokedex.probabilityOfPokemon(
      pokemon2,
      ball: BallType.poke,
    );

    final fusionProb = pokedex.probabilityOfFusion(
      p1: pokemon1,
      p2: pokemon2,
      ball: BallType.poke,
    );

    final combinedStats = pokemon1.totalStats + pokemon2.totalStats;

    return Column(
      children: [
        /// ORIGINAL POKÉMONS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _pokemonCard(
              pokemon1,
              _formatOneIn(p1Prob),
            ),
            const Icon(Icons.add, size: 32),
            _pokemonCard(
              pokemon2,
              _formatOneIn(p2Prob),
            ),
          ],
        ),
        const SizedBox(height: 24),

        /// FUSION IMAGE
        Image.network(
          _customFusionUrl,
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return Image.network(
              _autoGenFusionUrl,
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            );
          },
        ),

        const SizedBox(height: 16),

        /// FUSION NAME
        Text(
          '${pokemon1.name.toUpperCase()} - ${pokemon2.name.toUpperCase()}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        /// STATS
        Text(
          'Stats totales: $combinedStats',
          style: const TextStyle(fontSize: 16),
        ),

        const SizedBox(height: 8),

        /// FUSION RARITY
        Text(
          'Rareza de fusión (Poké Ball): '
          '${_formatOneIn(fusionProb)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
