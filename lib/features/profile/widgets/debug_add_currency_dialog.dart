import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/game_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/fusion_pedia_provider.dart';
import '../../../providers/home_slots_provider.dart';

class DebugAddCurrencyDialog extends StatefulWidget {
  const DebugAddCurrencyDialog({super.key});

  @override
  State<DebugAddCurrencyDialog> createState() =>
      _DebugAddCurrencyDialogState();
}

class _DebugAddCurrencyDialogState
    extends State<DebugAddCurrencyDialog> {
  final _moneyController = TextEditingController(text: '0');
  final _diamondController = TextEditingController(text: '0');

  int _parse(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? 0;
  }

  @override
  void dispose() {
    _moneyController.dispose();
    _diamondController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Debug: Añadir moneda'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _moneyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Dinero',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _diamondController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Diamantes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Reiniciar progreso'),
                    content: const Text(
                      'Esto reiniciará todo el progreso local en este dispositivo.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context, true),
                        child: const Text('Reiniciar'),
                      ),
                    ],
                  ),
                );

                if (confirmed != true) return;

                await context.read<GameProvider>().resetToDefault();
                await context
                    .read<FusionCollectionProvider>()
                    .resetToDefault();
                await context
                    .read<FusionPediaProvider>()
                    .resetToDefault();
                await context
                    .read<HomeSlotsProvider>()
                    .resetToDefault();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Reiniciar todo el progreso'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final money = _parse(_moneyController);
            final diamonds = _parse(_diamondController);

            if (money != 0) {
              context.read<GameProvider>().addMoney(money);
            }
            if (diamonds != 0) {
              context.read<GameProvider>().addDiamonds(diamonds);
            }

            Navigator.pop(context);
          },
          child: const Text('Añadir'),
        ),
      ],
    );
  }
}
