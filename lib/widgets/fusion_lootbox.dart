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

  late final AnimationController _mergeController;
  late final AnimationController _fusionController;

  late final _SpinData _spin1;
  late final _SpinData _spin2;

  late final Animation<double> _mergeRotate;
  late final Animation<double> _mergeScale;
  late final Animation<double> _mergeBrightness;
  late final Animation<Offset> _moveUp;
  late final Animation<Offset> _moveDown;

  late final Animation<double> _fusionRotate;
  late final Animation<double> _fusionScale;
  late final Animation<double> _fusionBrightness;

  static const double itemWidth = 120;
  static const int bufferSize = 20;

  bool _showRoulette = true;
  bool _showFusion = false;
  bool _showCard = false;

  @override
  void initState() {
    super.initState();
    final rng = Random();

    _spin1 = _buildSpin(widget.result1, rng);
    _spin2 = _buildSpin(widget.result2, rng, reverse: true);

    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _mergeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _mergeRotate = Tween<double>(begin: 0, end: pi / 2).animate(
      CurvedAnimation(parent: _mergeController, curve: Curves.easeInOut),
    );

    _mergeScale = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _mergeController, curve: Curves.easeIn));

    _mergeBrightness = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mergeController, curve: Curves.easeIn));

    _moveUp = Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _mergeController, curve: Curves.easeInOut),
        );

    _moveDown = Tween<Offset>(begin: const Offset(0, 1.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _mergeController, curve: Curves.easeInOut),
        );

    _fusionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fusionRotate = Tween<double>(begin: 0, end: pi * 6).animate(
      CurvedAnimation(parent: _fusionController, curve: Curves.easeOut),
    );

    _fusionScale = Tween<double>(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(parent: _fusionController, curve: Curves.easeOutBack),
    );

    _fusionBrightness = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fusionController, curve: Curves.easeOut),
    );

    _controller1.forward();
    _controller2.forward();

    Future.wait([_controller1.forward(), _controller2.forward()]).then((
      _,
    ) async {
      setState(() {
        _showRoulette = false;
        _showFusion = true;
      });

      await _mergeController.forward();
      await _fusionController.forward();

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _showCard = true);

      await Future.delayed(const Duration(seconds: 2));
      widget.onFinished();
    });
  }

  /// --------------------------------------------------
  /// URLs
  /// --------------------------------------------------

  String get _fusionUrl =>
      'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
      'pokemon/custom-fusion-sprites-main/CustomBattlers/'
      '${widget.result1.id}.${widget.result2.id}.png';

  String get _autoGenFusionUrl =>
      'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
      'pokemon/autogen-fusion-sprites-master/Battlers/'
      '${widget.result1.id}/${widget.result1.id}.${widget.result2.id}.png';

  ColorFilter _brightness(double value) {
    final v = value * 255;
    return ColorFilter.matrix([
      1,
      0,
      0,
      0,
      v,
      0,
      1,
      0,
      0,
      v,
      0,
      0,
      1,
      0,
      v,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  Widget _fusionOverlay() {
    if (!_showFusion) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([_mergeController, _fusionController]),
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // MERGE POKÉMON (only before fusion starts)
            if (_fusionController.value == 0)
              FractionalTranslation(
                translation: _moveUp.value,
                child: Transform.rotate(
                  angle: _mergeRotate.value,
                  child: Transform.scale(
                    scale: _mergeScale.value,
                    child: ColorFiltered(
                      colorFilter: _brightness(_mergeBrightness.value),
                      child: Image.network(
                        widget.result1.pokemonSprite,
                        width: 110,
                      ),
                    ),
                  ),
                ),
              ),

            if (_fusionController.value == 0)
              FractionalTranslation(
                translation: _moveDown.value,
                child: Transform.rotate(
                  angle: -_mergeRotate.value,
                  child: Transform.scale(
                    scale: _mergeScale.value,
                    child: ColorFiltered(
                      colorFilter: _brightness(_mergeBrightness.value),
                      child: Image.network(
                        widget.result2.pokemonSprite,
                        width: 110,
                      ),
                    ),
                  ),
                ),
              ),

            // ✨ WHITE SHINY PARTICLES (first half of fusion)
            if (_fusionController.value > 0 && _fusionController.value < 0.4)
              _FusionParticles(progress: _fusionController.value),

            // FUSION SPRITE (only when fusion starts)
            if (!_showCard && _fusionController.value > 0)
              Transform.rotate(
                angle: _fusionRotate.value,
                child: Transform.scale(
                  scale: _fusionScale.value,
                  child: ColorFiltered(
                    colorFilter: _brightness(_fusionBrightness.value),
                    child: Image.network(
                      _fusionUrl,
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return Image.network(
                          _autoGenFusionUrl,
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                ),
              ),

            // FINAL CARD
            if (_showCard)
              _FusionCard(
                p1: widget.result1,
                p2: widget.result2,
                autoGenUrl: _autoGenFusionUrl,
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_showRoulette)
            Material(
              elevation: 26,
              borderRadius: BorderRadius.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _roulette(_controller1, _spin1),
                    const SizedBox(height: 24),
                    _roulette(_controller2, _spin2),
                  ],
                ),
              ),
            ),
          _fusionOverlay(),
        ],
      ),
    );
  }

  /// --------------------------------------------------
  /// ROULETTE
  /// --------------------------------------------------

  Widget _roulette(AnimationController controller, _SpinData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerOffset = (constraints.maxWidth - itemWidth) / 2;
        final start = data.startIndex * itemWidth;
        final end = data.resultIndex * itemWidth;

        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final eased = Curves.easeOutQuart.transform(controller.value);
            final dx = centerOffset - lerpDouble(start, end, eased)!;

            return ClipRect(
              child: SizedBox(
                width: constraints.maxWidth,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(dx, 0),
                      child: OverflowBox(
                        alignment: Alignment.centerLeft,
                        minWidth: 0,
                        maxWidth: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: data.items.map(_tile).toList(),
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
          Image.network(p.pokemonSprite, width: 72, height: 72),
          const SizedBox(height: 6),
          Text(
            p.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------
  /// SPIN DATA BUILDER  ✅ THIS WAS MISSING BEFORE
  /// --------------------------------------------------

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

    if (reverse) {
      items = items.reversed.toList();
      final last = items.length - 1;
      resultIndex = last - resultIndex;
      startIndex = last - startIndex;
    }

    return _SpinData(
      items: items,
      startIndex: startIndex,
      resultIndex: resultIndex,
    );
  }
}

class _FusionParticles extends StatelessWidget {
  final double progress;

  const _FusionParticles({required this.progress});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: const Size(260, 260),
        painter: _FusionParticlesPainter(progress),
      ),
    );
  }
}

