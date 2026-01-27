import 'package:flutter/material.dart';

import '../widgets/widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 72),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: HomeSlotsGrid(),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(thickness: 2),
          ),
          SizedBox(height: 16),
          InventorySection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
