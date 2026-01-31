import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/bootstrap/app_init.dart';
import 'providers/pokedex_provider.dart';
import 'screens/screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final deps = await initApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: deps.game),
        ChangeNotifierProvider.value(value: deps.fusionPedia),
        ChangeNotifierProvider.value(value: deps.fusionCollection),
        ChangeNotifierProvider.value(value: deps.homeSlots),
        ChangeNotifierProvider.value(value: deps.settings),
        ChangeNotifierProvider(create: (_) => PokedexProvider()),
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
