import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fusion_entry.dart';
import '../providers/fusion_collection_provider.dart';
import '../providers/home_slots_provider.dart';
import '../providers/game_provider.dart';
import 'fusion_summary_modal.dart';
import '../economy/fusion_economy.dart';

class FusionInventoryCard extends StatelessWidget {
  final FusionEntry fusion;

  const FusionInventoryCard({
    super.key,
    required this.fusion,
  });

  @override
  Widget build(BuildContext context) {
    final slots = context.watch<HomeSlotsProvider>();
    final collection = context.read<FusionCollectionProvider>();
    final game = context.read<GameProvider>();

    final bool isAdded = slots.contains(fusion);
    final bool canAdd = slots.hasEmptyUnlockedSlot;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // IMAGE + NAME
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        FusionSummaryModal(fusion: fusion),
                  );
                },
                child: Row(
                  children: [
                    Image.network(
                      fusion.customFusionUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Image.network(
                        fusion.autoGenFusionUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fusion.fusionName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // BUTTONS (VERTICAL)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: isAdded
                      ? () => slots.removeFusion(fusion)
                      : canAdd
                          ? () => slots.addFusion(fusion)
                          : null,
                  child: Text(isAdded ? 'Quitar' : 'Añadir'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    if (isAdded) {
                      slots.removeFusion(fusion);
                    }
                    collection.removeFusion(fusion);

                    final value = FusionEconomy.sellPrice(fusion);
game.addMoney(value);
                  },
                  child: const Text('Vender'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
