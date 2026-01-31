import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/pokemon.dart';
import '../../../models/fusion_entry.dart';
import '../../../models/game_state.dart';
import '../../../models/home_slots_state.dart';
import '../../../providers/settings_provider.dart';
import '../adapters/ball_type_adapter.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  // ---------------------------
  // ADAPTERS
  // ---------------------------
  Hive.registerAdapter(PokemonAdapter());
  Hive.registerAdapter(FusionEntryAdapter());
  Hive.registerAdapter(GameStateAdapter());
  Hive.registerAdapter(HomeSlotsStateAdapter());
  Hive.registerAdapter(BallTypeAdapter());
  Hive.registerAdapter(SettingsStateAdapter());

  // ---------------------------
  // BOXES
  // ---------------------------
  await Hive.openBox<Pokemon>('pokedex');
  await Hive.openBox<HomeSlotsState>('home_slots');
}
