import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';

class LogEvents extends Table {
  TextColumn get userMuid => text().nullable()();

  TextColumn get appVersion => text()();

  TextColumn get osVersion => text()();

  TextColumn get severity => textEnum<LogSeverity>()();

  TextColumn get message => text()();

  DateTimeColumn get eventTime => dateTime()();
}
