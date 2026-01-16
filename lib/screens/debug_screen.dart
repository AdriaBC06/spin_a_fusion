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

          if (pokemon1 != null) _PokemonInfo(pokemon: pokemon1!),
          if (pokemon2 != null) _PokemonInfo(pokemon: pokemon2!),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------
/// WIDGET PARA MOSTRAR INFO DEL POKÉMON
/// ------------------------------------------------------
class _PokemonInfo extends StatelessWidget {
  final Pokemon pokemon;

  const _PokemonInfo({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            pokemon.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('ID: ${pokemon.id}'),
          Text('Stats totales: ${pokemon.totalStats}'),
        ],
      ),
    );
  }
}
