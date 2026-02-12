import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/daily_missions_provider.dart';

class DailyMissionsButton extends StatelessWidget {
  const DailyMissionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final missions = context.watch<DailyMissionsProvider>();
    final claimable = missions.claimableCount;

    return GestureDetector(
      onTap: () => _openMissionsDialog(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade800,
            child: const Icon(Icons.flag_rounded, color: Colors.white),
          ),
          if (claimable > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF2D95),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$claimable',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openMissionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _DailyMissionsDialog(),
    );
  }
}

class _DailyMissionsDialog extends StatelessWidget {
  const _DailyMissionsDialog();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DailyMissionsProvider>();
    final missions = provider.missions;

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Misiones diarias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...missions.map((mission) {
              final progress = mission.progress > mission.target
                  ? mission.target
                  : mission.progress;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF101826),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: mission.target == 0 ? 0 : progress / mission.target,
                      backgroundColor: Colors.white12,
                      color: const Color(0xFF00D1FF),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '$progress/${mission.target}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const Spacer(),
                        Text(
                          'Recompensa: ${mission.rewardDiamonds} 💎',
                          style: const TextStyle(
                            color: Color(0xFF9CFF8A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: mission.canClaim
                            ? () {
                                final ok = context
                                    .read<DailyMissionsProvider>()
                                    .claimMission(mission.id);
                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '✅ +${mission.rewardDiamonds} diamantes',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: Text(mission.claimed ? 'Reclamada' : 'Reclamar'),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
