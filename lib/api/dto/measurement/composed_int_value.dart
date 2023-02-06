import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'composed_int_value.freezed.dart';
part 'composed_int_value.g.dart';

@freezed
class ComposedIntValue with _$ComposedIntValue {
  const ComposedIntValue._();

  @HiveType(typeId: 32, adapterName: 'ComposedIntValueAdapter')
  const factory ComposedIntValue({
    @HiveField(0) int? firstValue,
    @HiveField(1) int? secondValue,
  }) = _ComposedIntValue;

  factory ComposedIntValue.fromJson(Map<String, dynamic> json) =>
      _$ComposedIntValueFromJson(json);

  @override
  String toString() => toJson().toString();
}
