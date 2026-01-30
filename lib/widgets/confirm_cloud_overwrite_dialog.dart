import 'package:flutter/material.dart';

Future<bool?> showConfirmCloudOverwriteDialog(
  BuildContext context,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Overwrite cloud save?'),
      content: const Text(
        'This device has more recent progress than the cloud.\n\n'
        'Do you want to overwrite the cloud save with this device?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Overwrite cloud'),
        ),
      ],
    ),
  );
}
