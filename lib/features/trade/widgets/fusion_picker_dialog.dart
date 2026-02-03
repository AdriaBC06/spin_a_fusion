import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/fusion_collection_provider.dart';

class FusionPickerDialog extends StatelessWidget {
  const FusionPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final fusions = context.watch<FusionCollectionProvider>().fusions;

    return AlertDialog(
      title: const Text('Select Fusion to Send'),
      content: SizedBox(
        width: double.maxFinite,
        child: fusions.length <= 1
            ? const Text('You need at least 2 fusions to trade.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: fusions.length <= 1 ? 0 : fusions.length,

                itemBuilder: (_, i) {
                  final fusion = fusions[i];
                  return ListTile(
                    leading: Image.network(
                      fusion.customFusionUrl,
                      width: 48,
                      errorBuilder: (_, __, ___) =>
                          Image.network(fusion.autoGenFusionUrl, width: 48),
                    ),
                    title: Text(fusion.fusionName),
                    subtitle: Text('Ball: ${fusion.ball.name}'),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirm Send'),
                          content: Text(
                            'Send ${fusion.fusionName}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Send'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        Navigator.pop(context, fusion);
                      }
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
