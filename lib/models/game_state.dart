import 'package:hive/hive.dart';
import '../constants/pokedex_constants.dart';

part 'game_state.g.dart';

@HiveType(typeId: 3)
class GameState {
  @HiveField(0)
  int money;

  @HiveField(1)
  int diamonds;

  @HiveField(2)
  Map<BallType, int> balls;

  GameState({
    required this.money,
    required this.diamonds,
    required this.balls,
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
      );
}
