import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/fusion_entry.dart';

class FusionPediaProvider extends ChangeNotifier {
  static const String _boxName = 'fusion_pedia';

  late Box<FusionEntry> _box;

  // ----------------------------
  // INIT
  // ----------------------------
  Future<void> init() async {
    _box = await Hive.openBox<FusionEntry>(_boxName);
    _migrateLegacyKeys();
    notifyListeners();
  }

  // ----------------------------
  // RESET (LOGOUT / CLOUD RESTORE)
  // ----------------------------
  Future<void> resetToDefault() async {
    await _box.clear();
    notifyListeners();
  }

  String _key(FusionEntry f) =>
      '${f.p1.fusionId}-${f.p2.fusionId}';

  FusionEntry _withPendingClaim(FusionEntry fusion) {
    if (fusion.claimPending) return fusion;
    return fusion.copyWith(claimPending: true);
  }

  /// Register fusion only once (directional, no duplicates)
  void registerFusion(FusionEntry fusion) {
    final key = _key(fusion);
    if (_box.containsKey(key)) return;

    _box.put(key, _withPendingClaim(fusion));
    notifyListeners();
  }

  /// Register fusion from cloud with explicit claim state.
  void registerFusionFromCloud(FusionEntry fusion) {
    final key = _key(fusion);
    _box.put(key, fusion);
    notifyListeners();
  }

  /// 🔥 Ensure inventory fusions exist in pedia
  void syncFromInventory(List<FusionEntry> inventory) {
    bool changed = false;

    for (final fusion in inventory) {
      final key = _key(fusion);
      if (_box.containsKey(key)) continue;

      _box.put(key, _withPendingClaim(fusion));
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  List<FusionEntry> get sortedFusions {
    final list = _box.values.toList();

    list.sort((a, b) {
      final c = a.p1.fusionId.compareTo(b.p1.fusionId);
      if (c != 0) return c;
      return a.p2.fusionId.compareTo(b.p2.fusionId);
    });

    return list;
  }

  bool get isEmpty => _box.isEmpty;

  int get pendingCount =>
      _box.values.where((f) => f.claimPending).length;

  bool get hasPending => pendingCount > 0;

  bool claimFusion(FusionEntry fusion) {
    final key = _key(fusion);
    final stored = _box.get(key);
    if (stored == null || !stored.claimPending) return false;

    _box.put(key, stored.copyWith(claimPending: false));
    notifyListeners();
    return true;
  }

  int claimAllPending() {
    int claimed = 0;

    for (final entry in _box.toMap().entries) {
      final fusion = entry.value;
      if (!fusion.claimPending) continue;
      _box.put(entry.key, fusion.copyWith(claimPending: false));
      claimed += 1;
    }

    if (claimed > 0) {
      notifyListeners();
    }

    return claimed;
  }

  void _migrateLegacyKeys() {
    final updates = <String, FusionEntry>{};
    final deletes = <String>[];

    for (final entry in _box.toMap().entries) {
      final key = entry.key;
      final fusion = entry.value;
      final legacyKey = _key(fusion);

      if (key == legacyKey) continue;

      if (_box.containsKey(legacyKey)) {
        deletes.add(key);
      } else {
        updates[legacyKey] = fusion;
        deletes.add(key);
      }
    }

    for (final key in deletes) {
      _box.delete(key);
    }
    for (final entry in updates.entries) {
      _box.put(entry.key, entry.value);
    }
  }
}
