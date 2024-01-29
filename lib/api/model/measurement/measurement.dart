import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity_contract.dart';
import 'package:scalesoft_app/api/model/measurement/composed_int_value.dart';
import 'package:scalesoft_app/api/model/measurement/overall_health_value.dart';
import 'package:scalesoft_app/api/model/measurement/shortness_of_breath_value.dart';
import 'package:scalesoft_app/api/model/measurement/source_device_info.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';

part 'measurement.freezed.dart';
part 'measurement.g.dart';

@freezed
class Measurement with _$Measurement {
  const Measurement._();

  @HiveType(typeId: 35, adapterName: 'MeasurementAdapter')
  const factory Measurement({
    @HiveField(0) String? note,
    @HiveField(1) SourceDeviceInfo? sourceDeviceWithMetadata,
    @HiveField(2) DateTime? measurementDateTime,
    @HiveField(3) double? temperature,
    @HiveField(4) BloodPressureValue? bloodPressure,
    @HiveField(5) int? heartRate,
    @HiveField(6) int? oxygenSaturation,
    @HiveField(7) int? respiratoryRate,
    @HiveField(8) String? patientMuid,
    @JsonKey(includeToJson: false)
    @HiveField(9)
    required MeasurementTypeContract measurementType,
    @HiveField(10) ShortnessOfBreathValue? shortnessOfBreath,
    @HiveField(11) OverallHealthValue? overallHealth,
    @HiveField(12) int? batteryPercentage,
  }) = _Measurement;

  factory Measurement.fromJson(Map<String, dynamic> json) =>
      _$MeasurementFromJson(json);

  @override
  String toString() => toJson().toString();

  String getFormattedValue() {
    final value = switch (measurementType) {
      MeasurementTypeContract.temperature => temperature.toString(),
      MeasurementTypeContract.bloodPressure =>
        "${bloodPressure?.systolic ?? 'N/A'}/${bloodPressure?.diastolic ?? 'N/A'}",
      MeasurementTypeContract.oxygenSaturation => oxygenSaturation.toString(),
      MeasurementTypeContract.heartRate => heartRate.toString(),
      MeasurementTypeContract.respiratoryRate => respiratoryRate.toString(),
      MeasurementTypeContract.shortnessOfBreath => shortnessOfBreath != null
          ? localization.shortness_of_breath_values(shortnessOfBreath!)
          : "",
      MeasurementTypeContract.overallHealth => overallHealth != null
          ? localization.overall_health_values(overallHealth!)
          : "",
      MeasurementTypeContract.ews ||
      MeasurementTypeContract.steps ||
      MeasurementTypeContract.globalPosition ||
      MeasurementTypeContract.battery =>
        "",
    };

    return "$value ${localization.common_measurement_units_types(measurementType)}";
  }
}
