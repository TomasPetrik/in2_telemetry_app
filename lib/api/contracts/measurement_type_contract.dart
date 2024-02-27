import 'package:json_annotation/json_annotation.dart';

enum MeasurementTypeContract {
  @JsonValue('Temperature')
  temperature('Temperature'),
  @JsonValue('BloodPressure')
  bloodPressure('BloodPressure'),
  @JsonValue('OxygenSaturation')
  oxygenSaturation('OxygenSaturation'),
  @JsonValue('Steps')
  steps('Steps'),
  @JsonValue('GlobalPosition')
  globalPosition('GlobalPosition'),
  @JsonValue('HeartRate')
  heartRate('HeartRate'),
  @JsonValue('Ews')
  ews('Ews'),
  @JsonValue('RespiratoryRate')
  respiratoryRate('RespiratoryRate'),
  @JsonValue('ShortnessOfBreath')
  shortnessOfBreath('ShortnessOfBreath'),
  @JsonValue('OverallHealth')
  overallHealth('OverallHealth'),
  battery('Battery');

  const MeasurementTypeContract(this.key);
  final String key;
}