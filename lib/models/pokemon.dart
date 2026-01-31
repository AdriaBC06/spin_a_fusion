import 'package:hive/hive.dart';

part 'pokemon.g.dart';

@HiveType(typeId: 0)
class Pokemon {
  @HiveField(0)
  final int fusionId;

  @HiveField(1)
  final int pokeApiId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int hp;

  @HiveField(4)
  final int attack;

  @HiveField(5)
  final int defense;

  @HiveField(6)
  final int specialAttack;

  @HiveField(7)
  final int specialDefense;

  @HiveField(8)
  final int speed;

  @HiveField(9)
  final String pokemonSprite;

  @HiveField(10)
  final int catchRate;

  const Pokemon({
    required this.fusionId,
    required this.pokeApiId,
    required this.name,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
    required this.pokemonSprite,
    required this.catchRate,
  });

  int get totalStats =>
      hp + attack + defense + specialAttack + specialDefense + speed;

  factory Pokemon.fromJson(
    Map<String, dynamic> json, {
    required int fusionId,
    required int catchRate,
  }) {
    int stat(String name) =>
        json['stats'].firstWhere((s) => s['stat']['name'] == name)['base_stat'];

    final pokeApiId = json['id'] as int;

    return Pokemon(
      fusionId: fusionId,
      pokeApiId: pokeApiId,
      name: json['name'],
      hp: stat('hp'),
      attack: stat('attack'),
      defense: stat('defense'),
      specialAttack: stat('special-attack'),
      specialDefense: stat('special-defense'),
      speed: stat('speed'),
      catchRate: catchRate,
      pokemonSprite:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/'
          'sprites/pokemon/$pokeApiId.png',
    );
  }
}
