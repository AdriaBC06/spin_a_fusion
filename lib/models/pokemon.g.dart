// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PokemonAdapter extends TypeAdapter<Pokemon> {
  @override
  final int typeId = 0;

  @override
  Pokemon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pokemon(
      id: fields[0] as int,
      name: fields[1] as String,
      hp: fields[2] as int,
      attack: fields[3] as int,
      defense: fields[4] as int,
      specialAttack: fields[5] as int,
      specialDefense: fields[6] as int,
      speed: fields[7] as int,
      pokemonSprite: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Pokemon obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.hp)
      ..writeByte(3)
      ..write(obj.attack)
      ..writeByte(4)
      ..write(obj.defense)
      ..writeByte(5)
      ..write(obj.specialAttack)
      ..writeByte(6)
      ..write(obj.specialDefense)
      ..writeByte(7)
      ..write(obj.speed)
      ..writeByte(8)
      ..write(obj.pokemonSprite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
