import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fusion_pedia_provider.dart';
import '../providers/game_provider.dart';
import '../features/fusion/widgets/pedia_fusion_tile.dart';

class PediaScreen extends StatelessWidget {
  const PediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedia = context.watch<FusionPediaProvider>();
    final fusions = pedia.sortedFusions;
    final pendingCount = pedia.pendingCount;

    if (pedia.isEmpty) {
      return const Center(
        child: Text(
          'No fusions unlocked yet',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Column(
      children: [
        if (pendingCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final claimed =
                      context.read<FusionPediaProvider>()
                          .claimAllPending();
                  if (claimed > 0) {
                    context.read<GameProvider>()
                        .addDiamonds(claimed);
                  }
                },
                child: Text('Reclamar todos ($pendingCount)'),
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: fusions.length,
            itemBuilder: (context, index) {
              return PediaFusionTile(
                fusion: fusions[index],
              );
            },
          ),
        ),
      ],
    );
  }
}
