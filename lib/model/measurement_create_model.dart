import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/enums/overall_health_state.dart';
import 'package:scalesoft_app/data/entities/enums/shortness_of_breath_level.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement/blood_pressure_value.dart';

class MeasurementCreateModel {
  int userId;
  int? deviceId;
  DateTime measuredAt;
  MeasurementType measurementType;
  double? temperature;
  BloodPressureValue? bloodPressure;
  int? heartRate;
  int? oxygenSaturation;
  int? respiratoryRate;
  ShortnessOfBreathLevel? shortnessOfBreath;
  OverallHealthState? overallHealth;
  int? batteryPercentage;

  MeasurementCreateModel(
    this.userId,
    this.measuredAt,
    this.measurementType, {
    this.deviceId,
    this.temperature,
    this.bloodPressure,
    this.heartRate,
    this.oxygenSaturation,
    this.respiratoryRate,
    this.shortnessOfBreath,
    this.overallHealth,
    this.batteryPercentage,
  });
}
