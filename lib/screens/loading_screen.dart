import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/pokedex_provider.dart';
import '../providers/game_provider.dart';
import '../providers/fusion_collection_provider.dart';
import '../providers/fusion_pedia_provider.dart';
import '../providers/home_slots_provider.dart';

import '../features/cloud/services/firebase_restore_service.dart';
import '../features/cloud/widgets/confirm_restore_from_cloud_dialog.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _restoreChecked = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PokedexProvider>().initialize();
    });
  }

  Future<void> _maybeRestoreFromCloud() async {
    if (_restoreChecked) return;
    _restoreChecked = true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final restoreService = FirebaseRestoreService();
    final cloud = await restoreService.fetchCloud();
    if (cloud == null) return;

    final cloudPlaytime = cloud['playTimeSeconds'] ?? 0;
    final localPlaytime =
        context.read<GameProvider>().playTimeSeconds;

    if (cloudPlaytime <= localPlaytime) return;

    final confirmed =
        await showConfirmRestoreFromCloudDialog(context);

    if (confirmed != true) return;

    await context.read<GameProvider>().resetToDefault();
    await context.read<FusionCollectionProvider>().resetToDefault();
    await context.read<FusionPediaProvider>().resetToDefault();
    await context.read<HomeSlotsProvider>().resetToDefault();

    await restoreService.restoreFromCloud(
      cloud: cloud,
      game: context.read<GameProvider>(),
      collection: context.read<FusionCollectionProvider>(),
      pedia: context.read<FusionPediaProvider>(),
      homeSlots: context.read<HomeSlotsProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pokedex = context.watch<PokedexProvider>();

    if (pokedex.isLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeRestoreFromCloud().then((_) {
          Navigator.of(context)
              .pushReplacementNamed('/home');
        });
      });

      return const SizedBox.shrink();
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.deepPurple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Loading Pokémon ${pokedex.loadedCount}/${pokedex.totalCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pokedex.progress,
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
