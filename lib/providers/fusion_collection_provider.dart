import 'package:flutter/material.dart';
import '../models/fusion_entry.dart';

class FusionCollectionProvider extends ChangeNotifier {
  final List<FusionEntry> _fusions = [];

  List<FusionEntry> get fusions => List.unmodifiable(_fusions);

  void addFusion(FusionEntry fusion) {
    _fusions.insert(0, fusion);
    notifyListeners();
  }

  void removeFusion(FusionEntry fusion) {
    _fusions.remove(fusion);
    notifyListeners();
  }
}
