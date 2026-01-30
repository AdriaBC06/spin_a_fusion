import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

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
        const SnackBar(content: Text('Username updated')),
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
      title: const Text('Settings'),
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
                  'Username',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your username',
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
                      : const Text('Save username'),
                ),
              ),
              const Divider(height: 32),
            ],

            // ----------------------------------
            // VIBRATION TOGGLE
            // ----------------------------------
            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text(
                'Enable vibration effects',
              ),
              value: settings.vibrationEnabled,
              onChanged: settings.setVibrationEnabled,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
