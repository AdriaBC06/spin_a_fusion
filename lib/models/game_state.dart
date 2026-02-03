import 'package:hive/hive.dart';
import '../core/constants/pokedex_constants.dart';

part 'game_state.g.dart';

@HiveType(typeId: 5)
class GameState {
  @HiveField(0)
  int money;

  @HiveField(1)
  int diamonds;

  @HiveField(2)
  Map<BallType, int> balls;

  @HiveField(3)
  int playTimeSeconds;

  @HiveField(4)
  int totalSpins;

  GameState({
    required this.money,
    required this.diamonds,
    required this.balls,
    required this.playTimeSeconds,
    required this.totalSpins,
  });

  factory GameState.initial() => GameState(
        money: 300,
        diamonds: 0,
        balls: {
          BallType.poke: 0,
          BallType.superBall: 0,
          BallType.ultra: 0,
          BallType.master: 0,
        },
        playTimeSeconds: 0,
        totalSpins: 0,
      );
}
