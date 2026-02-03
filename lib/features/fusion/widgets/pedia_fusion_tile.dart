import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/fusion_entry.dart';
import '../../../providers/fusion_pedia_provider.dart';
import '../../../providers/game_provider.dart';
import 'fusion_summary_modal.dart';

class PediaFusionTile extends StatelessWidget {
  final FusionEntry fusion;

  const PediaFusionTile({
    super.key,
    required this.fusion,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = fusion.claimPending;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => FusionSummaryModal(fusion: fusion),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF111C33), Color(0xFF182647)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF00D1FF).withOpacity(0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D1FF).withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Image.network(
                fusion.customFusionUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Image.network(fusion.autoGenFusionUrl),
              ),
            ),
            if (isPending)
              const Positioned(
                top: 6,
                right: 6,
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xFFFF2D95),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            if (isPending)
              Positioned(
                left: 6,
                right: 6,
                bottom: 4,
                child: ElevatedButton(
                  onPressed: () {
                    final pedia =
                        context.read<FusionPediaProvider>();
                    final game = context.read<GameProvider>();

                    if (pedia.claimFusion(fusion)) {
                      game.addDiamonds(1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2D95),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 2),
                    minimumSize: const Size(0, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Reclamar'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
