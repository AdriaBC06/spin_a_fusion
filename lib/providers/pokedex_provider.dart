import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/pokemon.dart';
import '../features/pokemon/services/pokemon_service.dart';
import '../core/constants/pokedex_constants.dart';
import '../core/constants/fusion_pokemon_list.dart';

class PokedexProvider extends ChangeNotifier {
  final Box<Pokemon> _box = Hive.box<Pokemon>('pokedex');
  final List<Pokemon> _pokemonList = [];

  int _loadedCount = 0;

  int get loadedCount => _loadedCount;
  int get totalCount => expectedPokemonCount;

  double get progress =>
      totalCount == 0 ? 0 : _loadedCount / totalCount;

  List<Pokemon> get pokemonList => List.unmodifiable(_pokemonList);

  bool get isLoaded => _loadedCount == totalCount;

  Future<void> initialize() async {
    _pokemonList.clear();
    _loadedCount = 0;
    notifyListeners();

    if (_box.length == expectedPokemonCount) {
      for (final pokemon in _box.values) {
        _pokemonList.add(pokemon);
        _loadedCount++;
        notifyListeners();
      }
    } else {
      await _reloadFromApi();
    }
  }

  Future<void> _reloadFromApi() async {
    await _box.clear();

    for (final entry in fusionPokemonList.take(expectedPokemonCount)) {
      final pokemon = await PokemonService.fetchPokemon(
        name: entry['name'],
        fusionId: entry['fusionId'],
      );

      _pokemonList.add(pokemon);
      await _box.put(entry['fusionId'], pokemon);

      _loadedCount++;
      notifyListeners(); // 🔥 THIS MAKES THE BAR MOVE
    }
  }

  // ------------------ GAME LOGIC (UNCHANGED) ------------------

  double _ballExponent(BallType ball) {
    switch (ball) {
      case BallType.poke:
        return 2.4;
      case BallType.superBall:
        return 1.7;
      case BallType.ultra:
        return 1.2;
      case BallType.master:
      case BallType.silver:
      case BallType.gold:
      case BallType.ruby:
      case BallType.sapphire:
      case BallType.emerald:
      case BallType.test:
        return 0.9;
    }
  }

  int _ballMinCatchRate(BallType ball) {
    switch (ball) {
      case BallType.poke:
        return 1;
      case BallType.superBall:
        return 35;
      case BallType.ultra:
        return 85;
      case BallType.master:
      case BallType.silver:
      case BallType.gold:
      case BallType.ruby:
      case BallType.sapphire:
      case BallType.emerald:
      case BallType.test:
        return 140;
    }
  }

  double _lowCatchRatePenalty(int catchRate, BallType ball) {
    if (catchRate >= 10) return 1.0;

    switch (ball) {
      case BallType.poke:
        return 0.0;
      case BallType.superBall:
        return 0.05;
      case BallType.ultra:
        return 0.01;
      case BallType.master:
      case BallType.silver:
      case BallType.gold:
      case BallType.ruby:
      case BallType.sapphire:
      case BallType.emerald:
      case BallType.test:
        return 0.1;
    }
  }

  double _weightFor(Pokemon p, BallType ball) {
    final minCR = _ballMinCatchRate(ball);
    final exp = _ballExponent(ball);

    final effectiveCR = max(p.catchRate, minCR);
    final baseWeight =
        pow(effectiveCR / 255, exp).toDouble();

    final penalty = _lowCatchRatePenalty(p.catchRate, ball);
    return baseWeight * penalty;
  }

  Pokemon getRandomPokemon({BallType ball = BallType.poke}) {
    for (final p in _pokemonList) {
      if (p.name.toLowerCase() == 'bulbasaur') {
        return p;
      }
    }
    return _pokemonList.first;
    final rng = Random();
    double totalWeight = 0;

    for (final p in _pokemonList) {
      totalWeight += _weightFor(p, ball);
    }

    double r = rng.nextDouble() * totalWeight;

    for (final p in _pokemonList) {
      r -= _weightFor(p, ball);
      if (r <= 0) return p;
    }

    return _pokemonList.last;
  }

  double probabilityOfPokemon(
    Pokemon target, {
    BallType ball = BallType.poke,
  }) {
    double totalWeight = 0;
    for (final p in _pokemonList) {
      totalWeight += _weightFor(p, ball);
    }

    return _weightFor(target, ball) / totalWeight;
  }

  double fusionCatchRate(Pokemon p1, Pokemon p2) {
    final raw = sqrt(p1.catchRate * p2.catchRate);
    return (raw * 0.75).clamp(1, 255);
  }

  double probabilityOfFusion({
    required Pokemon p1,
    required Pokemon p2,
    BallType ball = BallType.poke,
  }) {
    final fusionCR = fusionCatchRate(p1, p2);
    final minCR = _ballMinCatchRate(ball);
    final exp = _ballExponent(ball);

    final effectiveFusionCR = max(fusionCR, minCR);
    final baseWeight =
        pow(effectiveFusionCR / 255, exp).toDouble();

    final penalty =
        _lowCatchRatePenalty(fusionCR.round(), ball);

    final fusionWeight = baseWeight * penalty;

    double totalWeight = 0;
    for (final p in _pokemonList) {
      totalWeight += _weightFor(p, ball);
    }

    return fusionWeight / totalWeight;
  }
}
