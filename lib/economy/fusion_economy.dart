import 'dart:math';
import '../models/fusion_entry.dart';

class FusionEconomy {
  static const int baseValue = 1000;

  static double fusionCatchRate(FusionEntry fusion) {
    return (fusion.p1.catchRate + fusion.p2.catchRate) / 2;
  }

  static int sellPrice(FusionEntry fusion) {
    final rate = fusionCatchRate(fusion);
    return max(1, ((baseValue / rate) * 10).floor());
  }

  static int incomePerSecond(FusionEntry fusion) {
    final rate = fusionCatchRate(fusion);
    return max(1, ((baseValue / rate)).floor());
  }
}
