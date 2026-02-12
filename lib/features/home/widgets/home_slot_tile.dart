import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/fusion_entry.dart';
import '../../../providers/home_slots_provider.dart';
import '../../fusion/fusion_economy.dart';
import '../../shared/floating_money_text.dart';
import '../../fusion/widgets/fusion_summary_modal.dart';
import 'home_slot_locked_tile.dart';
import '../../../core/constants/pokedex_constants.dart';
import '../../../core/network/fusion_image_proxy.dart';

class HomeSlotTile extends StatefulWidget {
  final int index;
  final FusionEntry? fusion;

  const HomeSlotTile({
    super.key,
    required this.index,
    required this.fusion,
  });

  @override
  State<HomeSlotTile> createState() => _HomeSlotTileState();
}

class _HomeSlotTileState extends State<HomeSlotTile> {
  final List<int> _floatingAmounts = [];

  Widget _imageUnavailable() {
    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.white54,
        size: 32,
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
    final secondary = _networkImage(
      url: fusion.autoGenFusionUrl,
      imageKey: 'home-${fusion.uid}-autogen',
      onError: _imageUnavailable,
    );
    return _networkImage(
      url: fusion.customFusionUrl,
      imageKey: 'home-${fusion.uid}-custom',
      onError: () => secondary,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final slots = context.read<HomeSlotsProvider>();

    slots.incomeStream.listen((event) {
      if (event.slotIndex == widget.index &&
          mounted) {
        setState(() {
          _floatingAmounts.add(event.amount);
        });

        Future.delayed(
          const Duration(milliseconds: 900),
          () {
            if (mounted) {
              setState(() {
                _floatingAmounts.remove(event.amount);
              });
            }
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final slots = context.read<HomeSlotsProvider>();
    final unlocked =
        widget.index < slots.unlockedCount;

    // LOCKED
    if (!unlocked) {
      return HomeSlotLockedTile(index: widget.index);
    }

    // EMPTY
    if (widget.fusion == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF111C33), Color(0xFF182647)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF00D1FF).withOpacity(0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D1FF).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white54,
            size: 28,
          ),
        ),
      );
    }

    final fusion = widget.fusion!;
    final incomePerSec =
        FusionEconomy.incomePerSecond(fusion);
    final modifierColor = fusion.modifier == null
        ? null
        : fusionModifierColors[fusion.modifier!];

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) =>
              FusionSummaryModal(fusion: fusion),
        );
      },
      child: Stack(
        children: [
          // TILE
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B1020), Color(0xFF15254A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF00D1FF).withOpacity(0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D1FF).withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: modifierColor == null
                  ? _fusionImage(fusion)
                  : ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        modifierColor.withOpacity(0.45),
                        BlendMode.srcATop,
                      ),
                      child: _fusionImage(fusion),
                    ),
            ),
          ),

          // ❌ REMOVE
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => slots.removeFusion(fusion),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF2D95),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF2D95)
                          .withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          if (modifierColor != null)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: modifierColor.withOpacity(0.8),
                  ),
                ),
                child: Text(
                  fusionModifierLabels[fusion.modifier!]!
                      .toUpperCase(),
                  style: TextStyle(
                    color: modifierColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),

          // 💰 INCOME TEXT
          Positioned(
            bottom: 6,
            left: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF00D1FF)
                      .withOpacity(0.4),
                ),
              ),
              child: Text(
                '$incomePerSec Dinero/s',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CFF8A),
                ),
              ),
            ),
          ),

          // ✨ FLOATING MONEY
          ..._floatingAmounts.map(
            (amount) => Center(
              child: FloatingMoneyText(amount: amount),
            ),
          ),
        ],
      ),
    );
  }
}
