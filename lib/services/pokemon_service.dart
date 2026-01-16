import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {
  static Future<Pokemon> fetchPokemon(int id) async {
    final url = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon/$id',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Pokemon.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error cargando Pokémon $id');
    }
  }
}
