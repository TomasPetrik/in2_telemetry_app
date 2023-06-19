extension StringParse on String {
  double toDouble() {
    final usingDots = replaceAll(',', '.');
    return double.parse(usingDots);
  }

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
