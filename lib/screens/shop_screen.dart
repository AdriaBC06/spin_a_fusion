import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/shop_ball_card.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final money = gameProvider.money;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal
          const Text(
            'Tienda',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Sección Balls
          const Text(
            'Balls',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Poké Ball
          ShopBallCard(
            name: 'Poké Ball',
            color: Colors.red,
            price: 100,
            enabled: money >= 100,
            onBuy: () {
              final success =
                  context.read<GameProvider>().spendMoney(100);

              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No tienes suficiente dinero'),
                  ),
                );
              }
            },
          ),

          // Super Ball
          ShopBallCard(
            name: 'Super Ball',
            color: Colors.blue,
            price: 250,
            enabled: money >= 250,
            onBuy: () {
              final success =
                  context.read<GameProvider>().spendMoney(250);

              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No tienes suficiente dinero'),
                  ),
                );
              }
            },
          ),

          // Ultra Ball
          ShopBallCard(
            name: 'Ultra Ball',
            color: Colors.amber,
            price: 500,
            enabled: money >= 500,
            onBuy: () {
              final success =
                  context.read<GameProvider>().spendMoney(500);

              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No tienes suficiente dinero'),
                  ),
                );
              }
            },
          ),

          // Master Ball
          ShopBallCard(
            name: 'Master Ball',
            color: Colors.purple,
            price: 1000,
            enabled: money >= 1000,
            onBuy: () {
              final success =
                  context.read<GameProvider>().spendMoney(1000);

              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No tienes suficiente dinero'),
                  ),
                );
              }
            },
          ),
          
        ],
      ),
    );
  }
}
