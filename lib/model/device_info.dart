import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_info.freezed.dart';
part 'device_info.g.dart';

const Map<DeviceChar, String> deviceCharAddress = {
  DeviceChar.modelNumber: '2A24',
  DeviceChar.serialNumber: '2A25',
  DeviceChar.firmwareRevision: '2A26',
  DeviceChar.hardwareRevision: '2A27',
  DeviceChar.softwareRevision: '2A28',
  DeviceChar.manufacturerName: '2A29',
};

enum DeviceChar {
  modelNumber,
  serialNumber,
  firmwareRevision,
  hardwareRevision,
  softwareRevision,
  manufacturerName,
}

@freezed
class DeviceInfo with _$DeviceInfo {
  const factory DeviceInfo({
    required String modelNumber, //0x2A24
    required String serialNumber, //0x2A25
    required String firmwareRevision, //0x2A26
    required String hardwareRevision, //0x2A27
    required String softwareRevision, //0x2A28
    required String manufacturerName, //0x2A29
  }) = _BloodPressureInfo;

  factory DeviceInfo.fromJson(Map<String, Object?> json) => _$DeviceInfoFromJson(json);
}
