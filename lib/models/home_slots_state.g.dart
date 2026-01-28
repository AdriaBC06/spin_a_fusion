// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_slots_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HomeSlotsStateAdapter extends TypeAdapter<HomeSlotsState> {
  @override
  final int typeId = 4;

  @override
  HomeSlotsState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HomeSlotsState(
      (fields[0] as List).cast<FusionEntry?>(),
    );
  }

  @override
  void write(BinaryWriter writer, HomeSlotsState obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.slots);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeSlotsStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
