import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/pokemon.dart';
import '../../constants/pokedex_constants.dart';
import 'fusion_overlay.dart';
import 'roulette/fusion_roulette_widget.dart';
import 'roulette/spin_data.dart';
import 'fusion_lootbox_widget.dart';

class FusionLootboxState extends State<FusionLootbox>
    with TickerProviderStateMixin {
  static const int bufferSize = 20;

  late final AnimationController _spin1Controller;
  late final AnimationController _spin2Controller;
  late final AnimationController _mergeController;
  late final AnimationController _fusionController;

  late final SpinData _spin1;
  late final SpinData _spin2;

  late final Animation<double> mergeRotate;
  late final Animation<double> mergeScale;
  late final Animation<double> mergeBrightness;
  late final Animation<Offset> moveUp;
  late final Animation<Offset> moveDown;

  late final Animation<double> fusionRotate;
  late final Animation<double> fusionScale;
  late final Animation<double> fusionBrightness;

  bool showRoulette = true;
  bool showFusion = false;
  bool showCard = false;

  // --------------------------------------------------
  // 🔔 VIBRATION STATE
  // --------------------------------------------------
  int _lastMergeVibrationMs = 0;
  bool _fusionVibrated = false;

  @override
  void initState() {
    super.initState();
    final rng = Random();

    _spin1 = _buildSpin(widget.result1, rng);
    _spin2 = _buildSpin(widget.result2, rng, reverse: true);

    _spin1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _spin2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _mergeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fusionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 🔔 VIBRATION LISTENERS
    _mergeController.addListener(_handleMergeVibration);
    _fusionController.addListener(_handleFusionVibration);

    mergeRotate = Tween(begin: 0.0, end: pi / 2).animate(
      CurvedAnimation(
        parent: _mergeController,
        curve: Curves.easeInOut,
      ),
    );

    mergeScale = Tween(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(
        parent: _mergeController,
        curve: Curves.easeIn,
      ),
    );

    mergeBrightness = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mergeController,
        curve: Curves.easeIn,
      ),
    );

    moveUp = Tween(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mergeController,
        curve: Curves.easeInOut,
      ),
    );

    moveDown = Tween(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mergeController,
        curve: Curves.easeInOut,
      ),
    );

    fusionRotate = Tween(begin: 0.0, end: pi * 6).animate(
      CurvedAnimation(
        parent: _fusionController,
        curve: Curves.easeOut,
      ),
    );

    fusionScale = Tween(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(
        parent: _fusionController,
        curve: Curves.easeOutBack,
      ),
    );

    fusionBrightness = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fusionController,
        curve: Curves.easeOut,
      ),
    );

    _startSequence();
  }

  // --------------------------------------------------
  // 🔔 SOFT MERGE VIBRATION (PULSING ENERGY)
  // --------------------------------------------------
  void _handleMergeVibration() {
    if (!_mergeController.isAnimating) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - _lastMergeVibrationMs < 120) return;
    _lastMergeVibrationMs = now;

    HapticFeedback.vibrate();
  }

  // --------------------------------------------------
  // 🔔 STRONG FUSION IMPACT (DOUBLE PULSE)
  // --------------------------------------------------
  void _handleFusionVibration() {
    if (_fusionVibrated) return;

    if (_fusionController.value > 0.05) {
      _fusionVibrated = true;

      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 40), () {
        HapticFeedback.vibrate();
      });
    }
  }

  Future<void> _startSequence() async {
    // ----------------------------
    // 🎰 SPIN
    // ----------------------------
    await Future.wait([
      _forwardAndWait(_spin1Controller),
      _forwardAndWait(_spin2Controller),
    ]);

    // 🔔 FINAL SPIN STOP (DOUBLE PULSE)
    HapticFeedback.vibrate();
    Future.delayed(const Duration(milliseconds: 40), () {
      HapticFeedback.vibrate();
    });

    setState(() {
      showRoulette = false;
      showFusion = true;
    });

    // ----------------------------
    // 🔥 MERGE → FUSION
    // ----------------------------
    await _mergeController.forward();
    await _fusionController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => showCard = true);

    await Future.delayed(const Duration(seconds: 2));
    widget.onFinished();
  }

  Future<void> _forwardAndWait(AnimationController controller) {
    final completer = Completer<void>();

    void listener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        controller.removeStatusListener(listener);
        completer.complete();
      }
    }

    controller.addStatusListener(listener);
    controller.forward();

    return completer.future;
  }

  SpinData _buildSpin(
    Pokemon result,
    Random rng, {
    bool reverse = false,
  }) {
    final coreCount = 15 + rng.nextInt(6);
    final pool = List<Pokemon>.from(widget.allPokemon)
      ..remove(result)
      ..shuffle();

    final before = pool.take(bufferSize).toList();
    final core = pool.skip(bufferSize).take(coreCount).toList();
    final after =
        pool.skip(bufferSize + coreCount).take(bufferSize).toList();

    var items = [...before, ...core, result, ...after];
    var resultIndex = before.length + core.length;
    var startIndex = rng.nextInt(bufferSize ~/ 2) + 2;

    if (reverse) {
      items = items.reversed.toList();
      final last = items.length - 1;
      resultIndex = last - resultIndex;
      startIndex = last - startIndex;
    }

    return SpinData(
      items: items,
      startIndex: startIndex,
      resultIndex: resultIndex,
    );
  }

  @override
  void dispose() {
    _mergeController.removeListener(_handleMergeVibration);
    _fusionController.removeListener(_handleFusionVibration);

    _spin1Controller.dispose();
    _spin2Controller.dispose();
    _mergeController.dispose();
    _fusionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showRoulette)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FusionRoulette(
                  controller: _spin1Controller,
                  data: _spin1,
                  enableHaptics: true,
                ),
                const SizedBox(height: 24),
                FusionRoulette(
                  controller: _spin2Controller,
                  data: _spin2,
                  enableHaptics: true,
                ),
              ],
            ),

          FusionOverlay(
            showFusion: showFusion,
            showCard: showCard,
            p1: widget.result1,
            p2: widget.result2,
            ball: widget.ball,
            mergeRotate: mergeRotate,
            mergeScale: mergeScale,
            mergeBrightness: mergeBrightness,
            moveUp: moveUp,
            moveDown: moveDown,
            fusionRotate: fusionRotate,
            fusionScale: fusionScale,
            fusionBrightness: fusionBrightness,
            mergeController: _mergeController,
            fusionController: _fusionController,
          ),
        ],
      ),
    );
  }
}
