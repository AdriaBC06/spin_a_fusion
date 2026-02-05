import 'dart:math';
import '../../models/fusion_entry.dart';
import '../../core/constants/pokedex_constants.dart';

class FusionEconomy {
  static const int baseValue = 500;

  static double _clamp01(double value) {
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }

  static double _rarityFromCatchRate(int catchRate) {
    // PokeAPI capture_rate is 3..255. Higher rate => more common.
    final rarity = (255 - catchRate) / 252;
    return _clamp01(rarity);
  }

  static double _ballMultiplier(BallType ball) {
    switch (ball) {
      case BallType.poke:
      case BallType.superBall:
      case BallType.ultra:
      case BallType.master:
        return 1.0;
      case BallType.silver:
      case BallType.gold:
      case BallType.ruby:
      case BallType.sapphire:
      case BallType.emerald:
      case BallType.test:
        return 1.0;
    }
    return 1.0;
  }

  static double _modifierMultiplier(FusionModifier? modifier) {
    switch (modifier) {
      case FusionModifier.silver:
        return 1.5;
      case FusionModifier.gold:
        return 2.5;
      case FusionModifier.ruby:
      case FusionModifier.sapphire:
        return 3.5;
      case FusionModifier.emerald:
        return 6.0;
      case null:
        return 1.0;
    }
  }

  static double fusionCatchRate(FusionEntry fusion) {
    return (fusion.p1.catchRate + fusion.p2.catchRate) / 2;
  }

  static int sellPrice(FusionEntry fusion) {
    return max(1, incomePerSecond(fusion) * 10);
  }

  static int incomePerSecond(FusionEntry fusion) {
    final rate1 = fusion.p1.catchRate;
    final rate2 = fusion.p2.catchRate;

    // Bias toward the rarer Pokemon so "good fusions" feel better.
    final minRate = min(rate1, rate2).toDouble();
    final avgRate = (rate1 + rate2) / 2.0;
    final effectiveRate = (minRate * 0.7) + (avgRate * 0.3);

    // Convert to rarity and apply a gentle curve.
    final rarity = _rarityFromCatchRate(effectiveRate.round());
    final rarityCurve = pow(rarity, 1.7).toDouble();

    // Base income before ball and double-rare bonus.
    final baseIncome = 1 + (rarityCurve * 14).round(); // 1..15

    // Bonus for double-rare fusions (keeps extra punch).
    final r1 = _rarityFromCatchRate(rate1);
    final r2 = _rarityFromCatchRate(rate2);
    final doubleRareBonus = 1 + (r1 * r2 * 0.4); // up to +40%

    final ballMultiplier = _ballMultiplier(fusion.ball);
    final modifierMultiplier = _modifierMultiplier(fusion.modifier);
    final income = (baseIncome *
            ballMultiplier *
            doubleRareBonus *
            modifierMultiplier)
        .round();

    return max(1, income);
  }
}
