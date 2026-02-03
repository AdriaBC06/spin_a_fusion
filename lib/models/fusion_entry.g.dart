// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fusion_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FusionEntryAdapter extends TypeAdapter<FusionEntry> {
  @override
  final int typeId = 1;

  @override
  FusionEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FusionEntry(
      p1: fields[0] as Pokemon,
      p2: fields[1] as Pokemon,
      ball: fields[2] as BallType,
      rarity: fields[3] as double,
      claimPending: fields[4] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, FusionEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.p1)
      ..writeByte(1)
      ..write(obj.p2)
      ..writeByte(2)
      ..write(obj.ball)
      ..writeByte(3)
      ..write(obj.rarity)
      ..writeByte(4)
      ..write(obj.claimPending);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FusionEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
