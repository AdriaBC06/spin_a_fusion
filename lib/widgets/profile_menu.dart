import 'package:flutter/material.dart';

class ProfileMenu extends StatefulWidget {
  const ProfileMenu({super.key});

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  bool _isOpen = false;

  void _toggleMenu() => setState(() => _isOpen = !_isOpen);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: _toggleMenu,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade800,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isOpen
              ? Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade900,
                  child: SizedBox(
                    width: 180,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _ProfileMenuItem(icon: Icons.login, title: 'Login'),
                        _ProfileMenuItem(icon: Icons.settings, title: 'Settings'),
                        _ProfileMenuItem(icon: Icons.info_outline, title: 'About'),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
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