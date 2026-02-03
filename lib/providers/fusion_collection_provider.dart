import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:spin_a_fusion/providers/home_slots_provider.dart';

import '../models/fusion_entry.dart';
import 'fusion_pedia_provider.dart';

class FusionCollectionProvider extends ChangeNotifier {
  static const String _boxName = 'fusions';

  late Box<FusionEntry> _box;
  late FusionPediaProvider _pedia;

  // ----------------------------
  // INIT
  // ----------------------------
  Future<void> init(FusionPediaProvider pedia) async {
    _pedia = pedia;
    _box = await Hive.openBox<FusionEntry>(_boxName);
    notifyListeners();
  }

  // ----------------------------
  // RESET (LOGOUT / CLOUD RESTORE)
  // ----------------------------
  Future<void> resetToDefault() async {
    await _box.clear();
    notifyListeners();
  }

  // ----------------------------
  // GETTERS
  // ----------------------------
  List<FusionEntry> get fusions => _box.values.toList().reversed.toList();

  /// 🔓 Raw list (no reverse) for syncing
  List<FusionEntry> get allFusions => _box.values.toList();

  // ----------------------------
  // MUTATIONS
  // ----------------------------
  void addFusion(FusionEntry fusion) {
    _box.add(fusion);
    _pedia.registerFusion(fusion);
    notifyListeners();
  }

  void removeFusion(FusionEntry fusion, {HomeSlotsProvider? homeSlots}) {
    final index = _box.values.toList().indexOf(fusion);
    if (index == -1) return;

    _box.deleteAt(index);

    // 🔥 NEW: purge from home slots if present
    homeSlots?.purgeFusion(fusion);

    notifyListeners();
  }

  bool contains(FusionEntry fusion) => _box.values.contains(fusion);

  void toggleFavorite(FusionEntry fusion) {
    final index = _box.values.toList().indexOf(fusion);
    if (index == -1) return;

    final updated = fusion.copyWith(favorite: !fusion.favorite);
    _box.putAt(index, updated);
    notifyListeners();
  }
}
