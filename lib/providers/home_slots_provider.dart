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
  static const String _stateKey = 'state';

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

    final saved = _box.get(_stateKey);
    if (saved != null) {
      _state = saved;
    } else {
      _state = HomeSlotsState.empty(totalSlots);
      await _box.put(_stateKey, _state);
    }

    final changed = _syncWithInventory(inventory);
    if (changed) {
      await _box.put(_stateKey, _state);
    }

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickIncome(),
    );

    notifyListeners();
  }

  void bindGameProvider(GameProvider game) {
    _game = game;
  }

  // ----------------------------
  // RESET (LOGOUT / CLOUD RESTORE)
  // ----------------------------
  Future<void> resetToDefault() async {
    _state = HomeSlotsState.empty(totalSlots);
    await _box.put(_stateKey, _state);
    notifyListeners();
  }

  void _save() {
    _box.put(_stateKey, _state);
  }

  // ----------------------------
  // INVENTORY SYNC
  // ----------------------------
  bool _syncWithInventory(List<FusionEntry> inventory) {
    bool changed = false;

    for (int i = 0; i < totalSlots; i++) {
      final fusion = _state.slots[i];
      if (fusion == null) continue;

      final exists = inventory.any((f) =>
          f.p1.fusionId == fusion.p1.fusionId &&
          f.p2.fusionId == fusion.p2.fusionId);

      if (!exists) {
        _state.slots[i] = null;
        changed = true;
      }
    }

    return changed;
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
      _state.slots.any((f) =>
          f?.p1.fusionId == fusion.p1.fusionId &&
          f?.p2.fusionId == fusion.p2.fusionId);

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

  void setSlot(int index, FusionEntry? fusion) {
    if (index < 0 || index >= unlockedSlots) return;

    _state.slots[index] = fusion;
    _save();
    notifyListeners();
  }

  void purgeFusion(FusionEntry fusion) {
    bool changed = false;

    for (int i = 0; i < totalSlots; i++) {
      final f = _state.slots[i];
      if (f == null) continue;

      if (f.p1.fusionId == fusion.p1.fusionId &&
          f.p2.fusionId == fusion.p2.fusionId) {
        _state.slots[i] = null;
        changed = true;
      }
    }

    if (changed) {
      _save();
      notifyListeners();
    }
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
class HomeIncomeEvent {
  final int slotIndex;
  final int amount;

  HomeIncomeEvent({
    required this.slotIndex,
    required this.amount,
  });
}
