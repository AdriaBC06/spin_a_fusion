import 'package:firebase_auth/firebase_auth.dart';

import '../../../providers/home_slots_provider.dart';
import 'firebase_restore_service.dart';
import 'firebase_sync_service.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/fusion_pedia_provider.dart';

enum CloudDecision { useLocal, useCloud, autoLocal, autoUploadLocal }

class CloudDecisionResult {
  final CloudDecision decision;
  final int localTime;
  final int cloudTime;

  CloudDecisionResult({
    required this.decision,
    required this.localTime,
    required this.cloudTime,
  });
}

class CloudDecisionService {
  final _auth = FirebaseAuth.instance;
  final _restore = FirebaseRestoreService();
  final _sync = FirebaseSyncService();

  Future<CloudDecisionResult?> evaluate({required GameProvider game}) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final cloud = await _restore.fetchCloud();
    final localTime = game.playTimeSeconds;

    // ----------------------------
    // NO CLOUD
    // ----------------------------
    if (cloud == null) {
      if (localTime > 0) {
        return CloudDecisionResult(
          decision: CloudDecision.autoUploadLocal,
          localTime: localTime,
          cloudTime: 0,
        );
      }
      return null;
    }

    final cloudTime = (cloud['playTimeSeconds'] ?? 0) as int;

    // ----------------------------
    // NO LOCAL
    // ----------------------------
    if (localTime == 0 && cloudTime > 0) {
      return CloudDecisionResult(
        decision: CloudDecision.useCloud,
        localTime: 0,
        cloudTime: cloudTime,
      );
    }

    // ----------------------------
    // BOTH EXIST
    // ----------------------------
    if (localTime > cloudTime) {
      return CloudDecisionResult(
        decision: CloudDecision.autoLocal,
        localTime: localTime,
        cloudTime: cloudTime,
      );
    }

    if (localTime < cloudTime) {
      return CloudDecisionResult(
        decision: CloudDecision.useCloud,
        localTime: localTime,
        cloudTime: cloudTime,
      );
    }

    // Equal time → ask
    return CloudDecisionResult(
      decision: CloudDecision.useCloud,
      localTime: localTime,
      cloudTime: cloudTime,
    );
  }

  Future<void> apply({
    required CloudDecision decision,
    required Map<String, dynamic>? cloud,
    required GameProvider game,
    required FusionCollectionProvider collection,
    required FusionPediaProvider pedia,
    required HomeSlotsProvider homeSlots,
  }) async {
    switch (decision) {
      case CloudDecision.useCloud:
        if (cloud != null) {
          await _restore.restoreFromCloud(
            cloud: cloud,
            game: game,
            collection: collection,
            pedia: pedia,
            homeSlots: homeSlots,
          );
        }
        break;

      case CloudDecision.autoUploadLocal:
      case CloudDecision.autoLocal:
      case CloudDecision.useLocal:
        await _sync.sync(
          game: game,
          collection: collection,
          pedia: pedia,
          homeSlots: homeSlots,
        );
        break;
    }
  }
}
