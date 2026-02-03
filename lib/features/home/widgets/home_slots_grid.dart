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
        return HomeSlotTile(
          index: index,
          fusion: slots[index],
        );
      },
    );
  }
}
