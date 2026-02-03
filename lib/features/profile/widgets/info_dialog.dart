import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Info'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Desarrollado por Adrià Bonnin i Adrià Rebasa',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            'v1.0.2',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
