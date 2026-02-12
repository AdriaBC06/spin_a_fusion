import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/pokedex_constants.dart';
import '../../../models/fusion_entry.dart';
import '../../../providers/fusion_collection_provider.dart';

/// ------------------------------------------------------
/// TRADE SESSION DATA
/// ------------------------------------------------------
class TradeSessionData {
  final String tradeId;
  final String token;
  final DateTime expiresAt;

  TradeSessionData({
    required this.tradeId,
    required this.token,
    required this.expiresAt,
  });
}

/// ------------------------------------------------------
/// TRADE STATUS
/// ------------------------------------------------------
enum TradeStatus { open, completed, cancelled, expired }

/// ------------------------------------------------------
/// FIREBASE TRADE SERVICE
/// ------------------------------------------------------
class FirebaseTradeService {
  static const Duration tradeLifetime = Duration(seconds: 90);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _trades =>
      _firestore.collection('trade_sessions');

  // ======================================================
  // CREATE TRADE (RECEIVER)
  // ======================================================
  Future<TradeSessionData> createTradeSession({
    required String receiverName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final tradeRef = _trades.doc();
    final token = _secureToken();

    final now = DateTime.now();
    final expiresAt = now.add(tradeLifetime);

    await tradeRef.set({
      'receiverUid': user.uid,
      'receiverName': receiverName,

      'senderUid': null,
      'senderName': null,

      'status': 'open',
      'token': token,

      'fusion': null,

      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'cancelledBy': null,
    });

    return TradeSessionData(
      tradeId: tradeRef.id,
      token: token,
      expiresAt: expiresAt,
    );
  }

  // ======================================================
  // LISTEN TO TRADE (REAL-TIME)
  // ======================================================
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToTrade(String tradeId) {
    return _trades.doc(tradeId).snapshots();
  }

  // ======================================================
  // JOIN TRADE (SENDER AFTER QR SCAN)
  // ======================================================
  Future<void> joinTradeSession({
    required String tradeId,
    required String token,
    required String senderName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final ref = _trades.doc(tradeId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw Exception('Trade not found');
      }

      final data = snap.data()!;
      _validateTradeOpen(data, token);

      if (data['senderUid'] != null) {
        throw Exception('Trade already joined');
      }

      tx.update(ref, {'senderUid': user.uid, 'senderName': senderName});
    });
  }

  // --------------------------------------------------
  // COMPLETE TRADE (TRANSACTIONAL SEND)
  // --------------------------------------------------
  Future<void> completeTradeWithFusion({
    required String tradeId,
    required String token,
    required FusionEntry fusion,
    required FusionCollectionProvider senderCollection,
  }) async {
    final sender = _auth.currentUser;
    if (sender == null) throw Exception('User not authenticated');

    final ref = _trades.doc(tradeId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw Exception('Trade not found');

      final data = snap.data()!;
      _validateTradeOpen(data, token);

      if (data['senderUid'] != sender.uid) {
        throw Exception('Not authorized to complete trade');
      }

      if (!senderCollection.contains(fusion)) {
        throw Exception('Sender does not own fusion');
      }

      final fusionPayload = {
        'key': _fusionKey(fusion.p1.fusionId, fusion.p2.fusionId),
        'ball': fusion.ball.index,
        'modifier': fusion.modifier?.index,
      };

      tx.update(ref, {'fusion': fusionPayload, 'status': 'completed'});

      // ✅ ONLY SENDER UPDATES LOCAL STATE
      senderCollection.removeFusion(fusion);
    });
  }

  // ======================================================
  // CANCEL TRADE (BOTH SIDES)
  // ======================================================
  Future<void> cancelTrade({required String tradeId}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final ref = _trades.doc(tradeId);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final data = snap.data()!;
      if (data['status'] != 'open') return;

      final role = data['receiverUid'] == user.uid ? 'receiver' : 'sender';

      tx.update(ref, {'status': 'cancelled', 'cancelledBy': role});
    });
  }

  // ======================================================
  // EXPIRE TRADE (CLIENT SAFETY)
  // ======================================================
  Future<void> expireTradeIfNeeded(String tradeId) async {
    final ref = _trades.doc(tradeId);
    final snap = await ref.get();
    if (!snap.exists) return;

    final data = snap.data()!;
    if (data['status'] != 'open') return;

    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    if (DateTime.now().isBefore(expiresAt)) return;

    await ref.update({'status': 'expired'});
  }

  // ======================================================
  // VALIDATION
  // ======================================================
  void _validateTradeOpen(Map<String, dynamic> data, String token) {
    if (data['status'] != 'open') {
      throw Exception('Trade is not open');
    }

    if (data['token'] != token) {
      throw Exception('Invalid trade token');
    }

    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    if (DateTime.now().isAfter(expiresAt)) {
      throw Exception('Trade expired');
    }
  }

  // ======================================================
  // HELPERS
  // ======================================================
  String _secureToken() {
    final rand = Random.secure();
    return List.generate(32, (_) => rand.nextInt(36).toRadixString(36)).join();
  }

  int _fusionKey(int id1, int id2) => id1 * expectedPokemonCount + id2;
}
