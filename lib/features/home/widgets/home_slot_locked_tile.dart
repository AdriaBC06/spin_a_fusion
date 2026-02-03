import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/home_slots_provider.dart';
import '../../../providers/game_provider.dart';

class HomeSlotLockedTile extends StatelessWidget {
  final int index;

  const HomeSlotLockedTile({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final slots = context.read<HomeSlotsProvider>();
    final cost = slots.nextUnlockCost;

    return GestureDetector(
      onTap: () async {
        if (cost == null) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Unlock Slot'),
            content: Text(
              'Spend $cost diamonds to unlock this slot?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Buy'),
              ),
            ],
          ),
        );

        if (confirmed != true) return;

        final success = slots.unlockNextSlot();
        if (!success && context.mounted) {
          final diamonds =
              context.read<GameProvider>().diamonds;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                diamonds < (cost ?? 0)
                    ? '❌ Not enough diamonds'
                    : '❌ Slot unavailable',
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, color: Colors.white),
              if (cost != null) ...[
                const SizedBox(height: 4),
                Text(
                  '$cost 💎',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
