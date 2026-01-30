// main.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/pokemon.dart';
import 'models/fusion_entry.dart';
import 'models/game_state.dart';
import 'models/home_slots_state.dart';

import 'core/hive/adapters/ball_type_adapter.dart';

import 'providers/providers.dart';
import 'providers/fusion_pedia_provider.dart';
import 'providers/settings_provider.dart'; // ✅ ADDED
import 'screens/screens.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final bool kFirebaseSupported =
    kIsWeb || Platform.isAndroid || Platform.isIOS;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------------------
  // HIVE INIT
  // ---------------------------
  await Hive.initFlutter();

  Hive.registerAdapter(PokemonAdapter());
  Hive.registerAdapter(FusionEntryAdapter());
  Hive.registerAdapter(GameStateAdapter());
  Hive.registerAdapter(HomeSlotsStateAdapter());
  Hive.registerAdapter(BallTypeAdapter());
  Hive.registerAdapter(SettingsStateAdapter()); // ✅ ADDED

  await Hive.openBox<Pokemon>('pokedex');
  await Hive.openBox<HomeSlotsState>('home_slots');

  // ---------------------------
  // FIREBASE INIT
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

  final fusionCollectionProvider =
      FusionCollectionProvider();
  await fusionCollectionProvider
      .init(fusionPediaProvider);

  fusionPediaProvider.syncFromInventory(
    fusionCollectionProvider.allFusions,
  );

  final homeSlotsProvider = HomeSlotsProvider();
  await homeSlotsProvider.init(
    inventory: fusionCollectionProvider.allFusions,
  );
  homeSlotsProvider.bindGameProvider(gameProvider);

  // ---------------------------
  // SETTINGS PROVIDER (NEW)
  // ---------------------------
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: gameProvider),
        ChangeNotifierProvider.value(
            value: fusionPediaProvider),
        ChangeNotifierProvider.value(
            value: fusionCollectionProvider),
        ChangeNotifierProvider(
            create: (_) => PokedexProvider()),
        ChangeNotifierProvider.value(
            value: homeSlotsProvider),

        // 🔔 SETTINGS (VIBRATION TOGGLE)
        ChangeNotifierProvider.value(
            value: settingsProvider),
      ],
      child: const MyApp(),
    ),
  );
}

// ------------------------------------------------------
// ROOT APP
// ------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => const LoadingScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
