const int expectedPokemonCount = 20;

enum BallType {
  poke,
  superBall,
  ultra,
  master,
}

const Map<BallType, int> ballPrices = {
  BallType.poke: 100,
  BallType.superBall: 250,
  BallType.ultra: 1000,
  BallType.master: 10000,
};
