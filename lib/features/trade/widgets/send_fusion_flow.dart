import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:spin_a_fusion/providers/home_slots_provider.dart';

import '../services/firebase_trade_service.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/fusion_pedia_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../features/cloud/services/firebase_sync_service.dart';
import '../../../models/fusion_entry.dart';
import 'fusion_picker_dialog.dart';

class SendFusionFlow extends StatefulWidget {
  const SendFusionFlow({super.key});

  @override
  State<SendFusionFlow> createState() => _SendFusionFlowState();
}

class _SendFusionFlowState extends State<SendFusionFlow> {
  final FirebaseTradeService _tradeService = FirebaseTradeService();
  bool _processing = false;

  Future<void> _onQrScanned(String raw) async {
    if (_processing) return;
    _processing = true;

    try {
      // --------------------------------------
      // PARSE QR PAYLOAD
      // --------------------------------------
      final data = jsonDecode(raw);
      final String tradeId = data['tradeId'];
      final String token = data['token'];
      final int expiresAtMs = data['expiresAt'];

      if (DateTime.now().isAfter(
        DateTime.fromMillisecondsSinceEpoch(expiresAtMs),
      )) {
        throw Exception('Trade expired');
      }

      // --------------------------------------
      // FETCH SENDER USERNAME
      // --------------------------------------
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Debes iniciar sesión para enviar'),
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

      final String senderName =
          userDoc.data()?['username'] as String? ?? 'Unknown';

      // --------------------------------------
      // JOIN TRADE (CLAIM SLOT)
      // --------------------------------------
      await _tradeService.joinTradeSession(
        tradeId: tradeId,
        token: token,
        senderName: senderName,
      );

      // --------------------------------------
      // PICK FUSION TO SEND
      // --------------------------------------
      final FusionEntry? fusion = await showDialog<FusionEntry>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const FusionPickerDialog(),
      );

      // Sender cancelled
      if (fusion == null) {
        await _tradeService.cancelTrade(tradeId: tradeId);
        if (mounted) Navigator.pop(context);
        return;
      }

      final senderCollection = context.read<FusionCollectionProvider>();

      // --------------------------------------
      // COMPLETE TRADE (SENDER SIDE)
      // --------------------------------------
      await _tradeService.completeTradeWithFusion(
        tradeId: tradeId,
        token: token,
        fusion: fusion,
        senderCollection: senderCollection,
      );
      context.read<HomeSlotsProvider>().purgeFusion(fusion);

      await FirebaseSyncService().sync(
        game: context.read<GameProvider>(),
        collection: context.read<FusionCollectionProvider>(),
        pedia: context.read<FusionPediaProvider>(),
        homeSlots: context.read<HomeSlotsProvider>(),
        force: true,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎁 Fusión enviada con éxito')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ $e')));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar fusión')),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          final raw = barcode.rawValue;
          if (raw != null) {
            _onQrScanned(raw);
          }
        },
      ),
    );
  }
}
