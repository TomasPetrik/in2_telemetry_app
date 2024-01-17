class MacAddressHelper {
  /// Normalizes the format of a provided MAC address [macAddress]
  ///
  /// The returned string is in lowercase and '-' is replaced by ':'.
  static String normalizeFormat(String macAddress) {
    return macAddress.toUpperCase().replaceAll('-', ':');
  }

  /// Compares two MAC addresses, [first] and [second]
  ///
  /// Returns true if the normalized formats of the [first] and [second] MAC addresses are identical.
  static bool compare(String? first, String? second) {
    if (first == null || second == null) {
      return false;
    }
    return normalizeFormat(first) == normalizeFormat(second);
  }
}
