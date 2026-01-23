import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

                      final p1 = pool.removeAt(0);
                      final p2 = pool.removeAt(1);

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
              _FusionResult(pokemon1: pokemon1!, pokemon2: pokemon2!),
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

  const _FusionResult({required this.pokemon1, required this.pokemon2});

  String get _customFusionUrl =>
      'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
      'pokemon/custom-fusion-sprites-main/CustomBattlers/'
      '${pokemon1.id}.${pokemon2.id}.png';

  String get _autoGenFusionUrl =>
      'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
      'pokemon/autogen-fusion-sprites-master/Battlers/'
      '${pokemon1.id}/${pokemon1.id}.${pokemon2.id}.png';

  int get _combinedStats => pokemon1.totalStats + pokemon2.totalStats;

  Widget _pokemonCard(Pokemon pokemon) {
    return Column(
      children: [
        Image.network(
          pokemon.pokemonSprite,
          width: 96,
          height: 96,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          pokemon.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ORIGINAL POKÉMONS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _pokemonCard(pokemon1),
            const Icon(Icons.add, size: 32),
            _pokemonCard(pokemon2),
          ],
        ),

        const SizedBox(height: 24),

        /// FUSION IMAGE (WITH FALLBACK)
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
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        /// COMBINED STATS
        Text(
          'Stats totales: $_combinedStats',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
