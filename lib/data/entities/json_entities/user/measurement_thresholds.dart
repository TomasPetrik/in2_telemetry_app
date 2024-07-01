import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/blood_pressure_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/heart_rate_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/overall_health_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/oxygen_saturation_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/shortness_of_breath_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/temperature_thresholds.dart';
import 'package:scalesoft_app/model/measurement_create_model.dart';

part 'measurement_thresholds.g.dart';

@JsonSerializable()
class MeasurementThresholds {
  final BloodPressureThresholds? bloodPressure;
  final HeartRateThresholds? heartRate;
  final OxygenSaturationThresholds? oxygenSaturation;
  final TemperatureThresholds? temperature;
  final ShortnessOfBreathThresholds? shortnessOfBreath;
  final OverallHealthThresholds? overallHealth;

  MeasurementThresholds(
    this.bloodPressure,
    this.heartRate,
    this.oxygenSaturation,
    this.temperature,
    this.shortnessOfBreath,
    this.overallHealth,
  );

  factory MeasurementThresholds.fromJson(Map<String, dynamic> json) => _$MeasurementThresholdsFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementThresholdsToJson(this);

  static TypeConverter<MeasurementThresholds, String> converter = TypeConverter.json(
    fromJson: (json) => MeasurementThresholds.fromJson(json as Map<String, Object?>),
    toJson: (obj) => obj.toJson(),
  );

  bool exceededLimits(MeasurementCreateModel? model) {
    if (model == null) {
      return false;
    }

    final measurementType = model.measurementType;
    switch (measurementType) {
      case MeasurementType.bloodPressure:
        return bloodPressure?.exceeds(model.bloodPressure?.systolic, model.bloodPressure?.diastolic) ?? false;

      case MeasurementType.heartRate:
        return heartRate?.exceeds(model.heartRate) ?? false;

      case MeasurementType.oxygenSaturation:
        return oxygenSaturation?.exceeds(model.oxygenSaturation) ?? false;

      case MeasurementType.temperature:
        return temperature?.exceeds(model.temperature) ?? false;

      case MeasurementType.shortnessOfBreath:
        return shortnessOfBreath?.exceeds(model.shortnessOfBreath) ?? false;

      case MeasurementType.overallHealth:
        return overallHealth?.exceeds(model.overallHealth) ?? false;

      default:
        return false;
    }
  }
}
