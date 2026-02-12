import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'game_provider.dart';

class DailyMission {
  final String id;
  final String title;
  final int progress;
  final int target;
  final int rewardDiamonds;
  final bool claimed;

  const DailyMission({
    required this.id,
    required this.title,
    required this.progress,
    required this.target,
    required this.rewardDiamonds,
    required this.claimed,
  });

  bool get completed => progress >= target;
  bool get canClaim => completed && !claimed;
}

class DailyMissionsProvider extends ChangeNotifier {
  static const String _boxName = 'daily_missions';
  static const String _stateKey = 'state';

  late Box _box;
  late GameProvider _game;
  Map<String, dynamic> _state = <String, dynamic>{};

  Future<void> init(GameProvider game) async {
    _game = game;
    _box = await Hive.openBox(_boxName);
    _state = _readState();
    _ensureToday();
    _game.addListener(_onGameChanged);
  }

  @override
  void dispose() {
    _game.removeListener(_onGameChanged);
    super.dispose();
  }

  void _onGameChanged() {
    _ensureToday();
    notifyListeners();
  }

  Map<String, dynamic> _readState() {
    final raw = _box.get(_stateKey);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{};
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _save() {
    _box.put(_stateKey, _state);
  }

  int _randInRange(Random rng, int min, int max) {
    return min + rng.nextInt(max - min + 1);
  }

  void _ensureToday() {
    final today = _todayKey();
    if (_state['dateKey'] == today) return;

    final now = DateTime.now();
    final seed = (now.year * 10000) + (now.month * 100) + now.day;
    final rng = Random(seed);
    final spinTargetShort = _randInRange(rng, 16, 25);
    final spinTargetLong = _randInRange(rng, 140, 175);

    _state = <String, dynamic>{
      'dateKey': today,
      'startSpins': _game.totalSpins,
      'startPlaySeconds': _game.playTimeSeconds,
      'spinTargetShort': spinTargetShort,
      'spinTargetLong': spinTargetLong,
      'claimedSpinShort': false,
      'claimedSpinLong': false,
      'claimedPlay15': false,
      'claimedPlay45': false,
    };
    _save();
    notifyListeners();
  }

  int get _spinsToday {
    final start = (_state['startSpins'] as int?) ?? _game.totalSpins;
    return max(0, _game.totalSpins - start);
  }

  int get _playSecondsToday {
    final start = (_state['startPlaySeconds'] as int?) ?? _game.playTimeSeconds;
    return max(0, _game.playTimeSeconds - start);
  }

  int get _spinTargetShort => (_state['spinTargetShort'] as int?) ?? 16;
  int get _spinTargetLong => (_state['spinTargetLong'] as int?) ?? 140;

  bool _claimed(String key) => (_state[key] as bool?) ?? false;

  List<DailyMission> get missions {
    _ensureToday();

    return [
      DailyMission(
        id: 'spin_short',
        title: 'Haz $_spinTargetShort giros',
        progress: _spinsToday,
        target: _spinTargetShort,
        rewardDiamonds: 7,
        claimed: _claimed('claimedSpinShort'),
      ),
      DailyMission(
        id: 'spin_long',
        title: 'Haz $_spinTargetLong giros',
        progress: _spinsToday,
        target: _spinTargetLong,
        rewardDiamonds: _spinTargetLong ~/ 10,
        claimed: _claimed('claimedSpinLong'),
      ),
      DailyMission(
        id: 'play_15',
        title: 'Juega 15 minutos',
        progress: _playSecondsToday ~/ 60,
        target: 15,
        rewardDiamonds: 5,
        claimed: _claimed('claimedPlay15'),
      ),
      DailyMission(
        id: 'play_45',
        title: 'Juega 45 minutos',
        progress: _playSecondsToday ~/ 60,
        target: 45,
        rewardDiamonds: 10,
        claimed: _claimed('claimedPlay45'),
      ),
    ];
  }

  int get claimableCount => missions.where((m) => m.canClaim).length;

  bool claimMission(String id) {
    _ensureToday();
    final mission = missions.firstWhere(
      (m) => m.id == id,
      orElse: () => const DailyMission(
        id: '',
        title: '',
        progress: 0,
        target: 1,
        rewardDiamonds: 0,
        claimed: true,
      ),
    );
    if (mission.id.isEmpty || !mission.canClaim) return false;

    switch (id) {
      case 'spin_short':
        _state['claimedSpinShort'] = true;
        break;
      case 'spin_long':
        _state['claimedSpinLong'] = true;
        break;
      case 'play_15':
        _state['claimedPlay15'] = true;
        break;
      case 'play_45':
        _state['claimedPlay45'] = true;
        break;
      default:
        return false;
    }

    _save();
    _game.addDiamonds(mission.rewardDiamonds);
    notifyListeners();
    return true;
  }
}
