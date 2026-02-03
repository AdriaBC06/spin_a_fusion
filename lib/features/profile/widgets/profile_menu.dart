import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:spin_a_fusion/features/trade/widgets/receive_fusion_screen.dart';

import '../../auth/widgets/login_dialog.dart';
import '../../auth/widgets/register_dialog.dart';

import '../../../providers/game_provider.dart';
import '../../../providers/fusion_collection_provider.dart';
import '../../../providers/fusion_pedia_provider.dart';
import '../../../providers/home_slots_provider.dart';

import '../../cloud/services/firebase_sync_service.dart';
import '../../cloud/widgets/confirm_cloud_overwrite_dialog.dart';
import 'settings_panel.dart';
import 'debug_add_currency_dialog.dart';
import 'leaderboard_dialog.dart';

import '../../trade/widgets/send_fusion_flow.dart';

class ProfileMenu extends StatefulWidget {
  const ProfileMenu({super.key});

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, -0.1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  late final Animation<double> _fadeAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  void _toggleMenu(User? user) {
    if (_isOpen) {
      _closeMenu();
    } else {
      _overlayEntry = _createOverlay(user);
      Overlay.of(context).insert(_overlayEntry!);
      _controller.forward();
      setState(() => _isOpen = true);
    }
  }

  void _closeMenu() {
    _controller.reverse();
    Future.delayed(const Duration(milliseconds: 200), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
    setState(() => _isOpen = false);
  }

  // ------------------------------------------------------
  // SYNC → CLOUD
  // ------------------------------------------------------
  Future<void> _syncToCloud() async {
    final confirmed = await showConfirmCloudOverwriteDialog(context);
    if (confirmed != true) {
      _closeMenu();
      return;
    }

    try {
      await FirebaseSyncService().sync(
        game: context.read<GameProvider>(),
        collection: context.read<FusionCollectionProvider>(),
        pedia: context.read<FusionPediaProvider>(),
        homeSlots: context.read<HomeSlotsProvider>(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('☁️ Cloud overwritten')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Sync failed: $e')));
    }

    _closeMenu();
  }

  // ------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'This will log you out and reset all local progress on this device.\n\n'
          'Cloud data will NOT be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      _closeMenu();
      return;
    }

    // Auto-sync before logout.
    try {
      await FirebaseSyncService().sync(
        game: context.read<GameProvider>(),
        collection: context.read<FusionCollectionProvider>(),
        pedia: context.read<FusionPediaProvider>(),
        homeSlots: context.read<HomeSlotsProvider>(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Sync failed: $e')),
        );
      }
    }

    // Sign out after sync.
    await FirebaseAuth.instance.signOut();

    await context.read<GameProvider>().resetToDefault();
    await context.read<FusionCollectionProvider>().resetToDefault();
    await context.read<FusionPediaProvider>().resetToDefault();
    await context.read<HomeSlotsProvider>().resetToDefault();
    _closeMenu();
  }

  OverlayEntry _createOverlay(User? user) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final List<_ProfileMenuItem> items = [];
    final fusionCount = context.read<FusionCollectionProvider>().fusions.length;

    // --------------------------------------------------
    // NOT LOGGED IN
    // --------------------------------------------------
    if (user == null) {
      items.addAll([
        _ProfileMenuItem(
          icon: Icons.login,
          title: 'Login',
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => const LoginDialog(),
              ),
            );
            _closeMenu();
          },
        ),
        _ProfileMenuItem(
          icon: Icons.person_add,
          title: 'Create account',
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => const RegisterDialog(),
              ),
            );
            _closeMenu();
          },
        ),
      ]);
    }
    // --------------------------------------------------
    // LOGGED IN
    // --------------------------------------------------
    else {
      items.addAll([
        _ProfileMenuItem(
          icon: Icons.qr_code,
          title: 'Receive Fusion',
          onTap: () {
            _closeMenu();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const ReceiveFusionScreen(),
            );
          },
        ),

        _ProfileMenuItem(
          icon: Icons.qr_code_scanner,
          title: 'Send Fusion',
          onTap: fusionCount <= 1
              ? () {
                  _closeMenu();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ You need at least 2 fusions to trade'),
                    ),
                  );
                }
              : () {
                  _closeMenu();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SendFusionFlow()),
                  );
                },
        ),

        _ProfileMenuItem(
          icon: Icons.cloud_upload,
          title: 'Sync to Cloud',
          onTap: _syncToCloud,
        ),
        _ProfileMenuItem(icon: Icons.logout, title: 'Logout', onTap: _logout),
      ]);
    }

    // --------------------------------------------------
    // COMMON
    // --------------------------------------------------
    items.addAll([
      _ProfileMenuItem(
        icon: Icons.emoji_events,
        title: 'Leaderboard',
        onTap: () {
          _closeMenu();
          showDialog(
            context: context,
            builder: (_) => LeaderboardDialog(),
          );
        },
      ),
      _ProfileMenuItem(
        icon: Icons.bug_report,
        title: 'Debug: Add Currency',
        onTap: () {
          _closeMenu();
          showDialog(
            context: context,
            builder: (_) => const DebugAddCurrencyDialog(),
          );
        },
      ),
      _ProfileMenuItem(
        icon: Icons.settings,
        title: 'Settings',
        onTap: () {
          _closeMenu();
          showDialog(context: context, builder: (_) => const SettingsPanel());
        },
      ),
      _ProfileMenuItem(
        icon: Icons.info_outline,
        title: 'About',
        onTap: _closeMenu,
      ),
    ]);

    return OverlayEntry(
      builder: (_) => Stack(
        children: [
          GestureDetector(
            onTap: _closeMenu,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            top: offset.dy + size.height + 6,
            right: 12,
            width: 220,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade900,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snapshot) {
        final user = snapshot.data;

        return GestureDetector(
          onTap: () => _toggleMenu(user),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade800,
            child: user?.photoURL != null
                ? ClipOval(
                    child: Image.network(user!.photoURL!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.person, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
