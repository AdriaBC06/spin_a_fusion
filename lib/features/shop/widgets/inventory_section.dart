import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/game_provider.dart';
import '../../spin/services/fusion_spin_service.dart';
import 'inventory_ball_card.dart';
import '../../../core/constants/pokedex_constants.dart';

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
            onOpen: () => FusionSpinService.open(
              context: context,
              ball: BallType.poke,
            ),
          ),
          InventoryBallCard(
            name: 'Super Ball',
            color: Colors.blue,
            amount: game.ballCount(BallType.superBall),
            onOpen: () => FusionSpinService.open(
              context: context,
              ball: BallType.superBall,
            ),
          ),
          InventoryBallCard(
            name: 'Ultra Ball',
            color: Colors.amber,
            amount: game.ballCount(BallType.ultra),
            onOpen: () => FusionSpinService.open(
              context: context,
              ball: BallType.ultra,
            ),
          ),
          InventoryBallCard(
            name: 'Master Ball',
            color: Colors.purple,
            amount: game.ballCount(BallType.master),
            onOpen: () => FusionSpinService.open(
              context: context,
              ball: BallType.master,
            ),
          ),
        ],
      ),
    );
  }
}
