import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../service/auth_service.dart';

import '../../cloud/services/firebase_restore_service.dart';
import '../../cloud/widgets/cloud_restore_dialog.dart';

import '../../../providers/game_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/fusion_pedia_provider.dart';
import '../../../providers/home_slots_provider.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      // ----------------------------
      // LOGIN
      // ----------------------------
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ----------------------------
      // CHECK CLOUD
      // ----------------------------
      final restoreService = FirebaseRestoreService();
      final cloud = await restoreService.fetchCloud();

      if (cloud != null && mounted) {
        final localSeconds =
            context.read<GameProvider>().playTimeSeconds;

        final cloudSeconds =
            cloud['playTimeSeconds'] as int? ?? 0;

        final choice = await showCloudRestoreDialog(
          context,
          localSeconds: localSeconds,
          cloudSeconds: cloudSeconds,
        );

        if (choice == CloudRestoreChoice.cloud) {
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

          await restoreService.restoreFromCloud(
            cloud: cloud,
            game: context.read<GameProvider>(),
            collection:
                context.read<FusionCollectionProvider>(),
            pedia:
                context.read<FusionPediaProvider>(),
            homeSlots:
                context.read<HomeSlotsProvider>(),
          );
        }
      }

      // ----------------------------
      // CLOSE DIALOG
      // ----------------------------
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration:
                const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            decoration:
                const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _login,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Login'),
        ),
      ],
    );
  }
}
