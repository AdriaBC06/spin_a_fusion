import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/pokemon.dart';

class FusionLootbox extends StatefulWidget {
  final List<Pokemon> allPokemon;
  final Pokemon result1;
  final Pokemon result2;
  final VoidCallback onFinished;

  const FusionLootbox({
    super.key,
    required this.allPokemon,
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

  late final _SpinData _spin1;
  late final _SpinData _spin2;

  static const double itemWidth = 120;
  static const int bufferSize = 20;

  @override
  void initState() {
    super.initState();

    final rng = Random();

    _spin1 = _buildSpin(widget.result1, rng);
    _spin2 = _buildSpin(widget.result2, rng, reverse: true);

    final spinDuration1 = Duration(seconds: 5 + rng.nextInt(3));
    final spinDuration2 = Duration(seconds: 5 + rng.nextInt(3));

    _controller1 = AnimationController(vsync: this, duration: spinDuration1);

    _controller2 = AnimationController(vsync: this, duration: spinDuration2);

    _controller1.forward();
    _controller2.forward();

    Future.delayed(
      Duration(
        milliseconds:
            max(
              _controller1.duration!.inMilliseconds,
              _controller2.duration!.inMilliseconds,
            ) +
            600,
      ),
      widget.onFinished,
    );
  }

  _SpinData _buildSpin(Pokemon result, Random rng, {bool reverse = false}) {
    final coreCount = 15 + rng.nextInt(6);

    final pool = List<Pokemon>.from(widget.allPokemon)
      ..remove(result)
      ..shuffle();

    final before = pool.take(bufferSize).toList();
    final core = pool.skip(bufferSize).take(coreCount).toList();
    final after = pool.skip(bufferSize + coreCount).take(bufferSize).toList();

    var items = [...before, ...core, result, ...after];

    var resultIndex = before.length + core.length;
    var startIndex = rng.nextInt(bufferSize ~/ 2) + 2;

    // 🔥 THIS IS THE KEY PART 🔥
    if (reverse) {
      items = items.reversed.toList();

      final lastIndex = items.length - 1;
      resultIndex = lastIndex - resultIndex;
      startIndex = lastIndex - startIndex;
    }

    return _SpinData(
      items: items,
      startIndex: startIndex,
      resultIndex: resultIndex,
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  Widget _roulette(AnimationController controller, _SpinData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final centerOffset = (viewportWidth - itemWidth) / 2;

        final startOffset = data.startIndex * itemWidth;
        final endOffset = data.resultIndex * itemWidth;

        final totalWidth = data.items.length * itemWidth;

        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final eased = Curves.easeOutQuart.transform(controller.value);

            final currentOffset = lerpDouble(startOffset, endOffset, eased)!;

            final dx = centerOffset - currentOffset;

            return ClipRect(
              child: SizedBox(
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    OverflowBox(
                      maxWidth: totalWidth,
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset: Offset(dx, 0),
                        child: SizedBox(
                          width: totalWidth,
                          child: Row(
                            children: List.generate(
                              data.items.length,
                              (i) => _tile(data.items[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: itemWidth,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.amber, width: 3),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _tile(Pokemon p) {
    return SizedBox(
      width: itemWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(p.pokemonSprite, width: 64, height: 64),
          const SizedBox(height: 6),
          Text(
            p.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text('Total ${p.totalStats}', style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        elevation: 26,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TOP → normal (left spin)
              _roulette(_controller1, _spin1),
              const SizedBox(height: 24),
              // BOTTOM → mirrored (right spin)
              _roulette(_controller2, _spin2),
            ],
          ),
        ),
      ),
    );
  }
}

/// -------------------------------
/// INTERNAL DATA STRUCTURE
/// -------------------------------
class _SpinData {
  final List<Pokemon> items;
  final int startIndex;
  final int resultIndex;

  _SpinData({
    required this.items,
    required this.startIndex,
    required this.resultIndex,
  });
}
