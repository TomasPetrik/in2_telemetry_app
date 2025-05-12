import 'package:json_annotation/json_annotation.dart';

enum MeasurementType {
  @JsonValue('Temperature')
  temperature(),
  @JsonValue('BloodPressure')
  bloodPressure,
  @JsonValue('OxygenSaturation')
  oxygenSaturation,
  @JsonValue('Steps')
  steps,
  @JsonValue('GlobalPosition')
  globalPosition,
  @JsonValue('HeartRate')
  heartRate,
  @JsonValue('Ews')
  ews,
  @JsonValue('RespiratoryRate')
  respiratoryRate,
  @JsonValue('ShortnessOfBreath')
  shortnessOfBreath,
  @JsonValue('OverallHealth')
  overallHealth,
  @JsonValue('Battery')
  battery;
}
