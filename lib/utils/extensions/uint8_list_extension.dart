import 'package:flutter/foundation.dart';

extension Uint8ListExtension on List<int> {
  int toInt16(int fromIndex, int toIndex) {
    final bytes = Uint8List.fromList(sublist(fromIndex, toIndex).reversed.toList());
    final buffer = bytes.buffer;
    final bdata = ByteData.view(buffer);
    return bdata.getInt16(0);
  }

  int toInt8(int fromIndex, int toIndex) {
    final bytes = Uint8List.fromList(sublist(fromIndex, toIndex).reversed.toList());
    final buffer = bytes.buffer;
    final bdata = ByteData.view(buffer);
    return bdata.getInt8(0);
  }

  DateTime toTimestamp(int fromIndex, int toIndex) {
    final int year = toInt16(fromIndex, fromIndex + 2);
    final int month = toInt8(fromIndex + 2, fromIndex + 3);
    final int day = toInt8(fromIndex + 3, fromIndex + 4);
    final int hours = toInt8(fromIndex + 4, fromIndex + 5);
    final int minutes = toInt8(fromIndex + 5, fromIndex + 6);
    final int seconds = toInt8(fromIndex + 6, fromIndex + 7);

    return DateTime(
      year,
      month,
      day,
      hours,
      minutes,
      seconds,
    );
    // return dateTime.toIso8601String();
  }
}
