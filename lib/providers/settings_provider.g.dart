// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsStateAdapter extends TypeAdapter<SettingsState> {
  @override
  final int typeId = 20;

  @override
  SettingsState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsState(
      vibrationEnabled: fields[0] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsState obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.vibrationEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
