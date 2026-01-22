import 'package:flutter/material.dart';

class GameProvider extends ChangeNotifier {
  int money = 1000;
  int diamonds = 50;

  // ---------- MONEY ----------
  bool canSpendMoney(int amount) {
    return money >= amount;
  }

  bool spendMoney(int amount) {
    if (canSpendMoney(amount)) {
      money -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  void addMoney(int amount) {
    money += amount;
    notifyListeners();
  }

  // ---------- DIAMONDS ----------
  bool canSpendDiamonds(int amount) {
    return diamonds >= amount;
  }

  bool spendDiamonds(int amount) {
    if (canSpendDiamonds(amount)) {
      diamonds -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  void addDiamonds(int amount) {
    diamonds += amount;
    notifyListeners();
  }
}
