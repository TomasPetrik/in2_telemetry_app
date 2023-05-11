import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';

part 'source_device_info.freezed.dart';
part 'source_device_info.g.dart';
part 'source_device_info.hive.dart';

@freezed
class SourceDeviceInfo with _$SourceDeviceInfo {
  const SourceDeviceInfo._();

  @HiveType(typeId: 36, adapterName: 'SourceDeviceInfoAdapter')
  const factory SourceDeviceInfo({
    @HiveField(0) Device? sourceDevice,
    @HiveField(1) int? batteryPercentage,
  }) = _SourceDeviceInfo;

  factory SourceDeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$SourceDeviceInfoFromJson(json);

  @override
  String toString() => toJson().toString();
}
