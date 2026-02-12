import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/fusion_entry.dart';
import '../../../providers/home_slots_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/game_provider.dart';
import '../fusion_economy.dart';
import 'fusion_summary_modal.dart';
import '../../../core/constants/pokedex_constants.dart';
import '../../../core/network/fusion_image_proxy.dart';

class FusionInventoryCard extends StatelessWidget {
  final FusionEntry fusion;

  const FusionInventoryCard({
    super.key,
    required this.fusion,
  });

  String _ballLabel(BallType ball) {
    switch (ball) {
      case BallType.poke:
        return 'Poké';
      case BallType.superBall:
        return 'Super';
      case BallType.ultra:
        return 'Ultra';
      case BallType.master:
        return 'Master';
      case BallType.silver:
        return 'Silver';
      case BallType.gold:
        return 'Gold';
      case BallType.ruby:
        return 'Ruby';
      case BallType.sapphire:
        return 'Sapphire';
      case BallType.emerald:
        return 'Emerald';
      case BallType.test:
        return 'Test';
    }
  }

  Color _ballColor(BallType ball) {
    switch (ball) {
      case BallType.poke:
        return Colors.red;
      case BallType.superBall:
        return Colors.blue;
      case BallType.ultra:
        return Colors.amber;
      case BallType.master:
        return Colors.purple;
      case BallType.silver:
        return const Color(0xFFB8BCC6);
      case BallType.gold:
        return const Color(0xFFFFD76B);
      case BallType.ruby:
        return const Color(0xFFE84D4D);
      case BallType.sapphire:
        return const Color(0xFF4C7BFF);
      case BallType.emerald:
        return const Color(0xFF2ECC71);
      case BallType.test:
        return Colors.white;
    }
  }

  bool _modifierMatchesBall(FusionEntry fusion) {
    switch (fusion.ball) {
      case BallType.silver:
        return fusion.modifier == FusionModifier.silver;
      case BallType.gold:
        return fusion.modifier == FusionModifier.gold;
      case BallType.ruby:
        return fusion.modifier == FusionModifier.ruby;
      case BallType.sapphire:
        return fusion.modifier == FusionModifier.sapphire;
      case BallType.emerald:
        return fusion.modifier == FusionModifier.emerald;
      case BallType.poke:
      case BallType.superBall:
      case BallType.ultra:
      case BallType.master:
      case BallType.test:
        return false;
    }
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.6),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Color? _modifierColor(FusionEntry fusion) {
    final modifier = fusion.modifier;
    if (modifier == null) return null;
    return fusionModifierColors[modifier];
  }

  Widget _imageUnavailable() {
    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.white54,
        size: 36,
      ),
    );
  }

  Widget _networkImage({
    required String url,
    BoxFit fit = BoxFit.contain,
    String? imageKey,
    Widget Function()? onError,
  }) {
    return Image.network(
      key: imageKey == null ? null : ValueKey(imageKey),
      resolveFusionImageUrl(url),
      fit: fit,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (_, _, _) => onError == null ? _imageUnavailable() : onError(),
    );
  }

  Widget _fusionImage(FusionEntry fusion) {
    Widget secondary = _networkImage(
      url: fusion.autoGenFusionUrl,
      imageKey: 'inventory-${fusion.uid}-autogen',
      onError: _imageUnavailable,
    );

    return _networkImage(
      url: fusion.customFusionUrl,
      imageKey: 'inventory-${fusion.uid}-custom',
      onError: () => secondary,
    );
  }

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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _modifierColor(fusion) == null
                        ? _fusionImage(fusion)
                        : ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              _modifierColor(fusion)!
                                  .withOpacity(0.45),
                              BlendMode.srcATop,
                            ),
                            child: _fusionImage(fusion),
                          ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () =>
                          collection.toggleFavorite(fusion),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: fusion.favorite
                                ? const Color(0xFFFFD645)
                                : Colors.white24,
                          ),
                        ),
                        child: Icon(
                          fusion.favorite
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: fusion.favorite
                              ? const Color(0xFFFFD645)
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
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
                const SizedBox(height: 6),
                if (fusion.modifier != null)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _chip(
                        fusionModifierLabels[fusion.modifier!]!
                            .toUpperCase(),
                        fusionModifierColors[fusion.modifier!]!,
                      ),
                    ],
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
