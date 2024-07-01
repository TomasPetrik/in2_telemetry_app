import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/thresholds/blood_pressure_thresholds_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/heart_rate_thresholds_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/overall_health_thresholds_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/oxygen_saturation_thresholds_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/shortness_of_breath_thresholds_contract.dart';
import 'package:scalesoft_app/api/contracts/thresholds/temperature_thresholds_contract.dart';

part 'measurement_thresholds_contract.g.dart';

@JsonSerializable()
class MeasurementThresholdsContract {
  final BloodPressureThresholdsContract? bloodPressure;
  final HeartRateThresholdsContract? heartRate;
  final OxygenSaturationThresholdsContract? oxygenSaturation;
  final TemperatureThresholdsContract? temperature;
  final ShortnessOfBreathThresholdsContract? shortnessOfBreath;
  final OverallHealthThresholdsContract? overallHealth;

  MeasurementThresholdsContract({
    this.bloodPressure,
    this.heartRate,
    this.oxygenSaturation,
    this.temperature,
    this.shortnessOfBreath,
    this.overallHealth,
  });

  factory MeasurementThresholdsContract.fromJson(Map<String, dynamic> json) =>
      _$MeasurementThresholdsContractFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementThresholdsContractToJson(this);

  @override
  String toString() => toJson().toString();
}
