import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pokemon.dart';

class FusionLootbox extends StatefulWidget {
  final List<Pokemon> pool;
  final Pokemon result1;
  final Pokemon result2;
  final VoidCallback onFinished;

  const FusionLootbox({
    super.key,
    required this.pool,
    required this.result1,
    required this.result2,
    required this.onFinished,
  });

  @override
  State<FusionLootbox> createState() => _FusionLootboxState();
}

class _FusionLootboxState extends State<FusionLootbox>
    with TickerProviderStateMixin {
  late final AnimationController _controller1;
  late final AnimationController _controller2;

  late final Animation<double> _animation1;
  late final Animation<double> _animation2;

  static const double itemWidth = 140;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _animation1 = CurvedAnimation(
      parent: _controller1,
      curve: Curves.easeOutCubic,
    );

    _animation2 = CurvedAnimation(
      parent: _controller2,
      curve: Curves.easeOutQuart,
    );

    _controller1.forward();
    _controller2.forward();

    Future.delayed(const Duration(milliseconds: 3600), widget.onFinished);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  Widget _buildRoulette(
    Animation<double> animation,
    Pokemon result,
  ) {
    final items = [...widget.pool, result, result];

    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final maxScroll =
            (items.length - 3) * itemWidth;

        final offset = animation.value * maxScroll;

        return ClipRect(
          child: SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(-offset, 0),
                  child: Row(
                    children: items.map(_pokemonTile).toList(),
                  ),
                ),
                Container(
                  width: itemWidth,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.amber,
                      width: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pokemonTile(Pokemon p) {
    return SizedBox(
      width: itemWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            p.pokemonSprite,
            width: 72,
            height: 72,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 6),
          Text(
            p.name.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Total: ${p.totalStats}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoulette(_animation1, widget.result1),
            const SizedBox(height: 24),
            _buildRoulette(_animation2, widget.result2),
          ],
        ),
      ),
    );
  }
}
