import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../features/cloud/services/firebase_sync_service.dart';
import '../../../providers/daily_missions_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/fusion_pedia_provider.dart';
import '../../../providers/home_slots_provider.dart';

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

class _DailyMissionsDialog extends StatefulWidget {
  const _DailyMissionsDialog();

  @override
  State<_DailyMissionsDialog> createState() => _DailyMissionsDialogState();
}

class _DailyMissionsDialogState extends State<_DailyMissionsDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatCountdown(Duration d) {
    final total = d.inSeconds < 0 ? 0 : d.inSeconds;
    final h = (total ~/ 3600).toString().padLeft(2, '0');
    final m = ((total % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DailyMissionsProvider>();
    final missions = provider.missions;
    final remaining = provider.timeUntilReset;

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: mission.target == 0 ? 0 : progress / mission.target,
                        backgroundColor: Colors.white12,
                        color: const Color(0xFF00D1FF),
                        minHeight: 10,
                      ),
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
                                  FirebaseSyncService()
                                      .sync(
                                        game: context.read<GameProvider>(),
                                        collection: context
                                            .read<FusionCollectionProvider>(),
                                        pedia: context
                                            .read<FusionPediaProvider>(),
                                        homeSlots:
                                            context.read<HomeSlotsProvider>(),
                                        dailyMissions: context
                                            .read<DailyMissionsProvider>(),
                                        force: true,
                                      )
                                      .catchError((_) {});
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
            Row(
              children: [
                Text(
                  'Reinicio en ${_formatCountdown(remaining)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
