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

  void _autoSellFusions(
    BuildContext context,
    List<FusionEntry> fusions,
  ) {
    final slots = context.read<HomeSlotsProvider>();
    final collection = context.read<FusionCollectionProvider>();

    final homeKeys = <String>{
      for (final fusion in slots.slots)
        if (fusion != null) _key(fusion),
    };

    final protectedTopN = _topNFusions(
      fusions,
      slots.unlockedCount,
    ).toSet();

    final toSell = <FusionEntry>[];

    for (final fusion in fusions) {
      final inHome = homeKeys.contains(_key(fusion));
      final isProtected = inHome || protectedTopN.contains(fusion);
      final isFavorite = fusion.favorite;

      if (!isProtected && !isFavorite) {
        toSell.add(fusion);
      }
    }

    for (final fusion in toSell) {
      collection.removeFusion(fusion, homeSlots: slots);
    }
  }

  String _key(FusionEntry fusion) =>
      '${fusion.p1.fusionId}:${fusion.p2.fusionId}';

  List<FusionEntry> _topNFusions(
    List<FusionEntry> fusions,
    int n,
  ) {
    if (n <= 0) return [];

    final sorted = List<FusionEntry>.from(fusions)
      ..sort(
        (a, b) =>
            FusionEconomy.incomePerSecond(b)
                .compareTo(FusionEconomy.incomePerSecond(a)),
      );

    if (sorted.length <= n) return sorted;
    return sorted.take(n).toList();
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
        Positioned(
          left: 16,
          bottom: 16,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              backgroundColor: const Color(0xFFFF2D95),
              foregroundColor: Colors.white,
            ),
            onPressed: fusions.isEmpty
                ? null
                : () => _autoSellFusions(context, fusions),
            icon: const Icon(Icons.delete_sweep),
            label: const Text(
              'Auto-vender',
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
