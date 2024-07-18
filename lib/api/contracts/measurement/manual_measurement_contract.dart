import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scalesoft_app/api/contracts/measurement/blood_pressure_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/overall_health_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/shortness_of_breath_contract.dart';
import 'package:scalesoft_app/data/app_database.dart';

part 'manual_measurement_contract.g.dart';

@JsonSerializable()
class ManualMeasurementContract {
  final String? note;
  final DateTime measurementDateTime;
  final double? temperature;
  final BloodPressureContract? bloodPressure;
  final int? heartRate;
  final int? oxygenSaturation;
  final int? respiratoryRate;
  final String patientMuid;
  final ShortnessOfBreathContract? shortnessOfBreath;
  final OverallHealthContract? overallHealth;

  ManualMeasurementContract({
    this.note,
    required this.measurementDateTime,
    this.temperature,
    this.bloodPressure,
    this.heartRate,
    this.oxygenSaturation,
    this.respiratoryRate,
    required this.patientMuid,
    this.shortnessOfBreath,
    this.overallHealth,
  });

  factory ManualMeasurementContract.fromJson(Map<String, dynamic> json) => _$ManualMeasurementContractFromJson(json);

  Map<String, dynamic> toJson() => _$ManualMeasurementContractToJson(this);

  @override
  String toString() => toJson().toString();

  factory ManualMeasurementContract.fromEntity(String userMuid, Measurement entity) {
    final bloodPressure = entity.bloodPressure?.diastolic == null || entity.bloodPressure?.systolic == null
        ? null
        : BloodPressureContract(systolic: entity.bloodPressure!.systolic!, diastolic: entity.bloodPressure!.diastolic!);
    final shortnessOfBreath =
        ShortnessOfBreathContract.values.firstWhereOrNull((x) => x.name == entity.shortnessOfBreath?.name);
    final overallHealth = OverallHealthContract.values.firstWhereOrNull((x) => x.name == entity.overallHealth?.name);

    return ManualMeasurementContract(
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
