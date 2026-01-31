import 'package:hive/hive.dart';
import '../models/pokemon.dart';
import '../core/constants/pokedex_constants.dart';

part 'fusion_entry.g.dart';

@HiveType(typeId: 1)
class FusionEntry {
  @HiveField(0)
  final Pokemon p1;

  @HiveField(1)
  final Pokemon p2;

  @HiveField(2)
  final BallType ball;

  @HiveField(3)
  final double rarity;

  const FusionEntry({
    required this.p1,
    required this.p2,
    required this.ball,
    required this.rarity,
  });

  int get totalStats => p1.totalStats + p2.totalStats;

  String get fusionName {
    final half1 = (p1.name.length / 2).ceil();
    final half2 = (p2.name.length / 2).ceil();
    return (p1.name.substring(0, half1) +
            p2.name.substring(p2.name.length - half2))
        .toUpperCase();
  }

  String get customFusionUrl =>
      'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
      'pokemon/custom-fusion-sprites-main/CustomBattlers/'
      '${p1.fusionId}.${p2.fusionId}.png';

  String get autoGenFusionUrl =>
      'https://fusioncalc.com/wp-content/themes/twentytwentyone/'
      'pokemon/autogen-fusion-sprites-master/Battlers/'
      '${p1.fusionId}/${p1.fusionId}.${p2.fusionId}.png';
}
