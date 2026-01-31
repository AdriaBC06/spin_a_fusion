import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../models/pokemon.dart';
import '../shared/fusion_overlay.dart';
import '../roulette/fusion_roulette_widget.dart';
import '../../models/spin_data.dart';
import 'fusion_spin_dialog_widget.dart';

class FusionSpinDialogState extends State<FusionSpinDialog>
    with TickerProviderStateMixin {
  // --------------------------------------------------
  // CONFIG
  // --------------------------------------------------
  static const int spinBufferSize = 20;

  // --------------------------------------------------
  // CONTROLLERS
  // --------------------------------------------------
  late final AnimationController _spinControllerTop;
  late final AnimationController _spinControllerBottom;
  late final AnimationController _mergeController;
  late final AnimationController _fusionController;

  // --------------------------------------------------
  // SPIN DATA
  // --------------------------------------------------
  late final SpinData _topSpin;
  late final SpinData _bottomSpin;

  // --------------------------------------------------
  // ANIMATIONS (MERGE)
  // --------------------------------------------------
  late final Animation<double> _mergeRotate;
  late final Animation<double> _mergeScale;
  late final Animation<double> _mergeBrightness;
  late final Animation<Offset> _moveUp;
  late final Animation<Offset> _moveDown;

  // --------------------------------------------------
  // ANIMATIONS (FUSION)
  // --------------------------------------------------
  late final Animation<double> _fusionRotate;
  late final Animation<double> _fusionScale;
  late final Animation<double> _fusionBrightness;

  // --------------------------------------------------
  // UI STATE
  // --------------------------------------------------
  bool _showSpin = true;
  bool _showFusion = false;
  bool _showResultCard = false;

  // --------------------------------------------------
  // HAPTICS STATE
  // --------------------------------------------------
  int _lastMergeVibrationMs = 0;
  bool _fusionImpactTriggered = false;

  // --------------------------------------------------
  // LIFECYCLE
  // --------------------------------------------------
  @override
  void initState() {
    super.initState();

    final rng = Random();

    _topSpin = _buildSpinData(widget.result1, rng);
    _bottomSpin = _buildSpinData(widget.result2, rng, reverse: true);

    _initControllers();
    _initAnimations();
    _initHaptics();

    _startSpinSequence();
  }

  @override
  void dispose() {
    _mergeController.removeListener(_handleMergeHaptics);
    _fusionController.removeListener(_handleFusionHaptics);

    _spinControllerTop.dispose();
    _spinControllerBottom.dispose();
    _mergeController.dispose();
    _fusionController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // INITIALIZATION
  // --------------------------------------------------
  void _initControllers() {
    _spinControllerTop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _spinControllerBottom = AnimationController(
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
  }

  void _initAnimations() {
    _mergeRotate = Tween(begin: 0.0, end: pi / 2).animate(
      CurvedAnimation(parent: _mergeController, curve: Curves.easeInOut),
    );

    _mergeScale = Tween(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _mergeController, curve: Curves.easeIn));

    _mergeBrightness = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mergeController, curve: Curves.easeIn));

    _moveUp = Tween(begin: const Offset(0, -1.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _mergeController, curve: Curves.easeInOut),
    );

    _moveDown = Tween(begin: const Offset(0, 1.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _mergeController, curve: Curves.easeInOut),
    );

    _fusionRotate = Tween(begin: 0.0, end: pi * 6).animate(
      CurvedAnimation(parent: _fusionController, curve: Curves.easeOut),
    );

    _fusionScale = Tween(begin: 0.6, end: 1.2).animate(
      CurvedAnimation(parent: _fusionController, curve: Curves.easeOutBack),
    );

    _fusionBrightness = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fusionController, curve: Curves.easeOut),
    );
  }

  void _initHaptics() {
    _mergeController.addListener(_handleMergeHaptics);
    _fusionController.addListener(_handleFusionHaptics);
  }

  // --------------------------------------------------
  // HAPTICS
  // --------------------------------------------------
  void _handleMergeHaptics() {
    if (!_mergeController.isAnimating) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastMergeVibrationMs < 120) return;

    _lastMergeVibrationMs = now;
    HapticFeedback.vibrate();
  }

  void _handleFusionHaptics() {
    if (_fusionImpactTriggered) return;

    if (_fusionController.value > 0.05) {
      _fusionImpactTriggered = true;
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 40), HapticFeedback.vibrate);
    }
  }

  // --------------------------------------------------
  // SEQUENCE
  // --------------------------------------------------
  Future<void> _startSpinSequence() async {
    await Future.wait([
      _playController(_spinControllerTop),
      _playController(_spinControllerBottom),
    ]);

    // Final spin stop impact
    HapticFeedback.vibrate();
    Future.delayed(const Duration(milliseconds: 40), HapticFeedback.vibrate);

    setState(() {
      _showSpin = false;
      _showFusion = true;
    });

    await _mergeController.forward();
    await _fusionController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _showResultCard = true);

    await Future.delayed(const Duration(seconds: 2));
    widget.onFinished();
  }

  Future<void> _playController(AnimationController controller) {
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

  // --------------------------------------------------
  // SPIN DATA
  // --------------------------------------------------
  SpinData _buildSpinData(Pokemon result, Random rng, {bool reverse = false}) {
    final coreCount = 15 + rng.nextInt(6);

    final pool = List<Pokemon>.from(widget.allPokemon)
      ..remove(result)
      ..shuffle();

    final before = pool.take(spinBufferSize).toList();
    final core = pool.skip(spinBufferSize).take(coreCount).toList();
    final after = pool
        .skip(spinBufferSize + coreCount)
        .take(spinBufferSize)
        .toList();

    var items = [...before, ...core, result, ...after];
    var resultIndex = before.length + core.length;
    var startIndex = rng.nextInt(spinBufferSize ~/ 2) + 2;

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

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_showSpin)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FusionRoulette(
                  controller: _spinControllerTop,
                  data: _topSpin,
                  enableHaptics: true,
                ),
                const SizedBox(height: 24),
                FusionRoulette(
                  controller: _spinControllerBottom,
                  data: _bottomSpin,
                  enableHaptics: true,
                ),
              ],
            ),
          FusionOverlay(
            showFusion: _showFusion,
            showCard: _showResultCard,
            p1: widget.result1,
            p2: widget.result2,
            ball: widget.ball,
            mergeRotate: _mergeRotate,
            mergeScale: _mergeScale,
            mergeBrightness: _mergeBrightness,
            moveUp: _moveUp,
            moveDown: _moveDown,
            fusionRotate: _fusionRotate,
            fusionScale: _fusionScale,
            fusionBrightness: _fusionBrightness,
            mergeController: _mergeController,
            fusionController: _fusionController,
          ),
        ],
      ),
    );
  }
}
