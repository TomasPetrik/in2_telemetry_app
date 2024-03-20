import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/data/tables/users.dart';

class LogEvents extends Table {
  IntColumn get id =>integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #id).nullable()();

  TextColumn get appVersion => text()();

  TextColumn get osVersion => text()();

  TextColumn get severity => textEnum<LogSeverity>()();

  TextColumn get message => text()();

  DateTimeColumn get eventTime => dateTime()();
}
