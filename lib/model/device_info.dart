import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_info.freezed.dart';

final Map<DeviceChar, Guid> deviceCharAddress = {
  DeviceChar.modelNumber: Guid('2A24'),
  DeviceChar.serialNumber: Guid('2A25'),
  DeviceChar.firmwareRevision: Guid('2A26'),
  DeviceChar.hardwareRevision: Guid('2A27'),
  DeviceChar.softwareRevision: Guid('2A28'),
  DeviceChar.manufacturerName: Guid('2A29'),
  DeviceChar.batteryLevel: Guid('2A19'),
};

enum DeviceChar {
  modelNumber,
  serialNumber,
  firmwareRevision,
  hardwareRevision,
  softwareRevision,
  manufacturerName,
  batteryLevel,
}

@unfreezed
class DeviceInfo with _$DeviceInfo {
  const DeviceInfo._();

  factory DeviceInfo({
    required String modelNumber, //0x2A24
    required String serialNumber, //0x2A25
    required String firmwareRevision, //0x2A26
    required String hardwareRevision, //0x2A27
    required String softwareRevision, //0x2A28
    required String manufacturerName, //0x2A29
    BluetoothDevice? device,
    AdvertisementData? advData,
  }) = _DeviceInfo;

  @override
  String toString() {
    return 'devId:\n${device?.remoteId.str}\n'
        'devName:\n${device?.platformName}\n\n'
        'localName:\n${advData?.advName}\n'
        'manufacturerData:\n${getManufacturerData(advData?.manufacturerData)}\n'
        'modelNumber:\n$modelNumber\n\n'
        'serialNumber:\n${serialNumber.isEmpty ? 'EMPTY' : serialNumber}\n'
        'firmwareRevision:\n$firmwareRevision\n'
        'hardwareRevision:\n$hardwareRevision\n'
        'softwareRevision:\n$softwareRevision\n'
        'manufacturerName:\n$manufacturerName\n';
  }

  String getManufacturerData(Map<int, List<int>>? manufacturerData) {
    String manData = '';
    if (manufacturerData == null) {
      return 'N/A';
    }
    for (final entry in manufacturerData.entries) {
      final charData = entry.value;
      manData += '$charData,\n';
    }
    return manData;
  }
}

@freezed
class BatteryInfo with _$BatteryInfo {
  const factory BatteryInfo({
    required int batteryLevel, //0x2A19
  }) = _BatteryInfo;
}
