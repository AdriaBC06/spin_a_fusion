import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../features/shop/widgets/shop_ball_card.dart';
import '../features/shop/widgets/shop_diamond_card.dart';
import '../core/constants/pokedex_constants.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final money = game.money;
    const autoSpinPrice = 100;
    final autoSpinOwned = game.autoSpinUnlocked;
    final autoSpinEnabled =
        !autoSpinOwned && game.diamonds >= autoSpinPrice;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tienda',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pokéballs',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildBall(
            context,
            name: 'Poké Ball',
            color: Colors.red,
            type: BallType.poke,
            enabled: money >= ballPrices[BallType.poke]!,
          ),
          _buildBall(
            context,
            name: 'Super Ball',
            color: Colors.blue,
            type: BallType.superBall,
            enabled: money >= ballPrices[BallType.superBall]!,
          ),
          _buildBall(
            context,
            name: 'Ultra Ball',
            color: Colors.amber,
            type: BallType.ultra,
            enabled: money >= ballPrices[BallType.ultra]!,
          ),
          _buildBall(
            context,
            name: 'Master Ball',
            color: Colors.purple,
            type: BallType.master,
            enabled: money >= ballPrices[BallType.master]!,
          ),
          _buildBall(
            context,
            name: 'Silver Ball',
            color: const Color(0xFFB8BCC6),
            type: BallType.silver,
            enabled: money >= ballPrices[BallType.silver]!,
          ),
          _buildBall(
            context,
            name: 'Gold Ball',
            color: const Color(0xFFFFD76B),
            type: BallType.gold,
            enabled: money >= ballPrices[BallType.gold]!,
          ),
          _buildBall(
            context,
            name: 'Ruby Ball',
            color: const Color(0xFFE84D4D),
            type: BallType.ruby,
            enabled: money >= ballPrices[BallType.ruby]!,
          ),
          _buildBall(
            context,
            name: 'Sapphire Ball',
            color: const Color(0xFF4C7BFF),
            type: BallType.sapphire,
            enabled: money >= ballPrices[BallType.sapphire]!,
          ),
          _buildBall(
            context,
            name: 'Emerald Ball',
            color: const Color(0xFF2ECC71),
            type: BallType.emerald,
            enabled: money >= ballPrices[BallType.emerald]!,
          ),
          _buildBall(
            context,
            name: 'Test Ball',
            color: Colors.white,
            type: BallType.test,
            enabled: money >= ballPrices[BallType.test]!,
          ),

          const SizedBox(height: 28),
          const Text(
            'Tienda Diamantes',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.8,
            children: [
              ShopDiamondCard(
                title: 'Autospin',
                price: autoSpinPrice,
                enabled: autoSpinEnabled,
                locked: false,
                buttonLabel: autoSpinOwned ? 'Comprado' : 'Comprar',
                onBuy: () {
                  final ok = context.read<GameProvider>().unlockAutoSpin(
                        price: autoSpinPrice,
                      );
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No tienes suficientes diamantes'),
                      ),
                    );
                  }
                },
              ),
              const ShopDiamondCard(
                title: '?',
                locked: true,
              ),
              const ShopDiamondCard(
                title: '?',
                locked: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBall(
    BuildContext context, {
    required String name,
    required Color color,
    required BallType type,
    required bool enabled,
  }) {
    final price = ballPrices[type]!;
    return ShopBallCard(
      name: name,
      color: color,
      price: price,
      enabled: enabled,
      onBuy: () {
        final success = context.read<GameProvider>().buyBall(
              type: type,
              price: price,
            );

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No tienes suficiente dinero'),
            ),
          );
        }
      },
    );
  }
}
