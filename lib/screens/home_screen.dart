import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/widgets.dart';
import 'screens.dart';
import '../providers/providers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeTab(),      // 👈 contenido Home
    ShopScreen(),
    FusionScreen(),
    DebugScreen(),
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PokedexProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          screens[currentIndex],
          const MoneyCounter(),
          const DiamondCounter(),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

/// ------------------------------------------------------
/// CONTENIDO DE LA PESTAÑA HOME
/// ------------------------------------------------------
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Pantalla Home',
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}
