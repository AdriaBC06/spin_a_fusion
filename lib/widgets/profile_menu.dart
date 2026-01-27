import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_dialog.dart';

class ProfileMenu extends StatefulWidget {
  const ProfileMenu({super.key});

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  late final Animation<Offset> _slideAnimation =
      Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  late final Animation<double> _fadeAnimation =
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

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

  OverlayEntry _createOverlay(User? user) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    List<_ProfileMenuItem> items = [];

    if (user == null) {
      items.add(_ProfileMenuItem(
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
      ));
    } else {
      items.add(_ProfileMenuItem(
        icon: Icons.logout,
        title: 'Logout',
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          _closeMenu();
        },
      ));
    }

    // Common items
    items.addAll([
      _ProfileMenuItem(icon: Icons.settings, title: 'Settings', onTap: _closeMenu),
      _ProfileMenuItem(icon: Icons.info_outline, title: 'About', onTap: _closeMenu),
    ]);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent barrier to detect outside taps
          GestureDetector(
            onTap: _closeMenu,
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Positioned(
            top: offset.dy + size.height + 4,
            right: 12,
            width: 180,
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
      builder: (context, snapshot) {
        final user = snapshot.data;
        return CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: () => _toggleMenu(user),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade800,
              child: user != null && user.photoURL != null
                  ? ClipOval(
                      child: Image.network(user.photoURL!, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.person, color: Colors.white),
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
