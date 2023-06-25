import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/model/measurement/measurement.dart';
import 'package:scalesoft_app/api/model/thresholds/blood_pressure_threshold_setting.dart';
import 'package:scalesoft_app/api/model/thresholds/heart_rate_threshold_setting.dart';
import 'package:scalesoft_app/api/model/thresholds/oxygen_saturation_threshold_setting.dart';
import 'package:scalesoft_app/api/model/thresholds/temperature_threshold_settings.dart';

part 'measurement_thresholds.freezed.dart';
part 'measurement_thresholds.g.dart';
part 'measurement_thresholds.hive.dart';

@freezed
class MeasurementThresholds with _$MeasurementThresholds {
  const MeasurementThresholds._();

  @HiveType(typeId: 47, adapterName: 'MeasurementThresholdsAdapter')
  factory MeasurementThresholds(
    @HiveField(1) BloodPressureThresholdSetting? bloodPressure,
    @HiveField(2) HeartRateThresholdSetting? heartRate,
    @HiveField(3) OxygenSaturationThresholdSetting? oxygenSaturation,
    @HiveField(4) TemperatureThresholdSetting? temperature,
  ) = _MeasurementThresholds;

  factory MeasurementThresholds.fromJson(Map<String, dynamic> json) =>
      _$MeasurementThresholdsFromJson(json);

  @override
  String toString() => toJson().toString();

  bool _exceededBloodPressure(int systolic, int diastolic) {
    if (bloodPressure == null) return false;
    return (bloodPressure?.systolicMin != null &&
            systolic < bloodPressure!.systolicMin!) ||
        (bloodPressure?.systolicMax != null &&
            systolic > bloodPressure!.systolicMax!) ||
        (bloodPressure?.diastolicMin != null &&
            diastolic < bloodPressure!.diastolicMin!) ||
        (bloodPressure?.diastolicMax != null &&
            diastolic > bloodPressure!.diastolicMax!);
  }

  bool _exceededHeartRate(int heartRateValue) {
    if (heartRate == null) return false;
    return (heartRate?.min != null && heartRateValue < heartRate!.min!) ||
        (heartRate?.max != null && heartRateValue > heartRate!.max!);
  }

  bool _exceededOxygenSaturation(int oxygenSaturationValue) {
    if (oxygenSaturation == null) return false;
    return (oxygenSaturation?.percentageMin != null &&
            oxygenSaturationValue < oxygenSaturation!.percentageMin!) ||
        (oxygenSaturation?.percentageMax != null &&
            oxygenSaturationValue > oxygenSaturation!.percentageMax!);
  }

  bool _exceededTemperature(double temperatureValue) {
    if (temperature == null) return false;
    return (temperature?.min != null && temperatureValue < temperature!.min!) ||
        (temperature?.max != null && temperatureValue > temperature!.max!);
  }

  bool exceededValues(Measurement measurement) {
    final measurementType = measurement.measurementType!;
    switch (measurementType) {
      case MeasurementType.bloodPressure:
        return _exceededBloodPressure(
          measurement.bloodPressure!.systolic!,
          measurement.bloodPressure!.diastolic!,
        );

      case MeasurementType.heartRate:
        return _exceededHeartRate(
          measurement.heartRate!,
        );

      case MeasurementType.oxygenSaturation:
        return _exceededOxygenSaturation(
          measurement.oxygenSaturation!,
        );

      case MeasurementType.temperature:
        return _exceededTemperature(
          measurement.temperature!,
        );

      default:
        return false;
    }
  }
}
