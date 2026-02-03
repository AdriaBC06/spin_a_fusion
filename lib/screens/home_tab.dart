import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/home/widgets/home_slots_grid.dart';
import '../features/shop/widgets/inventory_section.dart';
import '../providers/home_slots_provider.dart';
import '../features/fusion/fusion_economy.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: HomeSlotsGrid(),
          ),
          SizedBox(height: 16),
          TotalGoldPerSecondWidget(),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(thickness: 2),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: InventorySection(),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ----------------------------
// DYNAMIC ANIMATED TOTAL GOLD WIDGET
// ----------------------------
class TotalGoldPerSecondWidget extends StatefulWidget {
  const TotalGoldPerSecondWidget({super.key});

  @override
  State<TotalGoldPerSecondWidget> createState() =>
      _TotalGoldPerSecondWidgetState();
}

class _TotalGoldPerSecondWidgetState
    extends State<TotalGoldPerSecondWidget> {
  int _displayedTotal = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final slotsProvider = context.watch<HomeSlotsProvider>();
    _updateTotal(slotsProvider);
  }

  @override
  void didUpdateWidget(covariant TotalGoldPerSecondWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final slotsProvider = context.watch<HomeSlotsProvider>();
    _updateTotal(slotsProvider);
  }

  void _updateTotal(HomeSlotsProvider slotsProvider) {
    final newTotal = slotsProvider.slots
        .where((fusion) => fusion != null)
        .fold<int>(
          0,
          (sum, fusion) =>
              sum + FusionEconomy.incomePerSecond(fusion!),
        );

    if (newTotal != _displayedTotal) {
      setState(() {
        _displayedTotal = newTotal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: Colors.amber),
          const SizedBox(width: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: _displayedTotal),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, _) {
              return Text(
                'Total: $value Dinero/s',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
