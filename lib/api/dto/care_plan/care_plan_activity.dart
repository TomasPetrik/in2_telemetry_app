import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'care_plan_activity.freezed.dart';
part 'care_plan_activity.g.dart';

@freezed
class CarePlanActivity with _$CarePlanActivity {
  @HiveType(typeId: 11, adapterName: 'CarePlanActivityAdapter')
  factory CarePlanActivity(
    @HiveField(0) ActivityType activityType,
    @HiveField(1) MeasurementType measurementType,
    @HiveField(2) int? goalValue,
  ) = _CarePlanActivity;

  factory CarePlanActivity.fromJson(Map<String, dynamic> json) =>
      _$CarePlanActivityFromJson(json);

  @override
  String toString() => toJson().toString();
}

@HiveType(typeId: 12)
enum ActivityType {
  @JsonValue('Measurement')
  @HiveField(0)
  measurement,
  @JsonValue('Goal')
  @HiveField(1)
  goal;
}

@HiveType(typeId: 13)
enum MeasurementType {
  @JsonValue('Temperature')
  @HiveField(0)
  temperature,
  @JsonValue('BloodPressure')
  @HiveField(1)
  bloodPressure,
  @JsonValue('OxygenSaturation')
  @HiveField(2)
  oxygenSaturation,
  @JsonValue('Steps')
  @HiveField(3)
  steps,
  @JsonValue('GlobalPosition')
  @HiveField(4)
  globalPosition,
  @JsonValue('HeartRate')
  @HiveField(5)
  heartRate,
  @JsonValue('Ews')
  @HiveField(6)
  ews,
  @JsonValue('RespiratoryRate')
  @HiveField(7)
  respiratoryRate;
}
