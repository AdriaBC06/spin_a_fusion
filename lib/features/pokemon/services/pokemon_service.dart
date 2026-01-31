import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/pokemon.dart';

class PokemonService {
  static Future<Pokemon> fetchPokemon({
    required String name,
    required int fusionId,
  }) async {
    final pokemonUrl =
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');

    final pokemonRes = await http.get(pokemonUrl);
    if (pokemonRes.statusCode != 200) {
      throw Exception('Error cargando Pokémon $name');
    }

    final pokemonJson = jsonDecode(pokemonRes.body);
    final pokeApiId = pokemonJson['id'];

    final speciesUrl = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon-species/$pokeApiId',
    );

    final speciesRes = await http.get(speciesUrl);
    if (speciesRes.statusCode != 200) {
      throw Exception('Error cargando species de $name');
    }

    final speciesJson = jsonDecode(speciesRes.body);
    final catchRate = speciesJson['capture_rate'] as int;

    return Pokemon.fromJson(
      pokemonJson,
      fusionId: fusionId,
      catchRate: catchRate,
    );
  }
}

