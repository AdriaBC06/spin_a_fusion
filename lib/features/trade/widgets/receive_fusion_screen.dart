import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

import '../services/firebase_trade_service.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/fusion_pedia_provider.dart';
import '../../../providers/home_slots_provider.dart';
import '../../../providers/daily_missions_provider.dart';
import '../../cloud/services/firebase_sync_service.dart';
import '../../../models/fusion_entry.dart';
import '../../../models/pokemon.dart';
import '../../../core/constants/pokedex_constants.dart';
import 'trade_qr_widget.dart';

class ReceiveFusionScreen extends StatefulWidget {
  const ReceiveFusionScreen({super.key});

  @override
  State<ReceiveFusionScreen> createState() => _ReceiveFusionScreenState();
}

class _ReceiveFusionScreenState extends State<ReceiveFusionScreen> {
  final _tradeService = FirebaseTradeService();

  String? _tradeId;
  String? _token;
  DateTime? _expiresAt;

  StreamSubscription<DocumentSnapshot>? _sub;
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  bool _completed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _startTrade();
  }

  // ======================================================
  // START TRADE
  // ======================================================
  Future<void> _startTrade() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Debes iniciar sesión para recibir'),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final username =
        userDoc.data()?['username'] as String? ?? 'Unknown';

    final session = await _tradeService.createTradeSession(
      receiverName: username,
    );

    if (!mounted) return;

    setState(() {
      _tradeId = session.tradeId;
      _token = session.token;
      _expiresAt = session.expiresAt;
      _remaining = session.expiresAt.difference(DateTime.now());
      _loading = false;
    });

    _sub = _tradeService
        .listenToTrade(session.tradeId)
        .listen(_onTradeUpdate);

    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining =
          session.expiresAt.difference(DateTime.now());

      if (remaining.isNegative) {
        _expire();
      } else if (mounted) {
        setState(() => _remaining = remaining);
      }
    });
  }

  // ======================================================
  // FIRESTORE UPDATES
  // ======================================================
  void _onTradeUpdate(DocumentSnapshot snap) {
    if (!snap.exists || _completed) return;

    final data = snap.data() as Map<String, dynamic>;
    final status = data['status'] as String;

    if (status == 'completed') {
      _applyFusion(data);
    } else if (status == 'cancelled' || status == 'expired') {
      _close();
    }
  }

  // ======================================================
  // APPLY FUSION
  // ======================================================
  void _applyFusion(Map<String, dynamic> data) {
    if (_completed) return;
    _completed = true;

    final fusionData = data['fusion'];
    if (fusionData == null) {
      _close();
      return;
    }

    final int key = fusionData['key'];
    final int ballIndex = fusionData['ball'];
    final int? modifierIndex = fusionData['modifier'] as int?;

    final id1 = key ~/ expectedPokemonCount;
    final id2 = key % expectedPokemonCount;

    final pokemonBox = Hive.box<Pokemon>('pokedex');
    final p1 = pokemonBox.get(id1);
    final p2 = pokemonBox.get(id2);

    if (p1 == null || p2 == null) {
      _close();
      return;
    }

    final fusion = FusionEntry(
      p1: p1,
      p2: p2,
      ball: BallType.values[ballIndex],
      rarity: 1.0,
      modifier: modifierIndex != null &&
              modifierIndex >= 0 &&
              modifierIndex < FusionModifier.values.length
          ? FusionModifier.values[modifierIndex]
          : null,
      uid: DateTime.now().microsecondsSinceEpoch,
    );

    context.read<FusionCollectionProvider>().addFusion(fusion);

    FirebaseSyncService().sync(
      game: context.read<GameProvider>(),
      collection: context.read<FusionCollectionProvider>(),
      pedia: context.read<FusionPediaProvider>(),
      homeSlots: context.read<HomeSlotsProvider>(),
      dailyMissions: context.read<DailyMissionsProvider>(),
      force: true,
    );

    if (context.read<SettingsProvider>().vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }

    final senderName = data['senderName'] ?? 'Alguien';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎁 Fusión recibida de $senderName'),
      ),
    );

    _close();
  }

  // ======================================================
  // CANCEL / EXPIRE
  // ======================================================
  Future<void> _cancel() async {
    if (_tradeId != null) {
      await _tradeService.cancelTrade(tradeId: _tradeId!);
    }
    _close();
  }

  void _expire() async {
    if (_tradeId != null) {
      await _tradeService.expireTradeIfNeeded(_tradeId!);
    }
    _close();
  }

  void _close() {
    _sub?.cancel();
    _countdownTimer?.cancel();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recibir fusión'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancel,
        ),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TradeQrWidget(
                    tradeId: _tradeId!,
                    token: _token!,
                    expiresAt: _expiresAt!,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Expira en ${_remaining.inSeconds}s',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
