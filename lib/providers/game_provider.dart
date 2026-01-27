import 'package:flutter/material.dart';

enum BallType {
  poke,
  superBall,
  ultra,
  master,
}

class GameProvider extends ChangeNotifier {
  int money = 100000;
  int diamonds = 50;

  final Map<BallType, int> _balls = {
    BallType.poke: 0,
    BallType.superBall: 0,
    BallType.ultra: 0,
    BallType.master: 0,
  };

  // ---------- MONEY ----------
  bool canSpendMoney(int amount) => money >= amount;

  bool spendMoney(int amount) {
    if (!canSpendMoney(amount)) return false;
    money -= amount;
    notifyListeners();
    return true;
  }

  void addMoney(int amount) {
    money += amount;
    notifyListeners();
  }

  // ---------- BALLS ----------
  int ballCount(BallType type) => _balls[type] ?? 0;

  void addBall(BallType type, {int amount = 1}) {
    _balls[type] = ballCount(type) + amount;
    notifyListeners();
  }

  bool buyBall({
    required BallType type,
    required int price,
  }) {
    if (!spendMoney(price)) return false;
    addBall(type);
    return true;
  }
}
