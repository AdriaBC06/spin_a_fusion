import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  static Future<Pokemon> fetchPokemon({
    required String name,
    required int fusionId,
  }) async {
    final url = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon/$name',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Pokemon.fromJson(
        jsonDecode(response.body),
        fusionId: fusionId,
      );
    } else {
      throw Exception('Error cargando Pokémon $name');
    }
  }
}
