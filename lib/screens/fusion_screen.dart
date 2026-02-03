import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fusion_entry.dart';
import '../providers/fusion_collection_provider.dart';
import '../providers/home_slots_provider.dart';
import '../features/fusion/fusion_economy.dart';
import '../features/fusion/widgets/fusion_inventory_card.dart';

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
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0B1020),
                Color(0xFF0E1B36),
                Color(0xFF1A0F3A),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF00D1FF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fusiones',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium,
                    ),
                  ],
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
              backgroundColor: const Color(0xFF00D1FF),
              foregroundColor: Colors.black,
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
