import 'package:flutter/material.dart';
import 'money_counter.dart';
import 'diamond_counter.dart';
import 'profile_menu.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: const [
            // Left side counters
            MoneyCounter(),
            SizedBox(width: 8),
            DiamondCounter(),
            Spacer(),
            // Right side profile menu
            ProfileMenu(),
          ],
        ),
      ),
    );
  }
}
