import 'package:flutter/material.dart';

Future<bool?> showConfirmRestoreFromCloudDialog(
  BuildContext context,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Cloud save found'),
      content: const Text(
        'A cloud save was found for this account.\n\n'
        'Do you want to overwrite your local progress '
        'with the cloud save?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Keep local'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Use cloud'),
        ),
      ],
    ),
  );
}
