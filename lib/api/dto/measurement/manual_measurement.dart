import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/dto/measurement/composed_int_value.dart';

part 'manual_measurement.freezed.dart';
part 'manual_measurement.g.dart';

@freezed
class ManualMeasurement with _$ManualMeasurement {
  const ManualMeasurement._();

  @HiveType(typeId: 34, adapterName: 'ManualMeasurementAdapter')
  const factory ManualMeasurement({
    @HiveField(0) String? note,
    @HiveField(1) DateTime? measurementDateTime,
    @HiveField(2) double? temperature,
    @HiveField(3) ComposedIntValue? bloodPressure,
    @HiveField(4) int? heartRate,
    @HiveField(5) int? oxygenSaturation,
    @HiveField(6) int? respiratoryRate,
    @HiveField(7) String? patientMuid,
  }) = _ManualMeasurement;
}
