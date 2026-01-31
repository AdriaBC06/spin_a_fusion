import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class DiamondCounter extends StatelessWidget {
  const DiamondCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final diamonds = context.watch<GameProvider>().diamonds;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            diamonds.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
