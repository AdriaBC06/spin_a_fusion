import 'package:hive/hive.dart';
import '../../constants/pokedex_constants.dart';

class BallTypeAdapter extends TypeAdapter<BallType> {
  @override
  final int typeId = 2;

  @override
  BallType read(BinaryReader reader) {
    final index = reader.readInt();
    if (index == BallType.test.index) {
      return BallType.poke;
    }
    if (index < 0 || index >= BallType.values.length) {
      return BallType.poke;
    }
    return BallType.values[index];
  }

  @override
  void write(BinaryWriter writer, BallType obj) {
    writer.writeInt(obj.index);
  }
}
