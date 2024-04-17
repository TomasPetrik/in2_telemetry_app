import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/measurement_type_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/overall_health_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/shortness_of_breath_contract.dart';
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

  bool _exceededBloodPressure(int systolic, int diastolic) {
    if (bloodPressure == null) return false;
    return (bloodPressure?.systolicMin != null && systolic < bloodPressure!.systolicMin!) ||
        (bloodPressure?.systolicMax != null && systolic > bloodPressure!.systolicMax!) ||
        (bloodPressure?.diastolicMin != null && diastolic < bloodPressure!.diastolicMin!) ||
        (bloodPressure?.diastolicMax != null && diastolic > bloodPressure!.diastolicMax!);
  }

  bool _exceededHeartRate(int heartRateValue) {
    if (heartRate == null) return false;
    return (heartRate?.min != null && heartRateValue < heartRate!.min!) ||
        (heartRate?.max != null && heartRateValue > heartRate!.max!);
  }

  bool _exceededOxygenSaturation(int oxygenSaturationValue) {
    if (oxygenSaturation == null) return false;
    return (oxygenSaturation?.percentageMin != null && oxygenSaturationValue < oxygenSaturation!.percentageMin!) ||
        (oxygenSaturation?.percentageMax != null && oxygenSaturationValue > oxygenSaturation!.percentageMax!);
  }

  bool _exceededTemperature(double temperatureValue) {
    if (temperature == null) return false;
    return (temperature?.min != null && temperatureValue < temperature!.min!) ||
        (temperature?.max != null && temperatureValue > temperature!.max!);
  }

  bool _exceededShortnessOfBreath(ShortnessOfBreathContract? value) {
    if (value == null) {
      return false;
    }

    return shortnessOfBreath?.max != null && value.index > shortnessOfBreath!.max!.index;
  }

  bool _exceededOverallHealth(OverallHealthContract? value) {
    if (value == null) {
      return false;
    }

    return overallHealth?.max != null && value.index > overallHealth!.max!.index;
  }

  bool exceededValues(MeasurementContract measurement) {
    final measurementType = measurement.measurementType;
    switch (measurementType) {
      case MeasurementTypeContract.bloodPressure:
        return _exceededBloodPressure(
          measurement.bloodPressure!.systolic,
          measurement.bloodPressure!.diastolic,
        );

      case MeasurementTypeContract.heartRate:
        return _exceededHeartRate(measurement.heartRate!);

      case MeasurementTypeContract.oxygenSaturation:
        return _exceededOxygenSaturation(measurement.oxygenSaturation!);

      case MeasurementTypeContract.temperature:
        return _exceededTemperature(measurement.temperature!);

      case MeasurementTypeContract.shortnessOfBreath:
        return _exceededShortnessOfBreath(measurement.shortnessOfBreath!);

      case MeasurementTypeContract.overallHealth:
        return _exceededOverallHealth(measurement.overallHealth!);

      default:
        return false;
    }
  }
}
