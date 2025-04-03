import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalesoft_app/constants/configuration_constants.dart';
import 'package:scalesoft_app/data/entities/enums/device_model_type.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/providers/device_prototype_db_provider.dart';
import 'package:scalesoft_app/utils/extensions/uint8_list_extension.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/device_prototype_model.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/measurement_info.dart';

final Guid deviceInfo = Guid('0000180a-0000-1000-8000-00805f9b34fb');
final Guid recordAccessCpServiceUuid =
    Guid('5df5e817-a945-4f81-89c0-3d4e9759c07c');
final Guid batteryService = Guid('0000180f-0000-1000-8000-00805f9b34fb');
final Guid bloodPressureServiceUuid = Guid('1810');
final Guid heartRateServiceUuid = Guid('180d');
final Guid temperatureServiceUuid = Guid('1809');

enum SearchMode { pairing, syncing }

var measurementTypeToUUid = {
  MeasurementType.bloodPressure : Guid('1810'),
  MeasurementType.heartRate : Guid('180d'),
  MeasurementType.temperature : Guid('1809'),
};

@singleton
class BtConnectionHelper {
  bool syncMode = false;
  final DevicePrototypeDbProvider _devicePrototypeDbProvider;


  BtConnectionHelper(this._devicePrototypeDbProvider);

  bool _matchDeviceMode(
    String localName,
    device,
    SearchMode searchMode,
  ) {
    final supportedBtNames = ConfigurationConstants.supportedDevices
        .map((supDev) => supDev.bluetoothName)
        .toList();

    final supportedBtPairingNames = ConfigurationConstants.supportedDevices
        .map((supDev) => supDev.bluetoothPairingName ?? '')
        .toList();

    if ((searchMode == SearchMode.pairing &&
            supportedBtPairingNames.any((suppBtPairName) {
              return localName.contains(suppBtPairName);
            })) ||
        (searchMode == SearchMode.syncing &&
            supportedBtNames.any((suppBtName) {
              return localName.contains(suppBtName);
            }))) {
      return true;
    } else {
      debugPrint(
        '$localName is not in ${searchMode.name} mode',
      );
      return false;
    }
  }

  bool _matchDeviceId(DeviceCreateModel device, String localName) {
    final supportedDev = ConfigurationConstants.supportedDevices.firstWhere(
      (dev) {
        return localName
            .toLowerCase()
            .contains(dev.bluetoothName.toLowerCase());
      },
    );

    var deviceId = device.deviceIdentifier;
    var searchDevId = localName;

    if (supportedDev.deviceModelType == DeviceModelType.omronM7) {
      searchDevId = searchDevId.split('_').last;
      deviceId = deviceId.split('_').last;
    }

    if (deviceId == searchDevId) {
      debugPrint('$localName is matching ID $deviceId');
      return true;
    } else {
      debugPrint('$localName NOT matching ID $deviceId');
      return false;
    }
  }

  Future<BluetoothDevice?> searchDevice({
    required Guid serviceUuid,
    required DeviceCreateModel device,
    required SearchMode searchMode,
    Duration? maxAllowedDeviceSearchingTime,
  }) async {
    syncMode = true;
    final isScanning = FlutterBluePlus.isScanningNow;
    if (!isScanning) {
      FlutterBluePlus.startScan();
    }

    final connectedDevices = await FlutterBluePlus.systemDevices;

    for (final connectedDevice in connectedDevices) {
      debugPrint('disconnecting from ${connectedDevice.platformName}');
      await connectedDevice.disconnect();
    }

    final startSearchAt = DateTime.now();

    while (true) {
      if (maxAllowedDeviceSearchingTime != null &&
          DateTime.now()
              .subtract(maxAllowedDeviceSearchingTime)
              .isAfter(startSearchAt)) {
        await FlutterBluePlus.stopScan();
        return null;
      }
      await Future.delayed(const Duration(seconds: 1));
      final availableDevices = await FlutterBluePlus.onScanResults.first;

      debugPrint('found all ${availableDevices.length} devices');

      for (final scanResult in availableDevices) {
        final serviceUuids = scanResult.advertisementData.serviceUuids;
        final services = scanResult.device.servicesList;
        if ((serviceUuids.any(
                (btServiceUuid) => btServiceUuid == serviceUuid) ||
                services.any(
                  (btService) => btService.serviceUuid == serviceUuid,
                )) &&
            _matchDeviceMode(
              scanResult.device.advName,
              device,
              searchMode,
            ) &&
            _matchDeviceId(
              device,
              scanResult.device.advName,
            )) {
          debugPrint('found device');

          await FlutterBluePlus.stopScan();

          return scanResult.device;
        }
      }

      if (syncMode = false || FlutterBluePlus.isScanningNow == false) {
        return null;
      }
    }
  }

