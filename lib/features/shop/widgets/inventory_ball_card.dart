import 'package:flutter/material.dart';

class InventoryBallCard extends StatelessWidget {
  final String name;
  final Color color;
  final int amount;
  final VoidCallback onOpen;

  const InventoryBallCard({
    super.key,
    required this.name,
    required this.color,
    required this.amount,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = amount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.25),
            const Color(0xFF0B1020),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.35),
              border: Border.all(color: color, width: 1.2),
            ),
            child: Icon(
              Icons.catching_pokemon,
              color: color,
              size: 26,
            ),
          ),

          const SizedBox(width: 12),

          // Name + amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Cantidad: $amount',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Open button
          ElevatedButton(
            onPressed: enabled ? onOpen : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.white24,
            ),
            child: const Text('Abrir'),
          ),
        ],
      ),
    );
  }
}
