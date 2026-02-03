import 'package:flutter/material.dart';

Future<bool?> showConfirmRestoreFromCloudDialog(
  BuildContext context,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Se encontró una partida en la nube'),
      content: const Text(
        'Se encontró una partida en la nube para esta cuenta.\n\n'
        '¿Quieres sobrescribir tu progreso local '
        'con la partida de la nube?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Mantener local'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Usar nube'),
        ),
      ],
    ),
  );
}
