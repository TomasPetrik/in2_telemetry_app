import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalesoft_app/data/entities/enums/device_model_type.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/providers/device_prototype_db_provider.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/device_prototype_model.dart';
import 'package:scalesoft_app/utils/extensions/uint8_list_extension.dart';

final Guid deviceInfo = Guid('0000180a-0000-1000-8000-00805f9b34fb');
final Guid recordAccessCpServiceUuid =
    Guid('5df5e817-a945-4f81-89c0-3d4e9759c07c');
final Guid batteryService = Guid('0000180f-0000-1000-8000-00805f9b34fb');

var measurementTypeToServiceUUid = {
  MeasurementType.bloodPressure: Guid('1810'),
  MeasurementType.heartRate: Guid('180d'),
  MeasurementType.temperature: Guid('1809'),
  MeasurementType.oxygenSaturation: Guid('FF12')
};

@singleton
class BtConnectionHelper {
  bool syncMode = false;
  final DevicePrototypeDbProvider _devicePrototypeDbProvider;

  BtConnectionHelper(this._devicePrototypeDbProvider);

  Future<void> searchDevicesByService({
    required List<Guid> serviceUuids,
    required onlyPairingMode,
    required Function(List<DeviceCreateModel> devices) onResult,
    required int userId,
    required bool isPersonalDevice,
  }) async {
    syncMode = false;
    if (!FlutterBluePlus.isScanningNow) {
      FlutterBluePlus.startScan();
    }
    final supportedDevicePrototypes =
        await _devicePrototypeDbProvider.getByUser(userId);

    final supportedBtNames =
        supportedDevicePrototypes.map((x) => x.bluetoothName).toList();

    debugPrint(supportedBtNames.toString());

    final supportedBtPairingNames = supportedDevicePrototypes
        .map((x) => x.bluetoothPairingName)
        .nonNulls
        .toList();

    var scanResultStream = FlutterBluePlus.onScanResults.listenAndBuffer();

    late List<ScanResult> matchedResults;

    await scanResultStream.firstWhere((scanResult) {

      matchedResults = scanResult.where((scanResult) {
        return scanResult.advertisementData.serviceUuids.any(
              (uuid) => serviceUuids.any((x) => x == uuid),
            ) &&
            ((!onlyPairingMode &&
                    supportedBtNames.any((suppBtName) {
                      return scanResult.advertisementData.advName
                          .toLowerCase()
                          .contains(suppBtName.toLowerCase());
                    })) ||
                (onlyPairingMode &&
                    supportedBtPairingNames.any((suppBtPairName) {
                      return scanResult.advertisementData.advName
                          .contains(suppBtPairName);
                    })));
      }).toList();
      debugPrint('found matching devices ${matchedResults.length}');

      final availableDevices = matchedResults
          .where((x) => x.rssi < 0 && x.advertisementData.connectable)
          .map(
            (x) => _convertToModel(
              x.advertisementData.advName,
              x.device,
              supportedDevicePrototypes,
              isPersonalDevice,
            ),
          )
          .toList();

      onResult.call(availableDevices);
      return syncMode;
    });
  }

  DeviceCreateModel _convertToModel(
    String advertisementName,
    BluetoothDevice btDevice,
    List<DevicePrototypeModel> supportedPrototypes,
    bool isPersonalDevice,
  ) {
    final prototype = supportedPrototypes.firstWhere(
      (dev) {
        return advertisementName
            .toLowerCase()
            .contains(dev.bluetoothName.toLowerCase());
      },
    );

    var preferredIdName = advertisementName;

    if (prototype.deviceModelType.index == DeviceModelType.omronM7.index) {
      preferredIdName = advertisementName.split('_').last;
    }

    return DeviceCreateModel(
      preferredIdName,
      prototype,
      bluetoothAddress:
          Platform.isAndroid ? btDevice.remoteId.toString() : null,
    );
  }

  Future<DeviceInfo?> requestDeviceInfo(BluetoothDevice device) async {
    final services = await device.discoverServices();

    final deviceInfoService = services.firstWhereOrNull(
      (service) => service.serviceUuid == deviceInfo,
    );
    if (deviceInfoService != null) {
      final deviceInfo = await _getDeviceInfoFromService(deviceInfoService);
      deviceInfo.device = device;
      return deviceInfo;
    } else {
      return null;
    }
  }

