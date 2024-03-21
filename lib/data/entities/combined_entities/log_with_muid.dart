import 'package:scalesoft_app/data/app_database.dart';

class LogWithMuid {
  final String? muid;
  final LogEvent log;

  LogWithMuid(this.muid, this.log);
}