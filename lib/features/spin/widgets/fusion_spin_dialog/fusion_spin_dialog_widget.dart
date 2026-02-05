import 'package:flutter/material.dart';
import '../../../../models/pokemon.dart';
import 'fusion_spin_dialog_state.dart';
import '../../../../core/constants/pokedex_constants.dart';

class FusionSpinDialog extends StatefulWidget {
  final List<Pokemon> allPokemon;
  final Pokemon result1;
  final Pokemon result2;
  final BallType ball;
  final FusionModifier? modifier;
  final VoidCallback onFinished;

  const FusionSpinDialog({
    super.key,
    required this.allPokemon,
    required this.result1,
    required this.result2,
    required this.ball,
    required this.modifier,
    required this.onFinished,
  });

  @override
  FusionSpinDialogState createState() => FusionSpinDialogState();
}
