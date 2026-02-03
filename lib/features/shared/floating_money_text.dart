import 'package:flutter/material.dart';

class FloatingMoneyText extends StatefulWidget {
  final int amount;

  const FloatingMoneyText({
    super.key,
    required this.amount,
  });

  @override
  State<FloatingMoneyText> createState() =>
      _FloatingMoneyTextState();
}

class _FloatingMoneyTextState extends State<FloatingMoneyText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _dy;
  bool _started = false;
  double _travelPx = 0;

  static const double _fontSize = 14;
  static const double _travelEm = 1.6;
  static const double _pixelsPerSecond = 90;
  static const int _minMs = 500;
  static const int _maxMs = 1200;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _opacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final textScale = MediaQuery.textScaleFactorOf(context);
    _travelPx = _fontSize * textScale * _travelEm;

    final durationMs =
        (_travelPx / _pixelsPerSecond * 1000).clamp(_minMs, _maxMs).round();
    _controller.duration = Duration(milliseconds: durationMs);

    _dy = Tween(begin: 0.0, end: -_travelPx).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _dy.value),
          child: child,
        );
      },
      child: FadeTransition(
        opacity: _opacity,
        child: Text(
          '+${widget.amount}',
          style: const TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: _fontSize,
          ),
        ),
      ),
    );
  }
}
