import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';

import '../../cloud/services/firebase_sync_service.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/fusion_pedia_provider.dart';
import '../../../providers/home_slots_provider.dart';

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      final username = _usernameController.text.trim();
      if (username.isEmpty) {
        throw Exception('Username is required');
      }

      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: username,
      );
      await FirebaseSyncService().sync(
        game: context.read<GameProvider>(),
        collection: context.read<FusionCollectionProvider>(),
        pedia: context.read<FusionPediaProvider>(),
        homeSlots: context.read<HomeSlotsProvider>(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration:
                const InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _register,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
