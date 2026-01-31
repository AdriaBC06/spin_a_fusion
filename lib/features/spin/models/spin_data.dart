import '../../../models/pokemon.dart';

class SpinData {
  final List<Pokemon> items;
  final int startIndex;
  final int resultIndex;

  const SpinData({
    required this.items,
    required this.startIndex,
    required this.resultIndex,
  });
}
