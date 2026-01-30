import 'package:flutter/material.dart';

enum CloudRestoreChoice {
  cloud,
  local,
}

Future<CloudRestoreChoice?> showCloudRestoreDialog(
  BuildContext context, {
  required int localSeconds,
  required int cloudSeconds,
}) {
  String format(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;

    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m';
  }

  return showDialog<CloudRestoreChoice>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('☁️ Progreso encontrado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Se ha encontrado progreso tanto en este dispositivo '
            'como en la nube.\n\n¿Qué progreso quieres usar?',
          ),
          const SizedBox(height: 16),
          Text('📱 Local: ${format(localSeconds)}'),
          const SizedBox(height: 8),
          Text('☁️ Nube: ${format(cloudSeconds)}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, CloudRestoreChoice.local),
          child: const Text('Usar local'),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.pop(context, CloudRestoreChoice.cloud),
          child: const Text('Usar nube'),
        ),
      ],
    ),
  );
}
