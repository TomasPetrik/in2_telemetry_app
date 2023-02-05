import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'composed_double_value.freezed.dart';
part 'composed_double_value.g.dart';

@freezed
class ComposedDoubleValue with _$ComposedDoubleValue {
  const ComposedDoubleValue._();

  @HiveType(typeId: 31, adapterName: 'ComposedDoubleValueAdapter')
  const factory ComposedDoubleValue({
    @HiveField(0) double? firstValue,
    @HiveField(1) double? secondValue,
  }) = _ComposedDoubleValue;
}
