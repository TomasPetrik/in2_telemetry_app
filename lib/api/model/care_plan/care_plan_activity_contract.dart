import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'care_plan_activity.freezed.dart';
part 'care_plan_activity.g.dart';
part 'care_plan_activity.hive.dart';

@freezed
class CarePlanActivityContract with _$CarePlanActivityContract {
  @HiveType(typeId: 11, adapterName: 'CarePlanActivityAdapter')
  const factory CarePlanActivityContract(
    @HiveField(0) ActivityTypeContract activityType,
    @HiveField(1) MeasurementTypeContract measurementType,
    @HiveField(2) int? goalValue,
  ) = _CarePlanActivity;

  factory CarePlanActivityContract.fromJson(Map<String, dynamic> json) =>
      _$CarePlanActivityContractFromJson(json);

  @override
  String toString() => toJson().toString();
}

@HiveType(typeId: 12)
enum ActivityTypeContract {
  @JsonValue('Measurement')
  @HiveField(0)
  measurement,
  @JsonValue('Goal')
  @HiveField(1)
  goal;
}

@HiveType(typeId: 13)
enum MeasurementTypeContract {
  @JsonValue('Temperature')
  @HiveField(0)
  temperature('Temperature'),
  @JsonValue('BloodPressure')
  @HiveField(1)
  bloodPressure('BloodPressure'),
  @JsonValue('OxygenSaturation')
  @HiveField(2)
  oxygenSaturation('OxygenSaturation'),
  @JsonValue('Steps')
  @HiveField(3)
  steps('Steps'),
  @JsonValue('GlobalPosition')
  @HiveField(4)
  globalPosition('GlobalPosition'),
  @JsonValue('HeartRate')
  @HiveField(5)
  heartRate('HeartRate'),
  @JsonValue('Ews')
  @HiveField(6)
  ews('Ews'),
  @JsonValue('RespiratoryRate')
  @HiveField(7)
  respiratoryRate('RespiratoryRate');

  const MeasurementTypeContract(this.key);
  final String key;
}
