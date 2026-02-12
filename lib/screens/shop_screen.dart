import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/game_provider.dart';
import '../features/shop/widgets/shop_ball_card.dart';
import '../features/shop/widgets/shop_diamond_card.dart';
import '../core/constants/pokedex_constants.dart';
import '../features/shop/services/ball_purchase_limit_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatRemaining(Duration remaining) {
    final totalSeconds = remaining.inSeconds < 0 ? 0 : remaining.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(hours)}:${two(minutes)}:${two(seconds)}';
  }

  Duration? _remainingForBall({
    required BallType type,
    required Map<String, dynamic> limits,
    required BallPurchaseLimitService limiter,
  }) {
    final cooldown = limiter.cooldownFor(type);
    if (cooldown == null) return null;

    final raw = limits[type.index.toString()];
    final last = raw is Timestamp ? raw.toDate() : null;
    if (last == null) return null;

    final next = last.add(cooldown);
    if (!_now.isBefore(next)) return null;
    return next.difference(_now);
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final money = game.money;
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
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

          if (!isLoggedIn)
            _lockedWrapper(
              locked: true,
              child: _buildBall(
                context,
                name: 'Silver Ball',
                color: const Color(0xFFB8BCC6),
                type: BallType.silver,
                enabled: false,
              ),
            ),
          if (!isLoggedIn)
            _lockedWrapper(
              locked: true,
              child: _buildBall(
                context,
                name: 'Gold Ball',
                color: const Color(0xFFFFD76B),
                type: BallType.gold,
                enabled: false,
              ),
            ),
          if (!isLoggedIn)
            _lockedWrapper(
              locked: true,
              child: _buildBall(
                context,
                name: 'Ruby Ball',
                color: const Color(0xFFE84D4D),
                type: BallType.ruby,
                enabled: false,
              ),
            ),
          if (!isLoggedIn)
            _lockedWrapper(
              locked: true,
              child: _buildBall(
                context,
                name: 'Sapphire Ball',
                color: const Color(0xFF4C7BFF),
                type: BallType.sapphire,
                enabled: false,
              ),
            ),
          if (!isLoggedIn)
            _lockedWrapper(
              locked: true,
              child: _buildBall(
                context,
                name: 'Emerald Ball',
                color: const Color(0xFF2ECC71),
                type: BallType.emerald,
                enabled: false,
              ),
            ),
          if (isLoggedIn)
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() ?? {};
                final limits = Map<String, dynamic>.from(
                  data['ballPurchaseLimits'] ?? {},
                );
                final limiter = BallPurchaseLimitService();

                return Column(
                  children: [
                    _buildBall(
                      context,
                      name: 'Silver Ball',
                      color: const Color(0xFFB8BCC6),
                      type: BallType.silver,
                      enabled: money >= ballPrices[BallType.silver]!,
                      cooldownRemaining: _remainingForBall(
                        type: BallType.silver,
                        limits: limits,
                        limiter: limiter,
                      ),
                    ),
                    _buildBall(
                      context,
                      name: 'Gold Ball',
                      color: const Color(0xFFFFD76B),
                      type: BallType.gold,
                      enabled: money >= ballPrices[BallType.gold]!,
                      cooldownRemaining: _remainingForBall(
                        type: BallType.gold,
                        limits: limits,
                        limiter: limiter,
                      ),
                    ),
                    _buildBall(
                      context,
                      name: 'Ruby Ball',
                      color: const Color(0xFFE84D4D),
                      type: BallType.ruby,
                      enabled: money >= ballPrices[BallType.ruby]!,
                      cooldownRemaining: _remainingForBall(
                        type: BallType.ruby,
                        limits: limits,
                        limiter: limiter,
                      ),
                    ),
                    _buildBall(
                      context,
                      name: 'Sapphire Ball',
                      color: const Color(0xFF4C7BFF),
                      type: BallType.sapphire,
                      enabled: money >= ballPrices[BallType.sapphire]!,
                      cooldownRemaining: _remainingForBall(
                        type: BallType.sapphire,
                        limits: limits,
                        limiter: limiter,
                      ),
                    ),
                    _buildBall(
                      context,
                      name: 'Emerald Ball',
                      color: const Color(0xFF2ECC71),
                      type: BallType.emerald,
                      enabled: money >= ballPrices[BallType.emerald]!,
                      cooldownRemaining: _remainingForBall(
                        type: BallType.emerald,
                        limits: limits,
                        limiter: limiter,
                      ),
                    ),
                  ],
                );
              },
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
    Duration? cooldownRemaining,
  }) {
    final price = ballPrices[type]!;
    final limiter = BallPurchaseLimitService();
    final cooldown = limiter.cooldownFor(type);
    final hasCooldown = cooldown != null;
    final blockedByCooldown = cooldownRemaining != null;
    final canBuy = enabled && !blockedByCooldown;
    final timerText =
        hasCooldown && blockedByCooldown ? _formatRemaining(cooldownRemaining!) : null;
    return ShopBallCard(
      name: name,
      color: color,
      price: price,
      timerText: timerText,
      enabled: canBuy,
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
