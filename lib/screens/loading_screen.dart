import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pokedex_provider.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PokedexProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pokedex = context.watch<PokedexProvider>();

    if (pokedex.isLoaded) {
      return const _GoToHome();
    }

    return Scaffold(
      body: Stack(
        children: [
          // 🔲 BACKGROUND PLACEHOLDER
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.deepPurple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🔄 LOADING BAR
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

class _GoToHome extends StatelessWidget {
  const _GoToHome();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/home');
    });

    return const SizedBox.shrink();
  }
}
