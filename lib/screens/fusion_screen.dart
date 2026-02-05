import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fusion_entry.dart';
import '../providers/fusion_collection_provider.dart';
import '../providers/home_slots_provider.dart';
import '../features/fusion/fusion_economy.dart';
import '../features/fusion/widgets/fusion_inventory_card.dart';

enum FusionSortField {
  name,
  income,
  favorite,
}

class FusionScreen extends StatefulWidget {
  const FusionScreen({super.key});

  @override
  State<FusionScreen> createState() => _FusionScreenState();
}

class _FusionScreenState extends State<FusionScreen> {
  FusionSortField? _sortField;
  bool _ascending = true;

  List<FusionEntry> _sorted(List<FusionEntry> fusions) {
    final list = List<FusionEntry>.from(fusions);
    if (_sortField == null) return list;

    int compare(FusionEntry a, FusionEntry b) {
      int result;
      switch (_sortField!) {
        case FusionSortField.name:
          result = a.fusionName.compareTo(b.fusionName);
          break;
        case FusionSortField.income:
          result = FusionEconomy.incomePerSecond(a)
              .compareTo(FusionEconomy.incomePerSecond(b));
          break;
        case FusionSortField.favorite:
          if (a.favorite == b.favorite) {
            result = 0;
          } else {
            result = a.favorite ? -1 : 1;
          }
          break;
      }
      return _ascending ? result : -result;
    }

    list.sort(compare);
    return list;
  }

  // ----------------------------
  // SORT MENU (HALF WIDTH + TAP OUTSIDE TO CLOSE)
  // ----------------------------
  void _openSortMenu() {
    final width = MediaQuery.of(context).size.width * 0.55;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context), // tap outside
          child: Align(
            alignment: Alignment.bottomLeft,
            child: GestureDetector(
              onTap: () {}, // absorb taps inside menu
              child: Container(
                width: width,
                decoration: const BoxDecoration(
                  color: Color(0xFF111C33),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _sortTile(FusionSortField.name, 'Nombre'),
                      _sortTile(
                          FusionSortField.income, 'Dinero generado'),
                      _sortTile(
                          FusionSortField.favorite, 'Favoritos'),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sortTile(FusionSortField field, String label) {
    final bool active = _sortField == field;
    final IconData? arrow = active
        ? (_ascending
            ? Icons.arrow_upward
            : Icons.arrow_downward)
        : null;

    return ListTile(
      onTap: () {
        setState(() {
          if (_sortField == field) {
            if (field == FusionSortField.favorite) {
              _sortField = null;
            } else {
              _ascending = !_ascending;
            }
          } else {
            _sortField = field;
            _ascending = field != FusionSortField.income;
          }
        });
        Navigator.pop(context);
      },
      title: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (arrow != null) ...[
            const SizedBox(width: 8),
            Icon(
              arrow,
              color: Color(0xFF00D1FF),
              size: 18,
            ),
          ],
        ],
      ),
    );
  }

  void _addBestFusions(
    BuildContext context,
    List<FusionEntry> fusions,
  ) {
    final slots = context.read<HomeSlotsProvider>();
    final unlocked = slots.unlockedCount;
    final current = List<FusionEntry?>.from(slots.slots);
    final homeKeys = <String>{
      for (final fusion in current)
        if (fusion != null) _key(fusion),
    };

    final sorted = List<FusionEntry>.from(fusions)
      ..sort((a, b) {
        final incomeA = FusionEconomy.incomePerSecond(a);
        final incomeB = FusionEconomy.incomePerSecond(b);
        if (incomeA != incomeB) {
          return incomeB.compareTo(incomeA);
        }

        if (a.favorite != b.favorite) {
          return a.favorite ? -1 : 1;
        }

        final aInHome = homeKeys.contains(_key(a));
        final bInHome = homeKeys.contains(_key(b));
        if (aInHome != bInHome) {
          return aInHome ? -1 : 1;
        }

        return 0;
      });

    final best = sorted.take(unlocked).toList();

    for (int i = 0; i < unlocked; i++) {
      final fusion = i < best.length ? best[i] : null;
      slots.setSlot(i, fusion);
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
      final isProtected =
          inHome || protectedTopN.contains(fusion);
      if (!isProtected && !fusion.favorite) {
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
      List<FusionEntry> fusions, int n) {
    if (n <= 0) return [];
    final sorted = List<FusionEntry>.from(fusions)
      ..sort(
        (a, b) => FusionEconomy.incomePerSecond(b)
            .compareTo(FusionEconomy.incomePerSecond(a)),
      );
    return sorted.take(n).toList();
  }

  @override
  Widget build(BuildContext context) {
    final fusionProvider =
        context.watch<FusionCollectionProvider>();
    final fusions = _sorted(fusionProvider.fusions);

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Color(0xFF00D1FF)),
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
                        (f) =>
                            FusionInventoryCard(fusion: f),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 140),
            ],
          ),
        ),

        // AUTO-VENDER
        Positioned(
          right: 16,
          bottom: 84,
          child: ElevatedButton.icon(
            onPressed: fusions.isEmpty
                ? null
                : () => _autoSellFusions(context, fusions),
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Auto-vender'),
          ),
        ),

        // SORT
        Positioned(
          left: 16,
          bottom: 16,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2D95),
              foregroundColor: Colors.white,
            ),
            onPressed:
                fusions.isEmpty ? null : _openSortMenu,
            icon: const Icon(Icons.sort),
            label: const Text('Ordenar'),
          ),
        ),

        // AÑADIR MEJORES
        Positioned(
          right: 16,
          bottom: 16,
          child: ElevatedButton(
            onPressed: fusions.isEmpty
                ? null
                : () => _addBestFusions(context, fusions),
            child: const Text('Añadir Mejores'),
          ),
        ),
      ],
    );
  }
}
