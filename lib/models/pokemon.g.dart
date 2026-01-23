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
      fusionId: fields[0] as int,
      pokeApiId: fields[1] as int,
      name: fields[2] as String,
      hp: fields[3] as int,
      attack: fields[4] as int,
      defense: fields[5] as int,
      specialAttack: fields[6] as int,
      specialDefense: fields[7] as int,
      speed: fields[8] as int,
      pokemonSprite: fields[9] as String,
      catchRate: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Pokemon obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.fusionId)
      ..writeByte(1)
      ..write(obj.pokeApiId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.hp)
      ..writeByte(4)
      ..write(obj.attack)
      ..writeByte(5)
      ..write(obj.defense)
      ..writeByte(6)
      ..write(obj.specialAttack)
      ..writeByte(7)
      ..write(obj.specialDefense)
      ..writeByte(8)
      ..write(obj.speed)
      ..writeByte(9)
      ..write(obj.pokemonSprite)
      ..writeByte(10)
      ..write(obj.catchRate);
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
