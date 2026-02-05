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
    _ensureUids();
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
    final normalized = _withUid(fusion);
    _box.add(normalized);
    _pedia.registerFusion(normalized);
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

    final updated = fusion.copyWith(
      favorite: !fusion.favorite,
      uid: fusion.uid,
    );
    _box.putAt(index, updated);
    notifyListeners();
  }

  FusionEntry _withUid(FusionEntry fusion) {
    if (fusion.uid != null) return fusion;
    return fusion.copyWith(uid: _generateUid());
  }

  int _generateUid() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final salt = _box.length + 1;
    return now ^ salt;
  }

  void _ensureUids() {
    final values = _box.values.toList();
    for (int i = 0; i < values.length; i++) {
      final fusion = values[i];
      if (fusion.uid != null) continue;
      _box.putAt(i, fusion.copyWith(uid: _generateUid()));
    }
  }
}
