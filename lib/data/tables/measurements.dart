import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/enums/overall_health_state.dart';
import 'package:scalesoft_app/data/entities/enums/shortness_of_breath_level.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement/blood_pressure_value.dart';
import 'package:scalesoft_app/data/tables/devices.dart';
import 'package:scalesoft_app/data/tables/users.dart';

class Measurements extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #id, onDelete: KeyAction.cascade)();

  IntColumn get deviceId => integer().references(Devices, #id, onDelete: KeyAction.cascade).nullable()();

  DateTimeColumn get measuredAt => dateTime()();

  TextColumn get measurementType => textEnum<MeasurementType>()();

  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();

  RealColumn get temperature => real().nullable()();

  TextColumn get bloodPressure => text().map(BloodPressureValue.converter).nullable()();

  IntColumn get heartRate => integer().nullable()();

  IntColumn get oxygenSaturation => integer().nullable()();

  IntColumn get respiratoryRate => integer().nullable()();

  TextColumn get shortnessOfBreath => textEnum<ShortnessOfBreathLevel>().nullable()();

  TextColumn get overallHealth => textEnum<OverallHealthState>().nullable()();

  IntColumn get batteryPercentage => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, measurementType, measuredAt},
      ];
}
