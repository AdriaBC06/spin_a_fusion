import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../constants/pokedex_constants.dart';
import '../models/game_state.dart';

class GameProvider extends ChangeNotifier {
  static const String _boxName = 'game';

  late Box<GameState> _box;
  late GameState _state;

  Timer? _playTimeTimer;

  // 🔒 Cloud overwrite permission (SESSION ONLY)
  bool _cloudOverwriteAllowed = false;

  // ----------------------------
  // INIT
  // ----------------------------
  Future<void> init() async {
    _box = await Hive.openBox<GameState>(_boxName);
    _state = _box.get('state') ?? GameState.initial();
    await _box.put('state', _state);

    _startPlayTimeCounter();
  }

  void _startPlayTimeCounter() {
    _playTimeTimer?.cancel();

    _playTimeTimer =
        Timer.periodic(const Duration(minutes: 1), (_) {
      _state.playTimeSeconds += 60;
      _save();
    });
  }

  @override
  void dispose() {
    _playTimeTimer?.cancel();
    super.dispose();
  }

  // ----------------------------
  // CLOUD OVERWRITE PERMISSION
  // ----------------------------
  bool get canOverwriteCloud => _cloudOverwriteAllowed;

  void allowCloudOverwrite() {
    _cloudOverwriteAllowed = true;
  }

  void resetCloudOverwritePermission() {
    _cloudOverwriteAllowed = false;
  }

  // ----------------------------
  // GETTERS
  // ----------------------------
  int get money => _state.money;
  int get diamonds => _state.diamonds;
  int get playTimeSeconds => _state.playTimeSeconds;

  int ballCount(BallType type) => _state.balls[type] ?? 0;

  // ----------------------------
  // INTERNAL SAVE
  // ----------------------------
  void _save() {
    _box.put('state', _state);
  }

  // ----------------------------
  // MONEY
  // ----------------------------
  bool canSpendMoney(int amount) => _state.money >= amount;

  bool spendMoney(int amount) {
    if (!canSpendMoney(amount)) return false;
    _state.money -= amount;
    _save();
    notifyListeners();
    return true;
  }

  void addMoney(int amount) {
    _state.money += amount;
    _save();
    notifyListeners();
  }

  // ----------------------------
  // BALLS
  // ----------------------------
  void addBall(BallType type, {int amount = 1}) {
    _state.balls[type] = ballCount(type) + amount;
    _save();
    notifyListeners();
  }

  bool buyBall({required BallType type, required int price}) {
    if (!spendMoney(price)) return false;
    addBall(type);
    return true;
  }

  bool canUseBall(BallType type) => ballCount(type) > 0;

  bool useBall(BallType type) {
    if (!canUseBall(type)) return false;
    _state.balls[type] = ballCount(type) - 1;
    _save();
    notifyListeners();
    return true;
  }
}
