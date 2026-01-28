import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fusion_entry.dart';
import '../providers/fusion_collection_provider.dart';
import '../providers/home_slots_provider.dart';
import '../economy/fusion_economy.dart';
import '../widgets/fusion_inventory_card.dart';

class FusionScreen extends StatelessWidget {
  const FusionScreen({super.key});

  void _addBestFusions(
    BuildContext context,
    List<FusionEntry> fusions,
  ) {
    final slots = context.read<HomeSlotsProvider>();

    // 1️⃣ Remove everything from Home
    for (final fusion in List<FusionEntry?>.from(slots.slots)) {
      if (fusion != null) {
        slots.removeFusion(fusion);
      }
    }

    // 2️⃣ Sort by income/sec DESC
    final sorted = List<FusionEntry>.from(fusions)
      ..sort(
        (a, b) =>
            FusionEconomy.incomePerSecond(b)
                .compareTo(
              FusionEconomy.incomePerSecond(a),
            ),
      );

    // 3️⃣ Add best until slots are full
    for (final fusion in sorted) {
      if (!slots.hasEmptyUnlockedSlot) break;
      slots.addFusion(fusion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fusionProvider =
        context.watch<FusionCollectionProvider>();
    final List<FusionEntry> fusions =
        fusionProvider.fusions;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 72),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Fusiones',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: fusions
                      .map(
                        (fusion) =>
                            FusionInventoryCard(
                                fusion: fusion),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),

        // ---------------------------------
        // AÑADIR MEJORES BUTTON
        // ---------------------------------
        Positioned(
          right: 16,
          bottom: 16,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              backgroundColor: Colors.green,
            ),
            onPressed: fusions.isEmpty
                ? null
                : () => _addBestFusions(context, fusions),
            child: const Text(
              'Añadir Mejores',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