class _FusionParticlesPainter extends CustomPainter {
  final double progress;
  final Random _rng = Random(1337);

  _FusionParticlesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // particles live for ~70% of fusion
    if (progress <= 0 || progress > 0.7) return;

    final center = Offset(size.width / 2, size.height / 2);

    // normalized burst progress (0 → 1)
    final t = Curves.easeOutCubic.transform(progress / 0.7);

    const particleCount = 48; // 🔥 MORE particles

    for (int i = 0; i < particleCount; i++) {
      final angle = _rng.nextDouble() * pi * 2;
      final spread = lerpDouble(40, 140, t)!;

      final offset = Offset(cos(angle) * spread, sin(angle) * spread);

      // 🌈 rainbow color per particle
      final hue = (_rng.nextDouble() * 360);
      final color = HSVColor.fromAHSV(1.0, hue, 0.35, 1.0).toColor();

      final paint = Paint()
        ..color = color.withOpacity(1.0 - t)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          12, // ✨ glow
        );

      final radius = lerpDouble(14, 0, t)!; // 💥 BIG particles

      canvas.drawCircle(center + offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FusionParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// --------------------------------------------------
/// FUSION CARD
/// --------------------------------------------------

class _FusionCard extends StatelessWidget {
  final Pokemon p1;
  final Pokemon p2;
  final String autoGenUrl;

  const _FusionCard({
    required this.p1,
    required this.p2,
    required this.autoGenUrl,
  });

  int get _stats => p1.totalStats + p2.totalStats;

  @override
  Widget build(BuildContext context) {
    final customUrl =
        'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
        'pokemon/custom-fusion-sprites-main/CustomBattlers/'
        '${p1.id}.${p2.id}.png';

    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              customUrl,
              width: 160,
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Image.network(
                  autoGenUrl,
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              '${p1.name.toUpperCase()} - ${p2.name.toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text('Stats totales: $_stats'),
          ],
        ),
      ),
    );
  }
}

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
