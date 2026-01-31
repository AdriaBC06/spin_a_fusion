import 'package:flutter/material.dart';

class ShopBallCard extends StatelessWidget {
  final String name;
  final Color color;
  final int price;
  final bool enabled;
  final VoidCallback onBuy;

  const ShopBallCard({
    super.key,
    required this.name,
    required this.color,
    required this.price,
    required this.onBuy,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nombre + precio
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    size: 18,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    price.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Botón comprar
          ElevatedButton(
            onPressed: enabled ? onBuy : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }
}
