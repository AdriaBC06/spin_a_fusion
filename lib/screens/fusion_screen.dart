import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class FusionScreen extends StatelessWidget {
  const FusionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Space for MoneyCounter and DiamondCounter
          const SizedBox(height: 72),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Fusiones',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Fusion list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: const [
                FusionInventoryCard(
                  name: 'Fusion #1',
                  imageUrl: '',
                ),
                FusionInventoryCard(
                  name: 'Fusion #2',
                  imageUrl: '',
                ),
                FusionInventoryCard(
                  name: 'Fusion #3',
                  imageUrl: '',
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
