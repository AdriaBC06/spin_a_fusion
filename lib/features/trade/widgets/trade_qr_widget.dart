import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TradeQrWidget extends StatelessWidget {
  final String tradeId;
  final String token;
  final DateTime expiresAt;

  const TradeQrWidget({
    super.key,
    required this.tradeId,
    required this.token,
    required this.expiresAt,
  });

  @override
  Widget build(BuildContext context) {
    final payload = jsonEncode({
      'tradeId': tradeId,
      'token': token,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrImageView(
          data: payload,
          size: 220,
          backgroundColor: Colors.white,
        ),
        const SizedBox(height: 12),
        const Text(
          'Scan this QR to send a fusion',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
