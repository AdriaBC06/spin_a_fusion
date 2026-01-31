import 'package:flutter/material.dart';
import '../../../../models/pokemon.dart';

class SpinRouletteTile extends StatelessWidget {
  final Pokemon pokemon;

  const SpinRouletteTile({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(pokemon.pokemonSprite, width: 72, height: 72),
          const SizedBox(height: 6),
          Text(
            pokemon.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
