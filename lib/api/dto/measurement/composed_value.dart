import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'composed_value.freezed.dart';
part 'composed_value.g.dart';

@freezed
class ComposedValue with _$ComposedValue {
  const ComposedValue._();

  @HiveType(typeId: 31, adapterName: 'ComposedValueAdapter')
  const factory ComposedValue({
    @HiveField(0) double? firstValue,
    @HiveField(1) double? secondValue,
  }) = _ComposedValue;
}
