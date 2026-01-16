import 'package:flutter/material.dart';

class MoneyCounter extends StatelessWidget {
  final int amount;

  const MoneyCounter({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.monetization_on,
              color: Colors.yellow,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              amount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
