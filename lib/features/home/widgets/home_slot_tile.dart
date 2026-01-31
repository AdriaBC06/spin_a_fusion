import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/fusion_entry.dart';
import '../../../providers/home_slots_provider.dart';
import '../../../economy/fusion_economy.dart';
import '../../shared/floating_money_text.dart';
import '../../fusion/widgets/fusion_summary_modal.dart';

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
        widget.index < HomeSlotsProvider.unlockedSlots;

    // LOCKED
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

    // EMPTY
    if (widget.fusion == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
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
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => slots.removeFusion(fusion),
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // 💰 INCOME TEXT
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '$incomePerSec Dinero/s',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
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