  Future<BatteryInfo?> requestBatteryInfo(BluetoothDevice device) async {
    final services = await device.discoverServices();
    final batteryInfoService = services.firstWhereOrNull(
      (service) => service.serviceUuid == batteryService,
    );
    if (batteryInfoService != null) {
      final batteryInfo = await _getBatteryInfoFromService(batteryInfoService);
      return batteryInfo;
    } else {
      return null;
    }
  }

  Future<String> _readCharData(
    List<BluetoothCharacteristic> characteristics,
    DeviceChar characteristic,
  ) async {
    final address = deviceCharAddress.entries
        .firstWhere((entry) => entry.key == characteristic)
        .value;
    final specificChar = characteristics.firstWhereOrNull(
      (char) => char.characteristicUuid == address,
    );

    if (specificChar == null) {
      return '';
    }

    final List<int> charData = await specificChar.read();
    return String.fromCharCodes(charData);
  }

  Future<DeviceInfo> _getDeviceInfoFromService(
    BluetoothService service,
  ) async {
    final characteristics = service.characteristics;

    final modelNumber =
        await _readCharData(characteristics, DeviceChar.modelNumber);
    final serialNumber =
        await _readCharData(characteristics, DeviceChar.serialNumber);
    final firmwareRevision =
        await _readCharData(characteristics, DeviceChar.firmwareRevision);
    final hardwareRevision =
        await _readCharData(characteristics, DeviceChar.hardwareRevision);
    final softwareRevision =
        await _readCharData(characteristics, DeviceChar.softwareRevision);
    final manufacturerName =
        await _readCharData(characteristics, DeviceChar.manufacturerName);

    final DeviceInfo deviceInfo = DeviceInfo(
      modelNumber: modelNumber,
      serialNumber: serialNumber,
      firmwareRevision: firmwareRevision,
      hardwareRevision: hardwareRevision,
      softwareRevision: softwareRevision,
      manufacturerName: manufacturerName,
    );

    debugPrint('device info:\n${deviceInfo.toString()}');

    return deviceInfo;
  }

  Future<BatteryInfo?> _getBatteryInfoFromService(
    BluetoothService service,
  ) async {
    final characteristics = service.characteristics;

    final batteryLevelAddress = deviceCharAddress.entries
        .firstWhere((entry) => entry.key == DeviceChar.batteryLevel)
        .value;

    final batteryLevelChar = characteristics.firstWhereOrNull(
      (char) => char.characteristicUuid == batteryLevelAddress,
    );

    if (batteryLevelChar != null) {
      final List<int> charData = await batteryLevelChar.read();
      int batteryLevel = charData.toInt8(0, 1);

      final BatteryInfo batteryInfo = BatteryInfo(
        batteryLevel: batteryLevel,
      );

      debugPrint('battery info:\n${batteryInfo.toString()}');

      return batteryInfo;
    }
    return null;
  }

  Future<bool> isBTPermissionsPermanentlyDenied() async {
    if (!Platform.isAndroid) {
      return false;
    }

    final isBtScanStatusPermanentlyDenied =
        await Permission.bluetoothScan.status.isPermanentlyDenied;
    final isBtConnectStatusPermanentlyDenied =
        await Permission.bluetoothConnect.status.isPermanentlyDenied;

    return isBtScanStatusPermanentlyDenied ||
        isBtConnectStatusPermanentlyDenied;
  }

  Future<bool> isBTPermissionsGranted() async {
    if (!Platform.isAndroid) {
      return false;
    }

    final isBtScanStatusGranted =
        await Permission.bluetoothScan.status.isGranted;
    final isBtConnectStatusGranted =
        await Permission.bluetoothConnect.status.isGranted;

    return isBtScanStatusGranted && isBtConnectStatusGranted;
  }

  Future<bool> requestForBTPermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    Map<Permission, PermissionStatus> statuses = await [
      //Permission.bluetooth, // -> is handled by flutter blue plus
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    if (statuses.values.any((permission) => permission.isGranted == false)) {
      return false;
    }

    return true;
  }

  Future<bool> hasLocationServiceEnabled() async {
    if (!Platform.isAndroid) {
      return true;
    }

    //Check if localization service is enabled only for Android 11 and lower
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    if (androidInfo.version.sdkInt > 30) {
      return true;
    }

    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      return true;
    } else {
      return false;
    }
  }
}
