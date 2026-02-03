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

    // 1️⃣ Sort by income/sec DESC
    final sorted = List<FusionEntry>.from(fusions)
      ..sort(
        (a, b) =>
            FusionEconomy.incomePerSecond(b)
                .compareTo(
          FusionEconomy.incomePerSecond(a),
        ),
      );

    String _key(FusionEntry fusion) =>
        '${fusion.p1.fusionId}:${fusion.p2.fusionId}';

    final unlocked = slots.unlockedCount;
    final current = List<FusionEntry?>.from(slots.slots);

    final available = List<FusionEntry>.from(sorted);

    void _removeOneAvailable(FusionEntry fusion) {
      final target = _key(fusion);
      final index = available.indexWhere(
        (f) => _key(f) == target,
      );
      if (index >= 0) {
        available.removeAt(index);
      }
    }

    for (int i = 0; i < unlocked; i++) {
      final currentFusion = current[i];
      if (currentFusion != null) {
        _removeOneAvailable(currentFusion);
      }
    }

    FusionEntry? _nextBest() =>
        available.isEmpty ? null : available.removeAt(0);

    // 2️⃣ Fill empty slots first
    for (int i = 0; i < unlocked; i++) {
      final currentFusion = current[i];
      if (currentFusion != null) continue;

      final best = _nextBest();
      if (best == null) break;
      slots.setSlot(i, best);
    }

    // 3️⃣ Replace only if strictly better (no wasted picks)
    for (int i = 0; i < unlocked; i++) {
      final currentFusion = current[i];
      if (currentFusion == null) continue;

      if (available.isEmpty) break;
      final best = available.first;

      final currentIncome =
          FusionEconomy.incomePerSecond(currentFusion);
      final bestIncome = FusionEconomy.incomePerSecond(best);

      if (bestIncome > currentIncome) {
        slots.setSlot(i, best);
        available.removeAt(0);
      }
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
