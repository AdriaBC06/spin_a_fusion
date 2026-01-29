import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fusion_pedia_provider.dart';
import '../widgets/pedia_fusion_tile.dart';

class PediaScreen extends StatelessWidget {
  const PediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedia = context.watch<FusionPediaProvider>();
    final fusions = pedia.sortedFusions;

    if (pedia.isEmpty) {
      return const Center(
        child: Text(
          'No fusions unlocked yet',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: fusions.length,
      itemBuilder: (context, index) {
        return PediaFusionTile(
          fusion: fusions[index],
        );
      },
    );
  }
}
