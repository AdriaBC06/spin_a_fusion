import 'dart:async';
import 'package:flutter/material.dart';

import '../models/fusion_entry.dart';
import 'game_provider.dart';
import '../economy/fusion_economy.dart';

class HomeSlotsProvider extends ChangeNotifier {
  static const int totalSlots = 12;
  static const int unlockedSlots = 3;

  final List<FusionEntry?> _slots = List<FusionEntry?>.filled(totalSlots, null);

  Timer? _timer;
  GameProvider? _game;

  HomeSlotsProvider() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tickIncome());
  }

  // ----------------------------
  // PUBLIC API
  // ----------------------------
  List<FusionEntry?> get slots => List.unmodifiable(_slots);

  bool get hasEmptyUnlockedSlot {
    for (int i = 0; i < unlockedSlots; i++) {
      if (_slots[i] == null) return true;
    }
    return false;
  }

  bool contains(FusionEntry fusion) => _slots.contains(fusion);

  bool addFusion(FusionEntry fusion) {
    for (int i = 0; i < unlockedSlots; i++) {
      if (_slots[i] == null) {
        _slots[i] = fusion;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void removeFusion(FusionEntry fusion) {
    for (int i = 0; i < totalSlots; i++) {
      if (_slots[i] == fusion) {
        _slots[i] = null;
        notifyListeners();
        return;
      }
    }
  }

  void bindGameProvider(GameProvider game) {
    _game = game;
  }

  // ----------------------------
  // PASSIVE INCOME (CORE LOGIC)
  // ----------------------------
  void _tickIncome() {
    if (_game == null) return;

    int income = 0;

    for (int i = 0; i < unlockedSlots; i++) {
      final fusion = _slots[i];
      if (fusion == null) continue;

      income += FusionEconomy.incomePerSecond(fusion);
    }

    if (income > 0) {
      _game!.addMoney(income);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
