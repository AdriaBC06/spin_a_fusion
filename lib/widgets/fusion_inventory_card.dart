import 'package:flutter/material.dart';

class FusionInventoryCard extends StatelessWidget {
  final String name;
  final String imageUrl; // placeholder for now

  const FusionInventoryCard({
    super.key,
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 2),
      ),
      child: Row(
        children: [
          // Pokémon image placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: imageUrl.isEmpty
                ? const Icon(
                    Icons.catching_pokemon,
                    size: 40,
                    color: Colors.grey,
                  )
                : Image.network(imageUrl, fit: BoxFit.contain),
          ),

          const SizedBox(width: 12),

          // Name / info
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Buttons column
          Column(
            children: [
              ElevatedButton(
                onPressed: () {}, // add to farm (later)
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 32),
                ),
                child: const Text('Añadir'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {}, // sell (later)
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(80, 32),
                ),
                child: const Text('Vender'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
