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
    @JsonKey(ignore: true) @HiveField(4) DeviceModel? deviceModel,
    @JsonKey(ignore: true)
    @HiveField(5)
        List<MeasurementType>? supportedMeasurementTypes,
    @JsonKey(ignore: true) @HiveField(6) String? imagePath,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  @override
  String toString() => toJson().toString();
}

@HiveType(typeId: 34)
enum DeviceModel {
  @HiveField(0)
  beurerBm77,
  @HiveField(1)
  omronM7,
}
