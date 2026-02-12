import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../hive/init/hive_init.dart';
import '../../firebase_options.dart';
import '../../providers/providers.dart';
import '../../providers/fusion_pedia_provider.dart';
import '../../providers/settings_provider.dart';

final bool kFirebaseSupported =
    kIsWeb || Platform.isAndroid || Platform.isIOS;

class AppDependencies {
  final GameProvider game;
  final FusionPediaProvider fusionPedia;
  final FusionCollectionProvider fusionCollection;
  final HomeSlotsProvider homeSlots;
  final SettingsProvider settings;
  final DailyMissionsProvider dailyMissions;

  AppDependencies({
    required this.game,
    required this.fusionPedia,
    required this.fusionCollection,
    required this.homeSlots,
    required this.settings,
    required this.dailyMissions,
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

    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: true,
      );
      return true;
    };
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

  final dailyMissionsProvider = DailyMissionsProvider();
  await dailyMissionsProvider.init(gameProvider);

  return AppDependencies(
    game: gameProvider,
    fusionPedia: fusionPediaProvider,
    fusionCollection: fusionCollectionProvider,
    homeSlots: homeSlotsProvider,
    settings: settingsProvider,
    dailyMissions: dailyMissionsProvider,
  );
}
