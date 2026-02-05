String formatMoney(int value) {
  if (value <= 999) return value.toString();

  const int thousand = 1000;
  const int million = 1000000;
  const int billion = 1000000000;

  if (value >= billion) {
    return _formatWithSuffix(value / billion, 'B');
  }
  if (value >= million) {
    return _formatWithSuffix(value / million, 'M');
  }
  return _formatWithSuffix(value / thousand, 'k');
}

String _formatWithSuffix(double value, String suffix) {
  final fixed = value.toStringAsFixed(2);
  final trimmed = fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  return '$trimmed$suffix';
}
