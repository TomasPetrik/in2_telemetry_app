import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/dto/measurement/composed_double_value.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';

part 'measurement.freezed.dart';
part 'measurement.g.dart';

@freezed
class Measurement with _$Measurement {
  const Measurement._();

  @HiveType(typeId: 30, adapterName: 'MeasurementAdapter')
  const factory Measurement({
    @HiveField(0) required DateTime measurementDateTime,
    @HiveField(1) double? value,
    @HiveField(2) required ComposedDoubleValue composedValue,
    @HiveField(3) required Device device,
    @HiveField(4) required bool isVerified,
  }) = _Measurement;
}
