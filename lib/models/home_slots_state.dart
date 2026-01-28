import 'package:hive/hive.dart';
import '../models/fusion_entry.dart';

part 'home_slots_state.g.dart';

@HiveType(typeId: 4)
class HomeSlotsState {
  @HiveField(0)
  final List<FusionEntry?> slots;

  HomeSlotsState(this.slots);

  factory HomeSlotsState.empty(int totalSlots) =>
      HomeSlotsState(List<FusionEntry?>.filled(totalSlots, null));
}
