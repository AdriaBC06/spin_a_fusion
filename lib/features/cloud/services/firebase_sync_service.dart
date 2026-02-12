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
      'schemaVersion': 5,
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
      'ownedFusionsBalls':
          _encodeFusionBalls(collection.allFusions),
      'ownedFusionsV3':
          _encodeFusionsWithBalls(collection.allFusions),
      'ownedFusionsV2':
          _encodeFusionsWithFavorites(collection.allFusions),
      'pediaFusions':
          _encodePediaClaims(pedia.sortedFusions),
      'pediaFusionsV2':
          _encodePediaClaimsV2(pedia.sortedFusions),
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

  Map<String, int> _encodeFusionBalls(List<FusionEntry> fusions) {
    final map = <String, int>{};

    for (final fusion in fusions) {
      final key = _fusionKey(
        fusion.p1.fusionId,
        fusion.p2.fusionId,
      );
      map[key.toString()] = fusion.ball.index;
    }

    return map;
  }

  List<Map<String, int>> _encodeFusionsWithBalls(
      List<FusionEntry> fusions) {
    return fusions
        .map((f) => {
              'k': _fusionKey(f.p1.fusionId, f.p2.fusionId),
              'b': f.ball.index,
              if (f.modifier != null) 'm': f.modifier!.index,
              if (f.uid != null) 'u': f.uid!,
            })
        .toList();
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

  Map<String, bool> _encodePediaClaimsV2(
      List<FusionEntry> fusions) {
    final map = <String, bool>{};

    for (final fusion in fusions) {
      final key =
          '${fusion.p1.fusionId}-${fusion.p2.fusionId}-${fusion.ball.index}';
      map[key] = fusion.claimPending;
    }

    return map;
  }

  Map<String, dynamic> _encodeHomeSlots(
      HomeSlotsProvider home) {
    final map = <String, dynamic>{};

    for (int i = 0;
        i < home.unlockedCount;
        i++) {
      final fusion = home.slots[i];
      map[i.toString()] = fusion == null
          ? null
          : {
              'k': _fusionKey(
                fusion.p1.fusionId,
                fusion.p2.fusionId,
              ),
              'b': fusion.ball.index,
              if (fusion.modifier != null)
                'm': fusion.modifier!.index,
              if (fusion.uid != null) 'u': fusion.uid!,
            };
    }

    return map;
  }

  // ------------------------------------------------------
  // FUSION KEY
  // ------------------------------------------------------
  int _fusionKey(int id1, int id2) =>
      id1 * expectedPokemonCount + id2;
}
