import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/dto/care_plan/care_plan_activity.dart';

part 'device.freezed.dart';
part 'device.g.dart';

@freezed
class Device with _$Device {
  const Device._();

  @HiveType(typeId: 33, adapterName: 'DeviceAdapter')
  const factory Device({
    @HiveField(0) String? deviceIdentifier,
    @HiveField(1) String? modelName,
    @HiveField(2) String? deviceManufacturer,
    @HiveField(4) @JsonKey(ignore: true) required DeviceModel deviceModel,
    @HiveField(5)
    @JsonKey(ignore: true)
        required List<MeasurementType> supportedMeasurementTypes,
    @HiveField(6) @JsonKey(ignore: true) required String imagePath,
  }) = _Device;
}

@HiveType(typeId: 33)
enum DeviceModel {
  @HiveField(0)
  beurerBm77,
  @HiveField(1)
  omronM7,
}
