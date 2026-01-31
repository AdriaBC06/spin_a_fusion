import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/fusion_entry.dart';
import '../../../providers/home_slots_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../economy/fusion_economy.dart';
import 'fusion_summary_modal.dart';

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
    final int incomePerSec =
        FusionEconomy.incomePerSecond(fusion);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ----------------------------
            // BIG IMAGE (FITS CONTAINER)
            // ----------------------------
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      FusionSummaryModal(fusion: fusion),
                );
              },
              child: SizedBox(
                width: 96,
                height: 96,
                child: Image.network(
                  fusion.customFusionUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Image.network(
                    fusion.autoGenFusionUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ----------------------------
            // INFO
            // ----------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fusion.fusionName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$incomePerSec Dinero/s',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ----------------------------
            // ACTIONS
            // ----------------------------
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

                    final value =
                        FusionEconomy.sellPrice(fusion);
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