import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../widgets/shop_ball_card.dart';
import '../constants/pokedex_constants.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final money = game.money;

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
            'Balls',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildBall(
            context,
            name: 'Poké Ball',
            color: Colors.red,
            price: 100,
            type: BallType.poke,
            enabled: money >= 100,
          ),
          _buildBall(
            context,
            name: 'Super Ball',
            color: Colors.blue,
            price: 250,
            type: BallType.superBall,
            enabled: money >= 250,
          ),
          _buildBall(
            context,
            name: 'Ultra Ball',
            color: Colors.amber,
            price: 500,
            type: BallType.ultra,
            enabled: money >= 500,
          ),
          _buildBall(
            context,
            name: 'Master Ball',
            color: Colors.purple,
            price: 1000,
            type: BallType.master,
            enabled: money >= 1000,
          ),
        ],
      ),
    );
  }

  Widget _buildBall(
    BuildContext context, {
    required String name,
    required Color color,
    required int price,
    required BallType type,
    required bool enabled,
  }) {
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
