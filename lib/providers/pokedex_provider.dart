import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../constants/constants.dart';

class PokedexProvider extends ChangeNotifier {
  final Box<Pokemon> _box = Hive.box<Pokemon>('pokedex');
  final List<Pokemon> _pokemonList = [];

  List<Pokemon> get pokemonList => List.unmodifiable(_pokemonList);

  bool get isLoaded => _pokemonList.length == expectedPokemonCount;

  Future<void> initialize() async {
    if (_box.length == expectedPokemonCount) {
      _pokemonList.addAll(_box.values);
    } else {
      await _reloadFromApi();
    }
    notifyListeners();
  }

  Future<void> _reloadFromApi() async {
    await _box.clear();
    _pokemonList.clear();

    for (int id = 1; id <= expectedPokemonCount; id++) {
      final pokemon = await PokemonService.fetchPokemon(id);
      _pokemonList.add(pokemon);
      await _box.put(id, pokemon);
    }
  }

  Pokemon getRandomPokemon() {
    _pokemonList.shuffle();
    return _pokemonList.first;
  }
}
