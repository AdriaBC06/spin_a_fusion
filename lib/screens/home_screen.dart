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
  int currentIndex = 1;

  final List<Widget> screens = const [
    ShopScreen(),
    HomeTab(),
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

  static const int _totalSlots = 12;
  static const int _unlockedSlots = 3;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Space for top counters
          const SizedBox(height: 72),

          // Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: _totalSlots,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final bool unlocked = index < _unlockedSlots;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.catching_pokemon,
                          size: 40,
                        ),
                      ),
                      if (!unlocked)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              thickness: 2,
              color: Colors.grey.shade400,
            ),
          ),

          const SizedBox(height: 16),

          // Inventory title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pokéballs',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Inventory list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: const [
                InventoryBallCard(
                  name: 'Poké Ball',
                  color: Colors.red,
                  amount: 0,
                ),
                InventoryBallCard(
                  name: 'Super Ball',
                  color: Colors.blue,
                  amount: 0,
                ),
                InventoryBallCard(
                  name: 'Ultra Ball',
                  color: Colors.amber,
                  amount: 0,
                ),
                InventoryBallCard(
                  name: 'Master Ball',
                  color: Colors.purple,
                  amount: 0,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
