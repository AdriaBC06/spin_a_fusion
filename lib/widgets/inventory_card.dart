import 'package:flutter/material.dart';

class InventoryBallCard extends StatelessWidget {
  final String name;
  final Color color;
  final int amount;

  const InventoryBallCard({
    super.key,
    required this.name,
    required this.color,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = amount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          // Icon
          Icon(
            Icons.catching_pokemon,
            color: color,
            size: 32,
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
                  ),
                ),
                Text(
                  'Cantidad: $amount',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Open button
          ElevatedButton(
            onPressed: enabled ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              disabledBackgroundColor: Colors.grey.shade400,
            ),
            child: const Text('Abrir'),
          ),
        ],
      ),
    );
  }
}
