import 'package:flutter/material.dart';

Future<bool?> showConfirmCloudOverwriteDialog(
  BuildContext context,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('¿Sobrescribir la nube?'),
      content: const Text(
        'Este dispositivo tiene un progreso más reciente que la nube.\n\n'
        '¿Quieres sobrescribir la partida en la nube con la de este dispositivo?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Sobrescribir nube'),
        ),
      ],
    ),
  );
}
