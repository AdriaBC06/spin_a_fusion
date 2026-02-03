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
            title: const Text('Desbloquear casilla'),
            content: Text(
              '¿Gastar $cost diamantes para desbloquear esta casilla?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Comprar'),
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
                    ? '❌ No tienes suficientes diamantes'
                    : '❌ Casilla no disponible',
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B1020), Color(0xFF2B0F46)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFF2D95).withOpacity(0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF2D95).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock,
                color: Colors.white,
                size: 26,
              ),
              if (cost != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF2D95)
                          .withOpacity(0.6),
                    ),
                  ),
                  child: Text(
                    '$cost 💎',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
