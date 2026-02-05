import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/game_provider.dart';
import '../features/shop/widgets/shop_ball_card.dart';
import '../features/shop/widgets/shop_diamond_card.dart';
import '../core/constants/pokedex_constants.dart';
import '../features/shop/services/ball_purchase_limit_service.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  String _formatRemaining(Duration remaining) {
    final totalMinutes = remaining.inMinutes;
    if (totalMinutes <= 0) return '0m';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final money = game.money;
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
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
          const SizedBox(height: 24),
          const Text(
            'Special Balls',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _lockedWrapper(
            locked: !isLoggedIn,
            child: _buildBall(
              context,
              name: 'Silver Ball',
              color: const Color(0xFFB8BCC6),
              type: BallType.silver,
              enabled: isLoggedIn &&
                  money >= ballPrices[BallType.silver]!,
            ),
          ),
          _lockedWrapper(
            locked: !isLoggedIn,
            child: _buildBall(
              context,
              name: 'Gold Ball',
              color: const Color(0xFFFFD76B),
              type: BallType.gold,
              enabled:
                  isLoggedIn && money >= ballPrices[BallType.gold]!,
            ),
          ),
          _lockedWrapper(
            locked: !isLoggedIn,
            child: _buildBall(
              context,
              name: 'Ruby Ball',
              color: const Color(0xFFE84D4D),
              type: BallType.ruby,
              enabled:
                  isLoggedIn && money >= ballPrices[BallType.ruby]!,
            ),
          ),
          _lockedWrapper(
            locked: !isLoggedIn,
            child: _buildBall(
              context,
              name: 'Sapphire Ball',
              color: const Color(0xFF4C7BFF),
              type: BallType.sapphire,
              enabled: isLoggedIn &&
                  money >= ballPrices[BallType.sapphire]!,
            ),
          ),
          _lockedWrapper(
            locked: !isLoggedIn,
            child: _buildBall(
              context,
              name: 'Emerald Ball',
              color: const Color(0xFF2ECC71),
              type: BallType.emerald,
              enabled: isLoggedIn &&
                  money >= ballPrices[BallType.emerald]!,
            ),
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
    final limiter = BallPurchaseLimitService();
    return ShopBallCard(
      name: name,
      color: color,
      price: price,
      enabled: enabled,
      onBuy: () async {
        final game = context.read<GameProvider>();
        if (!game.canSpendMoney(price)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No tienes suficiente dinero'),
            ),
          );
          return;
        }

        final limitResult = await limiter.tryConsume(type);
        if (!limitResult.allowed) {
          final remaining = limitResult.remaining;
          final msg = remaining == null
              ? 'Límite diario alcanzado'
              : 'Disponible en ${_formatRemaining(remaining)}';
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
          }
          return;
        }

        final success = game.buyBall(
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

  Widget _lockedWrapper({
    required bool locked,
    required Widget child,
  }) {
    if (!locked) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.lock, color: Colors.white, size: 24),
                    SizedBox(height: 6),
                    Text(
                      'Inicia sesión o Registrate\npara desbloquear',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
