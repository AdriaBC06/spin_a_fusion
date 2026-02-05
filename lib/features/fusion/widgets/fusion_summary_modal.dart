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

  String _ballLabel(BallType ball) {
    switch (ball) {
      case BallType.poke:
        return 'Poké';
      case BallType.superBall:
        return 'Super';
      case BallType.ultra:
        return 'Ultra';
      case BallType.master:
        return 'Master';
      case BallType.silver:
        return 'Silver';
      case BallType.gold:
        return 'Gold';
      case BallType.ruby:
        return 'Ruby';
      case BallType.sapphire:
        return 'Sapphire';
      case BallType.emerald:
        return 'Emerald';
      case BallType.test:
        return 'Test';
    }
  }

  Color _ballColor(BallType ball) {
    switch (ball) {
      case BallType.poke:
        return Colors.red;
      case BallType.superBall:
        return Colors.blue;
      case BallType.ultra:
        return Colors.amber;
      case BallType.master:
        return Colors.purple;
      case BallType.silver:
        return const Color(0xFFB8BCC6);
      case BallType.gold:
        return const Color(0xFFFFD76B);
      case BallType.ruby:
        return const Color(0xFFE84D4D);
      case BallType.sapphire:
        return const Color(0xFF4C7BFF);
      case BallType.emerald:
        return const Color(0xFF2ECC71);
      case BallType.test:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pokedex = context.read<PokedexProvider>();
    final fusionProbability = pokedex.probabilityOfFusion(
      p1: fusion.p1,
      p2: fusion.p2,
      ball: BallType.poke,
    );

    final modifierColor = fusion.modifier == null
        ? null
        : fusionModifierColors[fusion.modifier!];
    final modifierLabel = fusion.modifier == null
        ? null
        : fusionModifierLabels[fusion.modifier!];

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                modifierColor == null
                    ? Image.network(
                        fusion.customFusionUrl,
                        width: 160,
                        errorBuilder: (_, __, ___) =>
                            Image.network(
                          fusion.autoGenFusionUrl,
                          width: 160,
                        ),
                      )
                    : ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          modifierColor.withOpacity(0.45),
                          BlendMode.srcATop,
                        ),
                        child: Image.network(
                          fusion.customFusionUrl,
                          width: 160,
                          errorBuilder: (_, __, ___) =>
                              Image.network(
                            fusion.autoGenFusionUrl,
                            width: 160,
                          ),
                        ),
                      ),
                Positioned(
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _ballColor(fusion.ball).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _ballColor(fusion.ball)
                            .withOpacity(0.85),
                      ),
                    ),
                    child: Text(
                      _ballLabel(fusion.ball).toUpperCase(),
                      style: TextStyle(
                        color: _ballColor(fusion.ball),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
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
