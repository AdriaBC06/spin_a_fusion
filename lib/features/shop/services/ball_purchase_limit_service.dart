import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/pokedex_constants.dart';

class BallPurchaseLimitService {
  static const Map<BallType, Duration> _cooldowns = {
    BallType.silver: Duration(hours: 1),
    BallType.gold: Duration(hours: 2),
    BallType.ruby: Duration(hours: 6),
    BallType.sapphire: Duration(hours: 6),
    BallType.emerald: Duration(hours: 12),
  };

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  BallPurchaseLimitService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  bool hasLimit(BallType ball) => _cooldowns.containsKey(ball);

  Duration? cooldownFor(BallType ball) => _cooldowns[ball];

  Future<LimitResult> tryConsume(BallType ball) async {
    final cooldown = _cooldowns[ball];
    if (cooldown == null) {
      return const LimitResult.allowed();
    }

    final user = _auth.currentUser;
    if (user == null) {
      return const LimitResult.allowed();
    }

    final now = await _fetchServerTime();
    final docRef = _firestore.collection('users').doc(user.uid);

    final result = await _firestore.runTransaction((tx) async {
      final doc = await tx.get(docRef);
      final data = doc.data() ?? {};
      final limits = Map<String, dynamic>.from(
        data['ballPurchaseLimits'] ?? {},
      );

      final key = ball.index.toString();
      final raw = limits[key];
      final last = raw is Timestamp ? raw.toDate() : null;

      if (last != null) {
        final next = last.add(cooldown);
        if (now.isBefore(next)) {
          return LimitResult.blocked(next.difference(now));
        }
      }

      limits[key] = FieldValue.serverTimestamp();
      tx.set(docRef, {'ballPurchaseLimits': limits}, SetOptions(merge: true));

      return const LimitResult.allowed();
    });

    return result;
  }

  Future<DateTime> _fetchServerTime() async {
    final ref = _firestore.collection('meta').doc('server_time');
    await ref.set({'ts': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    final snap = await ref.get();
    final ts = snap.data()?['ts'] as Timestamp?;
    return ts?.toDate() ?? DateTime.now().toUtc();
  }
}

class LimitResult {
  final bool allowed;
  final Duration? remaining;

  const LimitResult.allowed()
      : allowed = true,
        remaining = null;

  const LimitResult.blocked(this.remaining) : allowed = false;
}
