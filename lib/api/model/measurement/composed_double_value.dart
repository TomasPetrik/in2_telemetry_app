import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'composed_double_value.freezed.dart';
part 'composed_double_value.g.dart';
part 'composed_double_value.hive.dart';

@freezed
class ComposedDoubleValue with _$ComposedDoubleValue {
  const ComposedDoubleValue._();

  @HiveType(typeId: 31, adapterName: 'ComposedDoubleValueAdapter')
  factory ComposedDoubleValue({
    @HiveField(0) double? firstValue,
    @HiveField(1) double? secondValue,
  }) = _ComposedDoubleValue;

  factory ComposedDoubleValue.fromJson(Map<String, dynamic> json) =>
      _$ComposedDoubleValueFromJson(json);

  @override
  String toString() => toJson().toString();
}
