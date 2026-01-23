import 'package:hive/hive.dart';

part 'pokemon.g.dart';

@HiveType(typeId: 0)
class Pokemon {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int hp;

  @HiveField(3)
  final int attack;

  @HiveField(4)
  final int defense;

  @HiveField(5)
  final int specialAttack;

  @HiveField(6)
  final int specialDefense;

  @HiveField(7)
  final int speed;

  // ✅ NEW FIELD (non-nullable, backward-safe)
  @HiveField(8)
  final String pokemonSprite;

  Pokemon({
    required this.id,
    required this.name,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
    required this.pokemonSprite,
  });

  int get totalStats =>
      hp + attack + defense + specialAttack + specialDefense + speed;

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    int getStat(String name) {
      return json['stats']
          .firstWhere((s) => s['stat']['name'] == name)['base_stat'];
    }

    return Pokemon(
      id: json['id'],
      name: json['name'],
      hp: getStat('hp'),
      attack: getStat('attack'),
      defense: getStat('defense'),
      specialAttack: getStat('special-attack'),
      specialDefense: getStat('special-defense'),
      speed: getStat('speed'),
      pokemonSprite: json['sprites']['front_default'] ?? '',
    );
  }
}