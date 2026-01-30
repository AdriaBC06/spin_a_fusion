import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'settings_provider.g.dart';

@HiveType(typeId: 20)
class SettingsState {
  @HiveField(0)
  final bool vibrationEnabled;

  const SettingsState({
    required this.vibrationEnabled,
  });

  factory SettingsState.defaults() =>
      const SettingsState(vibrationEnabled: true);

  SettingsState copyWith({
    bool? vibrationEnabled,
  }) {
    return SettingsState(
      vibrationEnabled:
          vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _stateKey = 'state';

  late Box<SettingsState> _box;
  late SettingsState _state;

  Future<void> init() async {
    _box = await Hive.openBox<SettingsState>(_boxName);
    _state =
        _box.get(_stateKey) ?? SettingsState.defaults();
    await _box.put(_stateKey, _state);
  }

  bool get vibrationEnabled => _state.vibrationEnabled;

  void setVibrationEnabled(bool value) {
    if (_state.vibrationEnabled == value) return;
    _state = _state.copyWith(vibrationEnabled: value);
    _box.put(_stateKey, _state);
    notifyListeners();
  }
}
