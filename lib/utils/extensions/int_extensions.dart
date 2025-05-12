extension IntBits on int {
  /// Returns integer value of bits between [start] and [end] from the least
  /// significant to most significant where LSB is at position 0.
  ///
  /// The integer contains bits at positions greater than or equal to [start] and
  /// less than [end].
  ///
  /// The `start` and `end` positions must satisfy the relations
  /// 0 ≤ `start` ≤ `end`.
  int getBits(int start, int end) {
    if (start < 0) {
      throw Exception("Start out of range");
    }
    if (end < 0) {
      throw Exception("End out of range");
    }
    if (end < start) {
      throw Exception("End must be greater than start");
    }
    var val = toUnsigned(end);
    val >>= start;
    return val;
  }

  /// Returns value of bit at [position] from LSB to MSB starting at 0.
  ///
  /// The [position] must be greater or equal to 0.
  int getBit(int position) {
    return getBits(position, position + 1);
  }
}
