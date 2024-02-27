import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/measurement_type_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/blood_pressure_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/overall_health_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/shortness_of_breath_contract.dart';
import 'package:scalesoft_app/api/contracts/device/source_device_with_metadata_contract.dart';
import 'package:scalesoft_app/service_locator/get_it.dart';

part 'measurement.g.dart';

@JsonSerializable()
class Measurement {
  final String? note;
  final SourceDeviceWithMetadataContract sourceDeviceWithMetadata;
  final DateTime measurementDateTime;
  final double? temperature;
  final BloodPressureContract? bloodPressure;
  final int? heartRate;
  final int? oxygenSaturation;
  final int? respiratoryRate;
  final String patientMuid;
  @JsonKey(includeToJson: false)
  final MeasurementTypeContract measurementType;
  final ShortnessOfBreathContract? shortnessOfBreath;
  final OverallHealthContract? overallHealth;
  final int? batteryPercentage;

  Measurement({
    this.note,
    required this.sourceDeviceWithMetadata,
    required this.measurementDateTime,
    this.temperature,
    this.bloodPressure,
    this.heartRate,
    this.oxygenSaturation,
    this.respiratoryRate,
    required this.patientMuid,
    required this.measurementType,
    this.shortnessOfBreath,
    this.overallHealth,
    this.batteryPercentage,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) =>
      _$MeasurementFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementToJson(this);

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
