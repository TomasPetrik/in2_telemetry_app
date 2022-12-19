import 'package:intl/intl.dart';

extension DateParse on DateTime {
  String getDateFormatLong() {
    return DateFormat('MMM d, yyyy, hh:mm a').format(toLocal());
  }

  String getDateFormatShort() {
    return DateFormat('d.M.yyyy').format(toLocal());
  }

  String getTimeShort() {
    return DateFormat('hh:mm').format(toLocal());
  }
}
