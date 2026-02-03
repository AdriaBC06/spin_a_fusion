import 'package:hive/hive.dart';
import '../models/fusion_entry.dart';

part 'home_slots_state.g.dart';

@HiveType(typeId: 4)
class HomeSlotsState {
  @HiveField(0)
  final List<FusionEntry?> slots;

  @HiveField(1)
  int unlockedCount;

  HomeSlotsState({
    required this.slots,
    required this.unlockedCount,
  });

  factory HomeSlotsState.empty(
    int totalSlots, {
    int unlockedCount = 3,
  }) =>
      HomeSlotsState(
        slots: List<FusionEntry?>.filled(totalSlots, null),
        unlockedCount: unlockedCount,
      );
}
