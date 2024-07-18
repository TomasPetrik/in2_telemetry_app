import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/enums/overall_health_state.dart';
import 'package:scalesoft_app/data/entities/enums/shortness_of_breath_level.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement/blood_pressure_value.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';

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

  String getFormattedValue() {
    final value = switch (measurementType) {
      MeasurementType.temperature => temperature.toString(),
      MeasurementType.bloodPressure => "${bloodPressure?.systolic ?? 'N/A'}/${bloodPressure?.diastolic ?? 'N/A'}",
      MeasurementType.oxygenSaturation => oxygenSaturation.toString(),
      MeasurementType.heartRate => heartRate.toString(),
      MeasurementType.respiratoryRate => respiratoryRate.toString(),
      MeasurementType.shortnessOfBreath =>
        shortnessOfBreath != null ? localization.shortness_of_breath_values(shortnessOfBreath!) : "",
      MeasurementType.overallHealth => overallHealth != null ? localization.overall_health_values(overallHealth!) : "",
      MeasurementType.ews || MeasurementType.steps || MeasurementType.globalPosition || MeasurementType.battery => "",
    };

    return "$value ${localization.common_measurement_units_types(measurementType)}";
  }
}
