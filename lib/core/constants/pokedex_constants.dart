import 'dart:ui';

const int expectedPokemonCount = 420;

enum BallType {
  poke,
  superBall,
  ultra,
  master,
  silver,
  gold,
  ruby,
  sapphire,
  emerald,
  // Hidden placeholder to preserve legacy index ordering.
  test,
}

enum FusionModifier {
  silver,
  gold,
  ruby,
  sapphire,
  emerald,
}

const Map<BallType, int> ballPrices = {
  BallType.poke: 100,
  BallType.superBall: 250,
  BallType.ultra: 1000,
  BallType.master: 10000,
  BallType.silver: 50000,
  BallType.gold: 200000,
  BallType.ruby: 1000000,
  BallType.sapphire: 1000000,
  BallType.emerald: 100000000,
};

const Map<FusionModifier, String> fusionModifierLabels = {
  FusionModifier.silver: 'Silver',
  FusionModifier.gold: 'Gold',
  FusionModifier.ruby: 'Ruby',
  FusionModifier.sapphire: 'Sapphire',
  FusionModifier.emerald: 'Emerald',
};

const Map<FusionModifier, Color> fusionModifierColors = {
  FusionModifier.silver: Color(0xFFB8BCC6),
  FusionModifier.gold: Color(0xFFFFD76B),
  FusionModifier.ruby: Color(0xFFE84D4D),
  FusionModifier.sapphire: Color(0xFF4C7BFF),
  FusionModifier.emerald: Color(0xFF2ECC71),
};
