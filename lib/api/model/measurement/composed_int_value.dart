import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'composed_int_value.freezed.dart';
part 'composed_int_value.g.dart';
part 'composed_int_value.hive.dart';

@freezed
class BloodPressureValue with _$BloodPressureValue {
  const BloodPressureValue._();

  @HiveType(typeId: 32, adapterName: 'BloodPressureValueAdapter')
  factory BloodPressureValue({
    @HiveField(0) int? systolic,
    @HiveField(1) int? diastolic,
  }) = _ComposedIntValue;

  factory BloodPressureValue.fromJson(Map<String, dynamic> json) =>
      _$BloodPressureValueFromJson(json);

  @override
  String toString() => toJson().toString();
}
