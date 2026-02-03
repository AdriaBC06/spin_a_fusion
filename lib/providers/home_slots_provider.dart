import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/fusion_entry.dart';
import '../models/home_slots_state.dart';
import 'game_provider.dart';
import '../features/fusion/fusion_economy.dart';
import '../core/constants/home_slot_prices.dart';

class HomeSlotsProvider extends ChangeNotifier {
  // ----------------------------
  // CONFIG
  // ----------------------------
  static const int totalSlots = 15;
  static const int initialUnlocked = 3;
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
      _state.unlockedCount = _state.unlockedCount <= 0
          ? initialUnlocked
          : _state.unlockedCount.clamp(
              initialUnlocked,
              totalSlots,
            );
    } else {
      _state = HomeSlotsState.empty(
        totalSlots,
        unlockedCount: initialUnlocked,
      );
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

  int get unlockedCount => _state.unlockedCount;

  int? get nextUnlockCost {
    final index = unlockedCount - initialUnlocked;
    if (index < 0 || index >= homeSlotPrices.length) {
      return null;
    }
    return homeSlotPrices[index];
  }

  List<FusionEntry?> get displaySlots {
    final displayCount =
        (unlockedCount + 1).clamp(0, totalSlots);
    return List.unmodifiable(_state.slots.take(displayCount));
  }

  bool get hasEmptyUnlockedSlot {
    for (int i = 0; i < unlockedCount; i++) {
      if (_state.slots[i] == null) return true;
    }
    return false;
  }

  bool contains(FusionEntry fusion) =>
      _state.slots.any((f) =>
          f?.p1.fusionId == fusion.p1.fusionId &&
          f?.p2.fusionId == fusion.p2.fusionId);

  bool addFusion(FusionEntry fusion) {
    for (int i = 0; i < unlockedCount; i++) {
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
    if (index < 0 || index >= unlockedCount) return;

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

    for (int i = 0; i < unlockedCount; i++) {
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

  bool unlockNextSlot() {
    if (_game == null) return false;
    if (unlockedCount >= totalSlots) return false;
    final cost = nextUnlockCost;
    if (cost == null) return false;
    if (!_game!.spendDiamonds(cost)) return false;

    _state.unlockedCount += 1;
    _save();
    notifyListeners();
    return true;
  }

  void setUnlockedCount(int count) {
    _state.unlockedCount = count.clamp(
      initialUnlocked,
      totalSlots,
    );
    _save();
    notifyListeners();
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
