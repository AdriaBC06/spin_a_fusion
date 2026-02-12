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

  Future<void> resetToDefault() async {
    _state = <String, dynamic>{};
    await _box.put(_stateKey, _state);
    _ensureToday();
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
    _state['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
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
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    _save();
    notifyListeners();
  }

  Map<String, dynamic> toCloudMap() {
    _ensureToday();
    return {
      'dateKey': _state['dateKey'],
      'startSpins': _state['startSpins'],
      'startPlaySeconds': _state['startPlaySeconds'],
      'spinTargetShort': _state['spinTargetShort'],
      'spinTargetLong': _state['spinTargetLong'],
      'claimedSpinShort': _state['claimedSpinShort'] == true,
      'claimedSpinLong': _state['claimedSpinLong'] == true,
      'claimedPlay15': _state['claimedPlay15'] == true,
      'claimedPlay45': _state['claimedPlay45'] == true,
      'updatedAt': _state['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  void restoreFromCloud(Map<String, dynamic>? cloudState) {
    _ensureToday();
    if (cloudState == null) return;

    final today = _todayKey();
    final cloudDate = cloudState['dateKey'];
    if (cloudDate is! String || cloudDate != today) {
      return;
    }

    int readInt(String key, int fallback) {
      final v = cloudState[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return fallback;
    }

    bool readBool(String key, bool fallback) {
      final v = cloudState[key];
      if (v is bool) return v;
      return fallback;
    }

    _state['dateKey'] = today;
    _state['startSpins'] = readInt(
      'startSpins',
      (_state['startSpins'] as int?) ?? _game.totalSpins,
    );
    _state['startPlaySeconds'] = readInt(
      'startPlaySeconds',
      (_state['startPlaySeconds'] as int?) ?? _game.playTimeSeconds,
    );

    final cloudShort = readInt('spinTargetShort', _spinTargetShort);
    final cloudLong = readInt('spinTargetLong', _spinTargetLong);
    _state['spinTargetShort'] = cloudShort.clamp(16, 25);
    _state['spinTargetLong'] = cloudLong.clamp(140, 175);

    _state['claimedSpinShort'] = readBool('claimedSpinShort', false) || _claimed('claimedSpinShort');
    _state['claimedSpinLong'] = readBool('claimedSpinLong', false) || _claimed('claimedSpinLong');
    _state['claimedPlay15'] = readBool('claimedPlay15', false) || _claimed('claimedPlay15');
    _state['claimedPlay45'] = readBool('claimedPlay45', false) || _claimed('claimedPlay45');
    _state['updatedAt'] = readInt(
      'updatedAt',
      DateTime.now().millisecondsSinceEpoch,
    );

    _save();
    notifyListeners();
  }

  Duration get timeUntilReset {
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    return next.difference(now);
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
