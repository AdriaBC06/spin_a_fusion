import 'package:flutter/material.dart';

import '../widgets/widgets.dart';
import 'home_tab.dart';
import 'screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;

  static const List<Widget> _screens = [
    ShopScreen(),
    HomeTab(),
    FusionScreen(),
    PediaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: const TopAppBar(),
    body: IndexedStack(
      index: _currentIndex,
      children: _screens,
    ),
    bottomNavigationBar: CustomBottomBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
    ),
  );
  }
}
