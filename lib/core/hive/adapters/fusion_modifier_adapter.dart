import 'package:hive/hive.dart';
import '../../constants/pokedex_constants.dart';

class FusionModifierAdapter extends TypeAdapter<FusionModifier> {
  @override
  final int typeId = 6;

  @override
  FusionModifier read(BinaryReader reader) {
    return FusionModifier.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, FusionModifier obj) {
    writer.writeInt(obj.index);
  }
}
