import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fusion_collection_provider.dart';
import '../widgets/fusion_inventory_card.dart';

class FusionScreen extends StatelessWidget {
  const FusionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fusions = context.watch<FusionCollectionProvider>().fusions;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 72),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Fusiones',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: fusions
                  .map((fusion) => FusionInventoryCard(fusion: fusion))
                  .toList(),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
