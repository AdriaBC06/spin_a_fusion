import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

import '../hive/init/hive_init.dart';
import '../../firebase_options.dart';
import '../../providers/providers.dart';
import '../../providers/fusion_pedia_provider.dart';
import '../../providers/home_slots_provider.dart';
import '../../providers/settings_provider.dart';

final bool kFirebaseSupported =
    kIsWeb || Platform.isAndroid || Platform.isIOS;

class AppDependencies {
  final GameProvider game;
  final FusionPediaProvider fusionPedia;
  final FusionCollectionProvider fusionCollection;
  final HomeSlotsProvider homeSlots;
  final SettingsProvider settings;

  AppDependencies({
    required this.game,
    required this.fusionPedia,
    required this.fusionCollection,
    required this.homeSlots,
    required this.settings,
  });
}

Future<AppDependencies> initApp() async {
  // ---------------------------
  // HIVE
  // ---------------------------
  await initHive();

  // ---------------------------
  // FIREBASE
  // ---------------------------
  if (kFirebaseSupported) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // ---------------------------
  // PROVIDERS
  // ---------------------------
  final gameProvider = GameProvider();
  await gameProvider.init();

  final fusionPediaProvider = FusionPediaProvider();
  await fusionPediaProvider.init();

  final fusionCollectionProvider = FusionCollectionProvider();
  await fusionCollectionProvider.init(fusionPediaProvider);

  fusionPediaProvider.syncFromInventory(
    fusionCollectionProvider.allFusions,
  );

  final homeSlotsProvider = HomeSlotsProvider();
  await homeSlotsProvider.init(
    inventory: fusionCollectionProvider.allFusions,
  );
  homeSlotsProvider.bindGameProvider(gameProvider);

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  return AppDependencies(
    game: gameProvider,
    fusionPedia: fusionPediaProvider,
    fusionCollection: fusionCollectionProvider,
    homeSlots: homeSlotsProvider,
    settings: settingsProvider,
  );
}
