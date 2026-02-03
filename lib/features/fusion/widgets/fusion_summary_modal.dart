import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/fusion_entry.dart';
import '../../../models/pokemon.dart';
import '../../../providers/pokedex_provider.dart';
import '../../../core/constants/pokedex_constants.dart';

class FusionSummaryModal extends StatelessWidget {
  final FusionEntry fusion;

  const FusionSummaryModal({
    super.key,
    required this.fusion,
  });

  String _formatOneIn(double probability) {
    if (probability <= 0) return '∞';
    final raw = 1 / probability;
    final magnitude = pow(10, (log(raw) / ln10).floor());
    final rounded = (raw / magnitude).round() * magnitude;
    return '1 in ${rounded.toInt()}';
  }

  Widget _parent(Pokemon p) {
    return Column(
      children: [
        Image.network(p.pokemonSprite, width: 64),
        const SizedBox(height: 4),
        Text(p.name.toUpperCase()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pokedex = context.read<PokedexProvider>();
    final fusionProbability = pokedex.probabilityOfFusion(
      p1: fusion.p1,
      p2: fusion.p2,
      ball: BallType.poke,
    );

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              fusion.customFusionUrl,
              width: 160,
              errorBuilder: (_, __, ___) =>
                  Image.network(fusion.autoGenFusionUrl, width: 160),
            ),
            const SizedBox(height: 12),
            Text(
              fusion.fusionName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _parent(fusion.p1),
                const Icon(Icons.add),
                _parent(fusion.p2),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Rareza: ${_formatOneIn(fusionProbability)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
