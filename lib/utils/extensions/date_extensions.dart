import 'package:intl/intl.dart';

extension DateParse on DateTime {
  String getRegularDate() {
    return DateFormat('dd.MM.yyyy').format(toLocal());
  }
}
