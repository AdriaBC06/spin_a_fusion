import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../providers/game_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/fusion_pedia_provider.dart';
import '../../../providers/home_slots_provider.dart';
import '../../../core/constants/pokedex_constants.dart';
import '../../../models/fusion_entry.dart';

class FirebaseSyncService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static DateTime? _lastSyncAt;

  // ------------------------------------------------------
  // PUBLIC API
  // ------------------------------------------------------
  Future<void> sync({
    required GameProvider game,
    required FusionCollectionProvider collection,
    required FusionPediaProvider pedia,
    required HomeSlotsProvider homeSlots,
    bool force = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final now = DateTime.now();
    if (!force &&
        _lastSyncAt != null &&
        now.difference(_lastSyncAt!) <
            const Duration(minutes: 1)) {
      return;
    }

    final payload = _buildPayload(
      game: game,
      collection: collection,
      pedia: pedia,
      homeSlots: homeSlots,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(payload, SetOptions(merge: true));

    _lastSyncAt = now;
  }

  // ------------------------------------------------------
  // BUILD PAYLOAD
  // ------------------------------------------------------
  Map<String, dynamic> _buildPayload({
    required GameProvider game,
    required FusionCollectionProvider collection,
    required FusionPediaProvider pedia,
    required HomeSlotsProvider homeSlots,
  }) {
    final username = _auth.currentUser?.displayName;

    return {
      'schemaVersion': 4,
      'lastSync': DateTime.now().millisecondsSinceEpoch,

      'playTimeSeconds': game.playTimeSeconds,
      'playTimeMinutes': (game.playTimeSeconds / 60).floor(),
      'money': game.money,
      'diamonds': game.diamonds,
      'totalSpins': game.totalSpins,
      'autoSpinUnlocked': game.autoSpinUnlocked,

      if (username != null && username.isNotEmpty)
        'username': username,

      'balls': _encodeBalls(game),

      'ownedFusions':
          _encodeFusions(collection.allFusions),
      'ownedFusionsV2':
          _encodeFusionsWithFavorites(collection.allFusions),
      'pediaFusions':
          _encodePediaClaims(pedia.sortedFusions),
      'pediaCount': pedia.sortedFusions.length,

      // 🔥 HOME SLOTS
      'homeSlots': _encodeHomeSlots(homeSlots),
      'homeSlotsUnlocked': homeSlots.unlockedCount,
    };
  }

  // ------------------------------------------------------
  // ENCODERS
  // ------------------------------------------------------
  Map<String, int> _encodeBalls(GameProvider game) {
    final map = <String, int>{};

    for (final type in BallType.values) {
      final count = game.ballCount(type);
      if (count > 0) {
        map[type.index.toString()] = count;
      }
    }

    return map;
  }

  List<int> _encodeFusions(List<FusionEntry> fusions) {
    return fusions
        .map((f) => _fusionKey(
              f.p1.fusionId,
              f.p2.fusionId,
            ))
        .toSet()
        .toList();
  }

  Map<String, bool> _encodeFusionsWithFavorites(
      List<FusionEntry> fusions) {
    final map = <String, bool>{};

    for (final fusion in fusions) {
      final key = _fusionKey(
        fusion.p1.fusionId,
        fusion.p2.fusionId,
      );

      if (fusion.favorite) {
        map[key.toString()] = true;
      } else {
        map.putIfAbsent(key.toString(), () => false);
      }
    }

    return map;
  }

  Map<String, bool> _encodePediaClaims(
      List<FusionEntry> fusions) {
    final map = <String, bool>{};

    for (final fusion in fusions) {
      final key = _fusionKey(
        fusion.p1.fusionId,
        fusion.p2.fusionId,
      );
      map[key.toString()] = fusion.claimPending;
    }

    return map;
  }

  Map<String, int?> _encodeHomeSlots(
      HomeSlotsProvider home) {
    final map = <String, int?>{};

    for (int i = 0;
        i < home.unlockedCount;
        i++) {
      final fusion = home.slots[i];
      map[i.toString()] = fusion == null
          ? null
          : _fusionKey(
              fusion.p1.fusionId,
              fusion.p2.fusionId,
            );
    }

    return map;
  }

  // ------------------------------------------------------
  // FUSION KEY
  // ------------------------------------------------------
  int _fusionKey(int id1, int id2) =>
      id1 * expectedPokemonCount + id2;
}
