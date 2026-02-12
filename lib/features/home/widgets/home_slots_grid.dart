import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/home_slots_provider.dart';
import 'home_slot_tile.dart';

class HomeSlotsGrid extends StatelessWidget {
  const HomeSlotsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final slots =
        context.watch<HomeSlotsProvider>().displaySlots;

    return GridView.builder(
      itemCount: slots.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (_, index) {
        final fusion = slots[index];
        final fusionKey = fusion == null
            ? 'empty'
            : (fusion.uid?.toString() ??
                '${fusion.p1.fusionId}:${fusion.p2.fusionId}');
        return HomeSlotTile(
          key: ValueKey('home-slot-$index-$fusionKey'),
          index: index,
          fusion: fusion,
        );
      },
    );
  }
}
