import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/pokedex_constants.dart';
import '../../../models/fusion_entry.dart';
import '../../../models/pokemon.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/fusion_pedia_provider.dart';
import '../../../providers/home_slots_provider.dart';

class FirebaseRestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // --------------------------------------------------
  // FETCH
  // --------------------------------------------------
  Future<Map<String, dynamic>?> fetchCloud() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;
    return doc.data();
  }

  // --------------------------------------------------
  // RESTORE
  // --------------------------------------------------
  Future<void> restoreFromCloud({
    required Map<String, dynamic> cloud,
    required GameProvider game,
    required FusionCollectionProvider collection,
    required FusionPediaProvider pedia,
    required HomeSlotsProvider homeSlots,
  }) async {
    // -------- GAME --------
    game.setMoney(cloud['money'] ?? 0);
    game.setDiamonds(cloud['diamonds'] ?? 0);
    game.setPlayTimeSeconds(cloud['playTimeSeconds'] ?? 0);
    game.setTotalSpins(cloud['totalSpins'] ?? 0);
    game.setAutoSpinUnlocked(cloud['autoSpinUnlocked'] ?? false);

    // -------- BALLS --------
    final balls =
        Map<String, dynamic>.from(cloud['balls'] ?? {});

    for (final entry in balls.entries) {
      final type =
          BallType.values[int.parse(entry.key)];
      game.addBall(type, amount: entry.value);
    }

    // -------- FUSIONS --------
    final pokemonBox = Hive.box<Pokemon>('pokedex');

    FusionEntry? decode(
      int key, {
      bool claimPending = false,
      bool favorite = false,
    }) {
      final id1 = key ~/ expectedPokemonCount;
      final id2 = key % expectedPokemonCount;

      final p1 = pokemonBox.get(id1);
      final p2 = pokemonBox.get(id2);

      if (p1 == null || p2 == null) {
        return null;
      }

      return FusionEntry(
        p1: p1,
        p2: p2,
        ball: BallType.poke,
        rarity: 1.0,
        claimPending: claimPending,
        favorite: favorite,
      );
    }

    final ownedFavoritesRaw = cloud['ownedFusionsV2'];
    final favoriteMap = <int, bool>{};

    if (ownedFavoritesRaw is Map<String, dynamic>) {
      for (final entry in ownedFavoritesRaw.entries) {
        final key = int.tryParse(entry.key);
        if (key == null) continue;
        favoriteMap[key] = entry.value == true;
      }
    }

    final owned = List<int>.from(cloud['ownedFusions'] ?? []);
    for (final key in owned) {
      final favorite = favoriteMap[key] ?? false;
      final fusion = decode(key, favorite: favorite);
      if (fusion != null) {
        collection.addFusion(fusion);
      }
    }

    final pediaClaimsRaw = cloud['pediaFusions'];

    if (pediaClaimsRaw is Map<String, dynamic>) {
      for (final entry in pediaClaimsRaw.entries) {
        final key = int.tryParse(entry.key);
        if (key == null) continue;
        final pending = entry.value == true;
        final fusion = decode(key, claimPending: pending);
        if (fusion != null) {
          pedia.registerFusionFromCloud(fusion);
        }
      }
    } else {
      // Backward compatibility (schema <= 2)
      final pediaList =
          List<int>.from(cloud['pediaFusions'] ?? []);
      final pendingList =
          List<int>.from(cloud['pediaPending'] ?? []);
      final pendingSet = pendingList.toSet();

      for (final key in pediaList) {
        final fusion = decode(
          key,
          claimPending: pendingSet.contains(key),
        );
        if (fusion != null) {
          pedia.registerFusionFromCloud(fusion);
        }
      }
    }

    // -------- HOME SLOTS --------
    final unlocked =
        (cloud['homeSlotsUnlocked'] ?? HomeSlotsProvider.initialUnlocked)
            as int;
    homeSlots.setUnlockedCount(unlocked);

    final rawSlots =
        Map<String, dynamic>.from(cloud['homeSlots'] ?? {});

    for (final entry in rawSlots.entries) {
      final index = int.parse(entry.key);
      if (index >= homeSlots.unlockedCount) {
        continue;
      }

      final int? key = entry.value;
      if (key == null) {
        homeSlots.setSlot(index, null);
        continue;
      }

      final fusion = decode(key);
      if (fusion != null) {
        homeSlots.setSlot(index, fusion);
      } else {
        homeSlots.setSlot(index, null);
      }
    }
  }
}
