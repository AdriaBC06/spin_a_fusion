import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/fusion_entry.dart';
import '../../../providers/home_slots_provider.dart';
import '../../fusion/fusion_economy.dart';
import '../../shared/floating_money_text.dart';
import '../../fusion/widgets/fusion_summary_modal.dart';
import 'home_slot_locked_tile.dart';

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
