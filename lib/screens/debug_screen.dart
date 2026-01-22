import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokedex_provider.dart';
import '../models/pokemon.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Pokemon? pokemon1;
  Pokemon? pokemon2;

  @override
  Widget build(BuildContext context) {
    final pokedex = context.watch<PokedexProvider>();

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pokémon cargados: ${pokedex.pokemonList.length}',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pokedex.isLoaded
                  ? () {
                      setState(() {
                        pokemon1 = pokedex.getRandomPokemon();
                        pokemon2 = pokedex.getRandomPokemon();
                      });
                    }
                  : null,
              child: const Text('Generar 2 Pokémon'),
            ),

            const SizedBox(height: 30),

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
      '${pokemon1.id}.${pokemon2.id}.png';

  String get _autoGenFusionUrl =>
      'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
      'pokemon/autogen-fusion-sprites-master/Battlers/'
      '${pokemon1.id}/${pokemon1.id}.${pokemon2.id}.png';

  int get _combinedStats =>
      pokemon1.totalStats + pokemon2.totalStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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

        /// NAMES
        Text(
          '${pokemon1.name.toUpperCase()} - ${pokemon2.name.toUpperCase()}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
