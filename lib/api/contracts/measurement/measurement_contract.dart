import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/device/source_device_contract.dart';
import 'package:scalesoft_app/api/contracts/device/source_device_with_metadata_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/blood_pressure_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/overall_health_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/shortness_of_breath_contract.dart';
import 'package:scalesoft_app/data/app_database.dart';

part 'measurement_contract.g.dart';

@JsonSerializable()
class MeasurementContract {
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
  final ShortnessOfBreathContract? shortnessOfBreath;
  final OverallHealthContract? overallHealth;
  final int? batteryPercentage;

  MeasurementContract({
    this.note,
    required this.sourceDeviceWithMetadata,
    required this.measurementDateTime,
    this.temperature,
    this.bloodPressure,
    this.heartRate,
    this.oxygenSaturation,
    this.respiratoryRate,
    required this.patientMuid,
    this.shortnessOfBreath,
    this.overallHealth,
    this.batteryPercentage,
  });

  factory MeasurementContract.fromJson(Map<String, dynamic> json) => _$MeasurementContractFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementContractToJson(this);

  @override
  String toString() => toJson().toString();

  factory MeasurementContract.fromEntity(
      String userMuid, Measurement entity, String deviceIdentifier, String modelName, String? deviceManufacturer) {
    final bloodPressure = entity.bloodPressure?.diastolic == null || entity.bloodPressure?.systolic == null
        ? null
        : BloodPressureContract(systolic: entity.bloodPressure!.systolic!, diastolic: entity.bloodPressure!.diastolic!);
    final shortnessOfBreath =
        ShortnessOfBreathContract.values.firstWhereOrNull((x) => x.name == entity.shortnessOfBreath?.name);
    final overallHealth = OverallHealthContract.values.firstWhereOrNull((x) => x.name == entity.overallHealth?.name);

    final device = SourceDeviceWithMetadataContract(
        sourceDevice: SourceDeviceContract(
            deviceIdentifier: deviceIdentifier, modelName: modelName, deviceManufacturer: deviceManufacturer));

    return MeasurementContract(
      sourceDeviceWithMetadata: device,
      measurementDateTime: entity.measuredAt.toUtc(),
      temperature: entity.temperature,
      bloodPressure: bloodPressure,
      heartRate: entity.heartRate,
      oxygenSaturation: entity.oxygenSaturation,
      respiratoryRate: entity.respiratoryRate,
      shortnessOfBreath: shortnessOfBreath,
      overallHealth: overallHealth,
      patientMuid: userMuid,
    );
  }
}
