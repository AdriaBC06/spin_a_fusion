import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  void _testVibration(BuildContext context) {
    final settings = context.read<SettingsProvider>();

    if (!settings.vibrationEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vibration is disabled in settings'),
        ),
      );
      return;
    }

    // 🔔 REAL DEVICE VIBRATION (NOT HAPTIC HINT)
    HapticFeedback.vibrate();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vibration triggered'),
        duration: Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text(
                'Enable vibration during spins',
              ),
              value: settings.vibrationEnabled,
              onChanged: settings.setVibrationEnabled,
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.vibration),
                label: const Text('Test vibration'),
                onPressed: () => _testVibration(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
