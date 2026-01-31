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
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _opacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _offset = Tween(
      begin: Offset.zero,
      end: const Offset(0, -0.8),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: FadeTransition(
        opacity: _opacity,
        child: Text(
          '+${widget.amount}',
          style: const TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
