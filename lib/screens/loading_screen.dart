import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../providers/pokedex_provider.dart';
import '../providers/game_provider.dart';
import '../providers/fusion_collection_provider.dart';
import '../providers/fusion_pedia_provider.dart';
import '../providers/home_slots_provider.dart';

import '../features/cloud/services/firebase_restore_service.dart';
import '../features/cloud/services/remote_config_service.dart';
import '../features/cloud/widgets/confirm_restore_from_cloud_dialog.dart';
import '../features/shared/force_update_screen.dart';
import '../core/bootstrap/app_init.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _restoreChecked = false;
  bool _updateChecked = false;
  bool _needsUpdate = false;
  String _updateMessage = '';
  String _updateUrl = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PokedexProvider>().initialize();
    });

    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    if (!kFirebaseSupported) {
      if (mounted) setState(() => _updateChecked = true);
      return;
    }

    try {
      final info = await PackageInfo.fromPlatform();
      final build =
          int.tryParse(info.buildNumber) ?? 0;

      final remote = RemoteConfigService();
      await remote.init();

      if (!mounted) return;

      setState(() {
        _updateChecked = true;
        _needsUpdate = build < remote.minBuild;
        _updateMessage = remote.message;
        _updateUrl = remote.updateUrl;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _updateChecked = true);
      }
    }
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

    if (_updateChecked && _needsUpdate) {
      return ForceUpdateScreen(
        message: _updateMessage,
        updateUrl: _updateUrl,
      );
    }

    if (pokedex.isLoaded) {
      if (_updateChecked) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _maybeRestoreFromCloud().then((_) {
            Navigator.of(context)
                .pushReplacementNamed('/home');
          });
        });
      }

      return const SizedBox.shrink();
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B1020),
                  Color(0xFF0B2E5E),
                  Color(0xFF2B0F46),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Image.asset(
                      'assets/images/loading.png',
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      filterQuality: FilterQuality.high,
                    ),
                  );
                },
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pokedex.progress,
                      minHeight: 10,
                      backgroundColor: Colors.white12,
                      color: Color(0xFF00D1FF),
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
