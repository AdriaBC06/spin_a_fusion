import 'package:hive/hive.dart';
import '../../constants/pokedex_constants.dart';

class BallTypeAdapter extends TypeAdapter<BallType> {
  @override
  final int typeId = 2;

  @override
  BallType read(BinaryReader reader) {
    return BallType.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, BallType obj) {
    writer.writeInt(obj.index);
  }
}
