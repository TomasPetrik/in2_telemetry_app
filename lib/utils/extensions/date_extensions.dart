import 'package:intl/intl.dart';

extension DateParse on DateTime {
  String toRegularDate() {
    return DateFormat('dd.MM.yyyy').format(toLocal());
  }
}
