import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../providers/settings_provider.dart';
import 'debug_add_currency_dialog.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final _usernameController = TextEditingController();
  bool _savingUsername = false;

  User? get _user => FirebaseAuth.instance.currentUser;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = _user;
    if (user == null) return;

    final doc =
        await _firestore.collection('users').doc(user.uid).get();

    final username = doc.data()?['username'] as String?;
    if (username != null) {
      _usernameController.text = username;
    }
  }

  Future<void> _saveUsername() async {
    final user = _user;
    if (user == null) return;

    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() => _savingUsername = true);

    await _firestore.collection('users').doc(user.uid).set(
      {
        'username': username,
      },
      SetOptions(merge: true),
    );

    setState(() => _savingUsername = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre de usuario actualizado')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isLoggedIn = _user != null;

    return AlertDialog(
      title: const Text('Ajustes'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ----------------------------------
            // USERNAME (ONLY WHEN LOGGED IN)
            // ----------------------------------
            if (isLoggedIn) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nombre de usuario',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu nombre de usuario',
                  border: OutlineInputBorder(),
                ),
                maxLength: 20,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _savingUsername ? null : _saveUsername,
                  child: _savingUsername
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Guardar nombre de usuario'),
                ),
              ),
              const Divider(height: 32),
            ],

            // ----------------------------------
            // VIBRATION TOGGLE
            // ----------------------------------
            SwitchListTile(
              title: const Text('Vibración'),
              subtitle: const Text(
                'Activar efectos de vibración',
              ),
              value: settings.vibrationEnabled,
              onChanged: settings.setVibrationEnabled,
            ),
            const Divider(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const DebugAddCurrencyDialog(),
                  );
                },
                icon: const Icon(Icons.bug_report),
                label: const Text('Debug'),
              ),
            ),
          ],
        ),
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