  /// Finds devices that support at least one of the services in [serviceUuids].
  Future<void> searchDevicesByService({
    required List<Guid> serviceUuids,
    required onlyPairingMode,
    required Function(List<DeviceCreateModel> devices) onResult,
    required int userId,
    required bool isPersonalDevice,
  }) async {
    syncMode = false;
    final isScanning = FlutterBluePlus.isScanningNow;
    if (!isScanning) {
      FlutterBluePlus.startScan();
    }
    final supportedDevicePrototypes =
        await _devicePrototypeDbProvider.getByUser(userId);

    final supportedBtNames =
        supportedDevicePrototypes.map((x) => x.bluetoothName).toList();

    final supportedBtPairingNames = supportedDevicePrototypes
        .map((x) => x.bluetoothPairingName)
        .whereNotNull()
        .toList();

    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final allDevices = await FlutterBluePlus.onScanResults.first;

      debugPrint('found all ${allDevices.length} devices');

      final matchedResults = allDevices.where((scanResult) {
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

      debugPrint('available devices ${matchedResults.length}');

      onResult.call(availableDevices);

      if (syncMode || FlutterBluePlus.isScanningNow == false) {
        break;
      }
    }
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
    List<BluetoothService> services = [];

    await Future.delayed(const Duration(milliseconds: 100));
    services = await device.discoverServices().timeout(
          const Duration(seconds: 3),
          onTimeout: () => <BluetoothService>[],
        );

    debugPrint('found services ${services.length}');
    await Future.delayed(const Duration(milliseconds: 100));
    services = await device.discoverServices().timeout(
          const Duration(seconds: 3),
          onTimeout: () => <BluetoothService>[],
        );

    debugPrint('found services2 ${services.length}');

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

  Future<HwMeasurementResult> _getHwMeasurementResult({
    required BluetoothDevice device,
    required BluetoothCharacteristic bpCharacteristic,
    required BluetoothCharacteristic recordAccessCpCharacteristic,
    required bool isPairing,
    bool? isSecondAttempt,
  }) async {
    final dtNow = DateTime.now().toUtc();

    var bpData = await _getBPDataFromService(
      device,
      bpCharacteristic,
      recordAccessCpCharacteristic,
      isPairing,
      isSecondAttempt,
    );

    if (bpData == null) {
      return HwMeasurementResult(
        resultState: ResultState.connectionError,
        measurementDt: dtNow,
      );
    } else if (bpData.isEmpty) {
      return HwMeasurementResult(
        resultState: isPairing ? ResultState.success : ResultState.noData,
        measurementDt: dtNow,
      );
    } else {
      final measurementInfo = MeasurementInfo.fromIntList(bpData);
      return HwMeasurementResult(
        resultState: ResultState.success,
        measurementInfo: measurementInfo,
        measurementDt: dtNow,
      );
    }
  }

  Future<HwMeasurementResult> requestBPData(
    BluetoothDevice device,
    bool isMeasurement,
  ) async {
    final services = await device.discoverServices();
    final bpCharacteristic = services
        .firstWhereOrNull(
          (service) => service.serviceUuid == bloodPressureServiceUuid,
        )
        ?.characteristics
        .firstWhereOrNull((characteristic) =>
            characteristic.uuid ==
            MeasurementChar.bloodPressureMeasurement.address);

    final recordAccessCpCharacteristic = services
        .firstWhereOrNull(
          (service) => service.serviceUuid == recordAccessCpServiceUuid,
        )
        ?.characteristics
        .firstWhereOrNull((characteristic) =>
            characteristic.uuid == MeasurementChar.recordAccessCp.address);

    if (bpCharacteristic != null && recordAccessCpCharacteristic != null) {
      final hwMeasurementResult = await _getHwMeasurementResult(
        device: device,
        bpCharacteristic: bpCharacteristic,
        recordAccessCpCharacteristic: recordAccessCpCharacteristic,
        isPairing: !isMeasurement,
      );
      if (isMeasurement) {
        try {
          await Future.delayed(const Duration(seconds: 2));
          //repeat action in case to get fresh data
          final hwMeasurementResult2 = await _getHwMeasurementResult(
            device: device,
            bpCharacteristic: bpCharacteristic,
            recordAccessCpCharacteristic: recordAccessCpCharacteristic,
            isPairing: !isMeasurement,
            isSecondAttempt: true,
          );
          if (hwMeasurementResult2.resultState == ResultState.success) {
            debugPrint('fetched more updated result');
            return hwMeasurementResult2;
          }

          await device.disconnect();
        } catch (e) {
          debugPrint('device was disconnected');
        }
      }

      return hwMeasurementResult;
    } else {
      return HwMeasurementResult(
        resultState: ResultState.connectionError,
        measurementDt: DateTime.now(),
      );
    }
  }

  Future<List<int>?> _getBPDataFromService(
    BluetoothDevice device,
    BluetoothCharacteristic bpCharacteristic,
    BluetoothCharacteristic recordAccessCpCharacteristic,
    bool isPairing,
    bool? isSecondAttempt,
  ) async {
    if (isSecondAttempt == true && bpCharacteristic.isNotifying) {
      return null;
    }

    debugPrint('sending notification');

    if (Platform.isAndroid && isPairing) {
      final BluetoothBondState bondState = await device.bondState.first;
      if (bondState != BluetoothBondState.bonded) {
        try {
          await device.createBond();
        } catch (e) {
          debugPrint(e.toString());
          return null;
        }
      }
    } else if (Platform.isIOS && isPairing) {
      try {
        await recordAccessCpCharacteristic.setNotifyValue(
            !recordAccessCpCharacteristic.isNotifying,
            timeout: 30);
        await recordAccessCpCharacteristic
            .write([0x00, 0x01], withoutResponse: false, timeout: 30);
      } on FlutterBluePlusException catch (e) {
        //Timeout error
        if (e.code == 1) return null;
        //Insufficient encryption error
        if (e.code == 15) return null;
      }
    }

    await bpCharacteristic.setNotifyValue(!bpCharacteristic.isNotifying);
    //wait for few seconds until device sends necessary measurements in stream
    final List<List<int>> results = [];
    bpCharacteristic.lastValueStream.listen(results.add);
    await Future.delayed(const Duration(seconds: 5));
    return results.last;
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

// Future<void> getGenericAccessInfo(BluetoothService service) async {
//   final characteristics = service.characteristics;
//
//   debugPrint('generic access info:\n');
//   for (final characteristic in characteristics) {
//     final List<int> charInfo = await characteristic.read();
//     String charInfoString = String.fromCharCodes(charInfo);
//     debugPrint('0x${characteristic.uuid.toString().toUpperCase()}\n'
//         ' $charInfoString');
//   }
// }

// BluetoothCharacteristic? getRecordAccessCpChar(
//   List<BluetoothCharacteristic> characteristics,
// ) {
//   final specificChar = characteristics.firstWhereOrNull(
//     (char) => char.uuid == MeasurementChar.recordAccessCp.address,
//   );
//   return specificChar;
// }

// BluetoothCharacteristic? getBloodPressureChar(
//     List<BluetoothCharacteristic> characteristics,
//     ) {
//   final specificChar = characteristics.firstWhereOrNull(
//         (char) => char.uuid == MeasurementChar.bloodPressureMeasurement.address,
//   );
//   return specificChar;
// }

// void listenOnBloodPressureData(
//     BluetoothCharacteristic specificChar, {
//       required Function(List<int> data)? onData,
//     }) async {
//   specificChar.lastValueStream.listen((data) {
//     onData?.call(data);
//   });
// }