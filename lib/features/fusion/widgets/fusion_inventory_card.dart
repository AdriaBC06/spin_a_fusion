import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/fusion_entry.dart';
import '../../../providers/home_slots_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/game_provider.dart';
import '../fusion_economy.dart';
import 'fusion_summary_modal.dart';
import '../../../core/constants/pokedex_constants.dart';

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
    final int totalFusions = collection.fusions.length;
    final int money = game.money;
    final int minBallPrice = ballPrices[BallType.poke]!;
    final bool hasAnyBall = BallType.values
        .any((type) => game.ballCount(type) > 0);

    bool _canSell() {
      if (money >= minBallPrice) {
        return totalFusions > 0;
      }
      if (hasAnyBall) {
        return totalFusions > 0;
      }
      return totalFusions > 2;
    }

    Future<bool> _confirmSellIfInHome() async {
      if (!isAdded) return true;

      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Atención'),
            content: const Text(
              'Esta fusión está en tu hogar. Si la vendes, se quitará del hogar. ¿Deseas continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Vender'),
              ),
            ],
          );
        },
      );

      return result ?? false;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111C33), Color(0xFF182647)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF00D1FF).withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D1FF).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      const Color(0xFF00D1FF).withOpacity(0.4),
                ),
              ),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF00D1FF)
                          .withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    '$incomePerSec Dinero/s',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9CFF8A),
                    ),
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
                  backgroundColor: const Color(0xFFFF2D95),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (!_canSell()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '❌ Debes conservar al menos una fusión',
                        ),
                      ),
                    );
                    return;
                  }
                  final shouldSell = await _confirmSellIfInHome();
                  if (!shouldSell) return;
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
    );
  }
}
