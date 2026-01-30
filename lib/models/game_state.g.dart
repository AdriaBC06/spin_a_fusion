// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameStateAdapter extends TypeAdapter<GameState> {
  @override
  final int typeId = 5;

  @override
  GameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameState(
      money: fields[0] as int,
      diamonds: fields[1] as int,
      balls: (fields[2] as Map).cast<BallType, int>(),
      playTimeSeconds: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameState obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.money)
      ..writeByte(1)
      ..write(obj.diamonds)
      ..writeByte(2)
      ..write(obj.balls)
      ..writeByte(3)
      ..write(obj.playTimeSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
