import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/fusion_entry.dart';

class FusionPediaProvider extends ChangeNotifier {
  static const String _boxName = 'fusion_pedia';

  late Box<FusionEntry> _box;

  Future<void> init() async {
    _box = await Hive.openBox<FusionEntry>(_boxName);
    notifyListeners();
  }

  String _key(FusionEntry f) =>
      '${f.p1.fusionId}-${f.p2.fusionId}';

  /// Register fusion only once (directional, no duplicates)
  void registerFusion(FusionEntry fusion) {
    final key = _key(fusion);
    if (_box.containsKey(key)) return;

    _box.put(key, fusion);
    notifyListeners();
  }

  /// 🔥 NEW: ensure inventory fusions exist in pedia
  void syncFromInventory(List<FusionEntry> inventory) {
    bool changed = false;

    for (final fusion in inventory) {
      final key = _key(fusion);
      if (_box.containsKey(key)) continue;

      _box.put(key, fusion);
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
}
