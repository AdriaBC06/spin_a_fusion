import 'dart:async';
import 'package:flutter/material.dart';

import '../models/fusion_entry.dart';
import 'game_provider.dart';
import '../economy/fusion_economy.dart';

class HomeSlotsProvider extends ChangeNotifier {
  // ----------------------------
  // CONFIG
  // ----------------------------
  static const int totalSlots = 12;
  static const int unlockedSlots = 3;

  // ----------------------------
  // STATE
  // ----------------------------
  final List<FusionEntry?> _slots =
      List<FusionEntry?>.filled(totalSlots, null);

  Timer? _timer;
  GameProvider? _game;

  // ----------------------------
  // INCOME EVENTS (UI FEEDBACK)
  // ----------------------------
  final StreamController<HomeIncomeEvent> _incomeController =
      StreamController<HomeIncomeEvent>.broadcast();

  Stream<HomeIncomeEvent> get incomeStream =>
      _incomeController.stream;

  // ----------------------------
  // LIFECYCLE
  // ----------------------------
  HomeSlotsProvider() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickIncome(),
    );
  }

  void bindGameProvider(GameProvider game) {
    _game = game;
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

  bool contains(FusionEntry fusion) =>
      _slots.contains(fusion);

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

  // ----------------------------
  // PASSIVE INCOME (CORE LOGIC)
  // ----------------------------
  void _tickIncome() {
    if (_game == null) return;

    for (int i = 0; i < unlockedSlots; i++) {
      final fusion = _slots[i];
      if (fusion == null) continue;

      final income =
          FusionEconomy.incomePerSecond(fusion);

      if (income > 0) {
        // Add money
        _game!.addMoney(income);

        // Emit UI event (floating number)
        _incomeController.add(
          HomeIncomeEvent(
            slotIndex: i,
            amount: income,
          ),
        );
      }
    }
  }

  // ----------------------------
  // CLEANUP
  // ----------------------------
  @override
  void dispose() {
    _timer?.cancel();
    _incomeController.close();
    super.dispose();
  }
}

// ------------------------------------------------------
// INCOME EVENT (USED BY HOME SLOT TILE UI)
// ------------------------------------------------------
class HomeIncomeEvent {
  final int slotIndex;
  final int amount;

  HomeIncomeEvent({
    required this.slotIndex,
    required this.amount,
  });
}
