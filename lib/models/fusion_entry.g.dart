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
      favorite: fields[5] as bool? ?? false,
      modifier: fields[6] as FusionModifier?,
      uid: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, FusionEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.p1)
      ..writeByte(1)
      ..write(obj.p2)
      ..writeByte(2)
      ..write(obj.ball)
      ..writeByte(3)
      ..write(obj.rarity)
      ..writeByte(4)
      ..write(obj.claimPending)
      ..writeByte(5)
      ..write(obj.favorite)
      ..writeByte(6)
      ..write(obj.modifier)
      ..writeByte(7)
      ..write(obj.uid);
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
