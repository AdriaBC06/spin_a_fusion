import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/pokemon.dart';
import 'models/fusion_entry.dart';
import 'models/game_state.dart';
import 'models/home_slots_state.dart';

import 'core/hive/adapters/ball_type_adapter.dart';

import 'providers/providers.dart';
import 'screens/screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // ----------------------------
  // HIVE ADAPTERS
  // ----------------------------
  Hive.registerAdapter(PokemonAdapter());
  Hive.registerAdapter(FusionEntryAdapter());
  Hive.registerAdapter(GameStateAdapter());
  Hive.registerAdapter(HomeSlotsStateAdapter());
  Hive.registerAdapter(BallTypeAdapter());

  // ----------------------------
  // PRE-OPEN BOXES
  // ----------------------------
  await Hive.openBox<Pokemon>('pokedex');

  // ----------------------------
  // INIT PROVIDERS (CRÍTICO)
  // ----------------------------
  final gameProvider = GameProvider();
  await gameProvider.init();

  final fusionCollectionProvider =
      FusionCollectionProvider();
  await fusionCollectionProvider.init();

  final homeSlotsProvider = HomeSlotsProvider();
  await homeSlotsProvider.init();
  homeSlotsProvider.bindGameProvider(gameProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: gameProvider),
        ChangeNotifierProvider.value(
          value: fusionCollectionProvider,
        ),
        ChangeNotifierProvider(create: (_) => PokedexProvider()),
        ChangeNotifierProvider.value(value: homeSlotsProvider),
      ],
      child: const MyApp(),
    ),
  );
}

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
