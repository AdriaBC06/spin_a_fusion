import 'package:flutter/material.dart';
import 'home_slot_item.dart';

class HomeSlotsGrid extends StatelessWidget {
  const HomeSlotsGrid({super.key});

  static const int totalSlots = 12;
  static const int unlockedSlots = 3;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: totalSlots,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return HomeSlotItem(
          unlocked: index < unlockedSlots,
        );
      },
    );
  }
}
