import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/game_provider.dart';
import '../../spin/services/fusion_spin_service.dart';
import 'inventory_ball_card.dart';
import '../../../core/constants/pokedex_constants.dart';

class InventorySection extends StatefulWidget {
  const InventorySection({super.key});

  @override
  State<InventorySection> createState() =>
      _InventorySectionState();
}

class _InventorySectionState extends State<InventorySection> {
  bool _autoSpinRunning = false;

  BallType? _bestAvailableBall(GameProvider game) {
    final order = [
      BallType.emerald,
      BallType.sapphire,
      BallType.ruby,
      BallType.gold,
      BallType.silver,
      BallType.master,
      BallType.ultra,
      BallType.superBall,
      BallType.poke,
      BallType.test,
    ];

    for (final type in order) {
      if (game.ballCount(type) > 0) return type;
    }
    return null;
  }

  Future<void> _startAutoSpin() async {
    if (_autoSpinRunning) return;
    _autoSpinRunning = true;

    final game = context.read<GameProvider>();
    game.setAutoSpinActive(true);

    try {
      while (game.autoSpinActive && mounted) {
        final nextBall = _bestAvailableBall(game);

        if (nextBall == null) {
          break;
        }

        await FusionSpinService.open(
          context: context,
          ball: nextBall,
        );

        if (game.consumeAutoSpinStopRequest()) {
          game.setAutoSpinActive(false);
          break;
        }
      }
    } finally {
      _autoSpinRunning = false;
      if (game.autoSpinActive) {
        game.setAutoSpinActive(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final autoSpinUnlocked = game.autoSpinUnlocked;
    final autoSpinActive = game.autoSpinActive;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pokéballs',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              OutlinedButton.icon(
                onPressed: autoSpinUnlocked
                    ? () {
                        if (autoSpinActive) {
                          game.requestAutoSpinStop();
                          return;
                        }

                        final nextBall =
                            _bestAvailableBall(game);
                        if (nextBall == null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No tienes Pokéballs',
                              ),
                            ),
                          );
                          return;
                        }

                        _startAutoSpin();
                      }
                    : null,
                icon: Icon(
                  autoSpinUnlocked
                      ? (autoSpinActive
                          ? Icons.stop_circle
                          : Icons.autorenew)
                      : Icons.lock,
                  size: 18,
                ),
                label: Text(
                  autoSpinActive ? 'Autospin ON' : 'Autospin',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      autoSpinUnlocked ? Colors.white : Colors.white54,
                  side: BorderSide(
                    color: autoSpinUnlocked
                        ? const Color(0xFF00D1FF)
                        : Colors.white24,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
              ),
            ],
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
          InventoryBallCard(
            name: 'Silver Ball',
            color: const Color(0xFFB8BCC6),
            amount: game.ballCount(BallType.silver),
            onOpen: () => FusionSpinService.open(
              context: context,
              ball: BallType.silver,
            ),
          ),
          InventoryBallCard(
            name: 'Gold Ball',
            color: const Color(0xFFFFD76B),
            amount: game.ballCount(BallType.gold),
            onOpen: () => FusionSpinService.open(
              context: context,
              ball: BallType.gold,
            ),
          ),
          InventoryBallCard(
            name: 'Ruby Ball',
            color: const Color(0xFFE84D4D),
            amount: game.ballCount(BallType.ruby),
            onOpen: () => FusionSpinService.open(
              context: context,
              ball: BallType.ruby,
            ),
          ),
          InventoryBallCard(
            name: 'Sapphire Ball',
            color: const Color(0xFF4C7BFF),
            amount: game.ballCount(BallType.sapphire),
            onOpen: () => FusionSpinService.open(
              context: context,
              ball: BallType.sapphire,
            ),
          ),
          InventoryBallCard(
            name: 'Emerald Ball',
            color: const Color(0xFF2ECC71),
            amount: game.ballCount(BallType.emerald),
            onOpen: () => FusionSpinService.open(
              context: context,
              ball: BallType.emerald,
            ),
          ),
          InventoryBallCard(
            name: 'Test Ball',
            color: Colors.white,
            amount: game.ballCount(BallType.test),
            onOpen: () => FusionSpinService.open(
              context: context,
              ball: BallType.test,
            ),
          ),
        ],
      ),
    );
  }
}
