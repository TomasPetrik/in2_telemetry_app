import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/api/dto/measurement/composed_int_value.dart';
import 'package:scalesoft_app/api/dto/measurement/source_device_info.dart';

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
    @JsonKey(ignore: true) @HiveField(9) MeasurementType? measurementType,
  }) = _ManualMeasurement;

  factory Measurement.fromJson(Map<String, dynamic> json) =>
      _$MeasurementFromJson(json);

  @override
  String toString() => toJson().toString();
}
