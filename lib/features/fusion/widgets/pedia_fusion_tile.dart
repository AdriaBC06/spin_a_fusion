import 'package:flutter/material.dart';
import '../../../models/fusion_entry.dart';
import 'fusion_summary_modal.dart';

class PediaFusionTile extends StatelessWidget {
  final FusionEntry fusion;

  const PediaFusionTile({
    super.key,
    required this.fusion,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => FusionSummaryModal(fusion: fusion),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Image.network(
            fusion.customFusionUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Image.network(fusion.autoGenFusionUrl),
          ),
        ),
      ),
    );
  }
}
