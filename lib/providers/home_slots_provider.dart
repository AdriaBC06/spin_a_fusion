import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/fusion_entry.dart';
import '../models/home_slots_state.dart';
import 'game_provider.dart';
import '../economy/fusion_economy.dart';

class HomeSlotsProvider extends ChangeNotifier {
  // ----------------------------
  // CONFIG
  // ----------------------------
  static const int totalSlots = 12;
  static const int unlockedSlots = 3;
  static const String _boxName = 'home_slots';

  // ----------------------------
  // STATE
  // ----------------------------
  late Box<HomeSlotsState> _box;
  late HomeSlotsState _state;

  Timer? _timer;
  GameProvider? _game;

  final StreamController<HomeIncomeEvent> _incomeController =
      StreamController<HomeIncomeEvent>.broadcast();

  Stream<HomeIncomeEvent> get incomeStream =>
      _incomeController.stream;

  // ----------------------------
  // INIT
  // ----------------------------
  Future<void> init({
    required List<FusionEntry> inventory,
  }) async {
    _box = await Hive.openBox<HomeSlotsState>(_boxName);
    _state = _box.get('state') ??
        HomeSlotsState.empty(totalSlots);

    // 🔥 CRITICAL FIX: purge invalid fusions
    _syncWithInventory(inventory);

    await _box.put('state', _state);

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickIncome(),
    );
  }

  void bindGameProvider(GameProvider game) {
    _game = game;
  }

  void _save() {
    _box.put('state', _state);
  }

  // ----------------------------
  // 🔥 INVENTORY SYNC
  // ----------------------------
  void _syncWithInventory(List<FusionEntry> inventory) {
    bool changed = false;

    for (int i = 0; i < totalSlots; i++) {
      final fusion = _state.slots[i];
      if (fusion == null) continue;

      if (!inventory.contains(fusion)) {
        _state.slots[i] = null;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// Optional explicit purge (runtime safety)
  void purgeFusion(FusionEntry fusion) {
    for (int i = 0; i < totalSlots; i++) {
      if (_state.slots[i] == fusion) {
        _state.slots[i] = null;
      }
    }
    _save();
    notifyListeners();
  }

  // ----------------------------
  // PUBLIC API
  // ----------------------------
  List<FusionEntry?> get slots =>
      List.unmodifiable(_state.slots);

  bool get hasEmptyUnlockedSlot {
    for (int i = 0; i < unlockedSlots; i++) {
      if (_state.slots[i] == null) return true;
    }
    return false;
  }

  bool contains(FusionEntry fusion) =>
      _state.slots.contains(fusion);

  bool addFusion(FusionEntry fusion) {
    for (int i = 0; i < unlockedSlots; i++) {
      if (_state.slots[i] == null) {
        _state.slots[i] = fusion;
        _save();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void removeFusion(FusionEntry fusion) {
    purgeFusion(fusion);
  }

  // ----------------------------
  // PASSIVE INCOME
  // ----------------------------
  void _tickIncome() {
    if (_game == null) return;

    for (int i = 0; i < unlockedSlots; i++) {
      final fusion = _state.slots[i];
      if (fusion == null) continue;

      final income =
          FusionEconomy.incomePerSecond(fusion);

      if (income > 0) {
        _game!.addMoney(income);

        _incomeController.add(
          HomeIncomeEvent(
            slotIndex: i,
            amount: income,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _incomeController.close();
    super.dispose();
  }
}

// ------------------------------------------------------
// INCOME EVENT
// ------------------------------------------------------
class HomeIncomeEvent {
  final int slotIndex;
  final int amount;

  HomeIncomeEvent({
    required this.slotIndex,
    required this.amount,
  });
}
