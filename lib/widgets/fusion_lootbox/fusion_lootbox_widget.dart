import 'package:flutter/material.dart';
import '../../models/pokemon.dart';
import 'fusion_lootbox_state.dart';
import '../../constants/pokedex_constants.dart';

class FusionLootbox extends StatefulWidget {
  final List<Pokemon> allPokemon;
  final Pokemon result1;
  final Pokemon result2;
  final BallType ball;
  final VoidCallback onFinished;

  const FusionLootbox({
    super.key,
    required this.allPokemon,
    required this.result1,
    required this.result2,
    required this.ball,
    required this.onFinished,
  });

  @override
  FusionLootboxState createState() => FusionLootboxState();
}
