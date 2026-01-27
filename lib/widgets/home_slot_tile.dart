import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/fusion_entry.dart';
import '../providers/home_slots_provider.dart';

class HomeSlotTile extends StatelessWidget {
  final int index;
  final FusionEntry? fusion;

  const HomeSlotTile({
    super.key,
    required this.index,
    required this.fusion,
  });

  @override
  Widget build(BuildContext context) {
    final slots = context.read<HomeSlotsProvider>();
    final bool unlocked = index < HomeSlotsProvider.unlockedSlots;

    // LOCKED SLOT
    if (!unlocked) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.lock, color: Colors.white),
        ),
      );
    }

    // EMPTY SLOT
    if (fusion == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    final entry = fusion!;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    entry.customFusionUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return Image.network(
                        entry.autoGenFusionUrl,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // REMOVE BUTTON
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => slots.removeFusion(entry),
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
