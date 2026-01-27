import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import 'inventory_card.dart';

class InventorySection extends StatelessWidget {
  const InventorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pokéballs',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          InventoryBallCard(
            name: 'Poké Ball',
            color: Colors.red,
            amount: game.ballCount(BallType.poke),
          ),
          InventoryBallCard(
            name: 'Super Ball',
            color: Colors.blue,
            amount: game.ballCount(BallType.superBall),
          ),
          InventoryBallCard(
            name: 'Ultra Ball',
            color: Colors.amber,
            amount: game.ballCount(BallType.ultra),
          ),
          InventoryBallCard(
            name: 'Master Ball',
            color: Colors.purple,
            amount: game.ballCount(BallType.master),
          ),
        ],
      ),
    );
  }
}
