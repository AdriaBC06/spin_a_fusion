import 'package:flutter/material.dart';

class HomeSlotItem extends StatelessWidget {
  final bool unlocked;

  const HomeSlotItem({
    super.key,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.catching_pokemon, size: 40),
          ),
          if (!unlocked)
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.lock, color: Colors.white, size: 30),
              ),
            ),
        ],
      ),
    );
  }
}
