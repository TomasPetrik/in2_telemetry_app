extension StringParse on String {
  double toDouble() {
    final usingDots = replaceAll(',', '.');
    return double.parse(usingDots);
  }
}
