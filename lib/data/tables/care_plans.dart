import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/entities/care_plan_activity.dart';

class CarePlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn? get targetUserMuid => text().nullable()();
  TextColumn? get finishedByUserMuid => text().nullable()();
  TextColumn get activity => text().map(const CarePlanActivityConverter()).nullable()();
  DateTimeColumn get scheduledStart => dateTime()();
  IntColumn get versionId => integer().nullable()();
}
