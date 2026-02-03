import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../models/pokemon.dart';
import '../../models/spin_data.dart';
import '../roulette/spin_roulette_widget.dart';
import '../shared/fusion_overlay.dart';
import 'fusion_spin_dialog_widget.dart';
import '../../../../providers/settings_provider.dart';

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

  bool get _hapticsEnabled =>
      context.read<SettingsProvider>().vibrationEnabled;

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
      duration: _spinDurationFor(_topSpin),
    );

    _spinControllerBottom = AnimationController(
      vsync: this,
      duration: _spinDurationFor(_bottomSpin),
    );

    _mergeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fusionController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  }

  void _initAnimations() {
    _mergeRotate = Tween(begin: 0.0, end: pi / 2).animate(
      CurvedAnimation(parent: _mergeController, curve: Curves.easeInOut),
    );

    _mergeScale = Tween(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _mergeController, curve: Curves.easeIn),
    );

    _mergeBrightness = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mergeController, curve: Curves.easeIn),
    );

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
    if (!_hapticsEnabled) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastMergeVibrationMs < 120) return;

    _lastMergeVibrationMs = now;
    HapticFeedback.vibrate();
  }

  void _handleFusionHaptics() {
    if (_fusionImpactTriggered) return;
    if (!_hapticsEnabled) return;

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

    if (_hapticsEnabled) {
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 40), HapticFeedback.vibrate);
    }

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
  SpinData _buildSpinData(
    Pokemon result,
    Random rng, {
    bool reverse = false,
  }) {
    final coreCount = 15 + rng.nextInt(6);

    final pool = List<Pokemon>.from(widget.allPokemon)
      ..remove(result)
      ..shuffle();

    final before = pool.take(spinBufferSize).toList();
    final core = pool.skip(spinBufferSize).take(coreCount).toList();
    final after =
        pool.skip(spinBufferSize + coreCount).take(spinBufferSize).toList();

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

  Duration _spinDurationFor(SpinData data) {
    const double pixelsPerSecond = 600;
    const int minMs = 4000;
    const int maxMs = 8000;

    final distanceItems =
        (data.resultIndex - data.startIndex).abs().toDouble();
    final distancePixels = distanceItems * SpinRoulette.itemWidth;

    final rawMs = (distancePixels / pixelsPerSecond) * 1000;
    final clampedMs = rawMs.clamp(minMs.toDouble(), maxMs.toDouble());

    return Duration(milliseconds: clampedMs.round());
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final hapticsEnabled =
        context.watch<SettingsProvider>().vibrationEnabled;

    final showContainerBackground = !_showFusion || _showResultCard;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: showContainerBackground
            ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B1020), Color(0xFF151E2C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF00D1FF).withOpacity(0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D1FF).withOpacity(0.2),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              )
            : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_showSpin)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SpinRoulette(
                    controller: _spinControllerTop,
                    data: _topSpin,
                    hapticsEnabled: hapticsEnabled,
                  ),
                  const SizedBox(height: 20),
                  SpinRoulette(
                    controller: _spinControllerBottom,
                    data: _bottomSpin,
                    hapticsEnabled: hapticsEnabled,
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
      ),
    );
  }
}
