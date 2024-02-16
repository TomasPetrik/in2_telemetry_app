import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/blood_pressure_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/heart_rate_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/overall_health_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/oxygen_saturation_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/shortness_of_breath_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/temperature_thresholds.dart';
import 'package:scalesoft_app/data/tables/users.dart';

class MeasurementThresholds extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get bloodPressure => text().map(BloodPressureThresholds.converter).nullable()();

  TextColumn get heartRate => text().map(HeartRateThresholds.converter).nullable()();

  TextColumn get overallHealth => text().map(OverallHealthThresholds.converter).nullable()();

  TextColumn get oxygenSaturation => text().map(OxygenSaturationThresholds.converter).nullable()();

  TextColumn get shortnessOfBreath => text().map(ShortnessOfBreathThresholds.converter).nullable()();

  TextColumn get temperature => text().map(TemperatureThresholds.converter).nullable()();

  IntColumn get userId => integer().references(Users, #id, onDelete: KeyAction.cascade).unique()();
}
