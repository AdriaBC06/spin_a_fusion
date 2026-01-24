import 'package:flutter/material.dart';
import '../../models/pokemon.dart';

class FusionCard extends StatelessWidget {
  final Pokemon p1;
  final Pokemon p2;
  final String autoGenUrl;

  const FusionCard({
    super.key,
    required this.p1,
    required this.p2,
    required this.autoGenUrl,
  });

  int get _stats => p1.totalStats + p2.totalStats;

  @override
  Widget build(BuildContext context) {
    final customUrl =
        'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
        'pokemon/custom-fusion-sprites-main/CustomBattlers/'
        '${p1.fusionId}.${p2.fusionId}.png';

    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              customUrl,
              width: 160,
              errorBuilder: (_, __, ___) =>
                  Image.network(autoGenUrl, width: 160),
            ),
            const SizedBox(height: 12),
            Text(
              '${p1.name.toUpperCase()} - ${p2.name.toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text('Stats totales: $_stats'),
          ],
        ),
      ),
    );
  }
}
