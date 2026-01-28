import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/fusion_entry.dart';

class FusionCollectionProvider extends ChangeNotifier {
  static const String _boxName = 'fusions';

  late Box<FusionEntry> _box;

  // ----------------------------
  // INIT
  // ----------------------------
  Future<void> init() async {
    _box = await Hive.openBox<FusionEntry>(_boxName);
    notifyListeners();
  }

  // ----------------------------
  // PUBLIC API
  // ----------------------------
  List<FusionEntry> get fusions =>
      _box.values.toList().reversed.toList();

  void addFusion(FusionEntry fusion) {
    _box.add(fusion);
    notifyListeners();
  }

  void removeFusion(FusionEntry fusion) {
    final index = _box.values.toList().indexOf(fusion);
    if (index == -1) return;

    _box.deleteAt(index);
    notifyListeners();
  }

  bool contains(FusionEntry fusion) {
    return _box.values.contains(fusion);
  }

  int indexOf(FusionEntry fusion) {
    return _box.values.toList().indexOf(fusion);
  }
}
