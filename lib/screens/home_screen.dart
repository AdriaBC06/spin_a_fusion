import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import 'screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  int money = 1250;
int diamonds = 42;


  final List<Widget> screens = const [
    HomeContent(),
    ShopScreen(),
    FusionScreen(),
    PediaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: Stack(
        children: [
          screens[currentIndex],
          MoneyCounter(amount: money),
          DiamondCounter(amount: diamonds),
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

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Pantalla Home', style: TextStyle(fontSize: 22)),
    );
  }
}
