import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/extensions/uint8_list_extension.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/measurement_info.dart';
import 'package:scalesoft_app/utils/constants.dart';

const String deviceInfo = '0000180a-0000-1000-8000-00805f9b34fb';
const String bloodPressure = '00001810-0000-1000-8000-00805f9b34fb';
const String batteryService = '0000180f-0000-1000-8000-00805f9b34fb';
const String bloodPressureServiceUuid = '1810';

class DeviceSearchResult {
  BluetoothDevice device;
  String localName;

  DeviceSearchResult(this.device, this.localName);
}

enum SearchMode { pairing, syncing }

@singleton
class BtConnectionHelper {
  bool syncMode = false;

  bool matchDeviceMode(
    String localName,
    device,
    SearchMode searchMode,
  ) {
    final supportedBtNames = Constants.supportedDevices
        .map((supDev) => supDev.bluetoothName ?? '')
        .toList();

    final supportedBtPairingNames = Constants.supportedDevices
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

  bool matchDeviceId(Device device, String localName) {
    if (device.deviceIdentifier == null) {
      return true;
    }

    final supportedDev = Constants.supportedDevices.firstWhere(
      (dev) {
        return localName
            .toLowerCase()
            .contains(dev.bluetoothName!.toLowerCase());
      },
    );

    var deviceId = device.deviceIdentifier;
    var searchDevId = localName;

    if (supportedDev.deviceModelType == DeviceModelType.omronM7) {
      searchDevId = searchDevId.split('_').last;
      deviceId = deviceId?.split('_').last;
    }

    if (deviceId == searchDevId) {
      debugPrint('$localName is matching ID $deviceId');
      return true;
    } else {
      debugPrint('$localName NOT matching ID $deviceId');
      return false;
    }
  }

  Future<DeviceSearchResult?> searchDevice({
    required String serviceUuid,
    required Device device,
    required SearchMode searchMode,
    Duration? maxAllowedDeviceSearchingTime,
  }) async {
    syncMode = true;
    final isScanning = FlutterBluePlus.isScanningNow;
    if (!isScanning) {
      FlutterBluePlus.startScan();
    }

    final connectedDevices = await FlutterBluePlus.connectedSystemDevices;

    for (final connectedDevice in connectedDevices) {
      debugPrint('disconecting from ${connectedDevice.localName}');
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
      final availableDevices = await FlutterBluePlus.scanResults.first;

      for (final scanResult in availableDevices) {
        final serviceUuids = scanResult.advertisementData.serviceUuids
            .map((uuid) => uuid.toLowerCase());
        if (serviceUuids.any(
              (devServiceUuid) =>
                  devServiceUuid.contains(serviceUuid.toLowerCase()),
            ) &&
            matchDeviceMode(
              scanResult.advertisementData.localName,
              device,
              searchMode,
            ) &&
            matchDeviceId(
              device,
              scanResult.advertisementData.localName,
            )) {
          debugPrint('found device');

          await FlutterBluePlus.stopScan();

          return DeviceSearchResult(
            scanResult.device,
            scanResult.advertisementData.localName,
          );
        }
      }

      if (syncMode = false || FlutterBluePlus.isScanningNow == false) {
        return null;
      }
    }
  }

  Future<void> searchDevicesByService({
    required String serviceUuid,
    required onlyPairingMode,
    required Function(List<Device> devices) onResult,
  }) async {
    syncMode = false;
    final isScanning = FlutterBluePlus.isScanningNow;
    if (!isScanning) {
      FlutterBluePlus.startScan();
    }

    final supportedBtNames = Constants.supportedDevices
        .map((supDev) => supDev.bluetoothName ?? '')
        .toList();

    final supportedBtPairingNames = Constants.supportedDevices
        .map((supDev) => supDev.bluetoothPairingName ?? '')
        .toList();

    while (true) {
      Future.delayed(const Duration(seconds: 1));
      final allDevices = await FlutterBluePlus.scanResults.first;

      debugPrint('found all ${allDevices.length} devices');

      final matchedResults = allDevices.where((scanResult) {
        return scanResult.advertisementData.serviceUuids
                .map((uuid) => uuid.toLowerCase())
                .any((uuid) => uuid.contains(serviceUuid.toLowerCase())) &&
            ((!onlyPairingMode &&
                    supportedBtNames.any((suppBtName) {
                      return scanResult.advertisementData.localName
                          .toLowerCase()
                          .contains(suppBtName.toLowerCase());
                    })) ||
                (onlyPairingMode &&
                    supportedBtPairingNames.any((suppBtPairName) {
                      return scanResult.advertisementData.localName
                          .contains(suppBtPairName);
                    })));
      }).toList();

      debugPrint('found matching devices ${matchedResults.length}');

      final List<Device> availableDevices = [];

      for (final scanResult in matchedResults) {
        if (scanResult.rssi < 0 && scanResult.advertisementData.connectable) {
          availableDevices.add(
            convertToDevice(
              scanResult.advertisementData.localName,
              scanResult.device,
            ),
          );
        }
      }

      debugPrint('available devices ${matchedResults.length}');

      onResult.call(availableDevices);

      if (syncMode || FlutterBluePlus.isScanningNow == false) {
        break;
      }
    }
  }

  Device convertToDevice(
    String advertisementName,
    BluetoothDevice btDevice,
  ) {
    final supportedDev = Constants.supportedDevices.firstWhere(
      (dev) {
        return advertisementName
            .toLowerCase()
            .contains(dev.bluetoothName!.toLowerCase());
      },
    );

    var preferedIdName = advertisementName;

    if (supportedDev.deviceModelType == DeviceModelType.omronM7) {
      preferedIdName = advertisementName.split('_').last;
    }

    return supportedDev.copyWith(deviceIdentifier: preferedIdName);
  }

  Future<DeviceInfo?> requestDeviceInfo(BluetoothDevice device) async {
    var services = [];

    Future.delayed(const Duration(milliseconds: 100));
    services = await device.discoverServices().timeout(
          const Duration(seconds: 3),
          onTimeout: () => <BluetoothService>[],
        );

    debugPrint('found services ${services.length}');
    Future.delayed(const Duration(milliseconds: 100));
    services = await device.discoverServices().timeout(
          const Duration(seconds: 3),
          onTimeout: () => <BluetoothService>[],
        );

    debugPrint('found services2 ${services.length}');

    final deviceInfoService = services.firstWhereOrNull(
      (service) => service.uuid.toString().toLowerCase() == deviceInfo,
    );
    if (deviceInfoService != null) {
      final deviceInfo = await getDeviceInfoFromService(deviceInfoService);
      deviceInfo.device = device;
      return deviceInfo;
    } else {
      return null;
    }
  }

/*
  static Future<DeviceInfo?> requestDeviceInfo2(BluetoothDevice device) async {
    device.se

    final services = await device.discoverServices();
    final deviceInfoService = services.firstWhereOrNull(
      (service) => service.uuid.toString().toLowerCase() == deviceInfo,
    );
    if (deviceInfoService != null) {
      final deviceInfo = await getDeviceInfoFromService(deviceInfoService);
      deviceInfo.device = device;
      return deviceInfo;
    } else {
      return null;
    }
  }
  */

  Future<BatteryInfo?> requestBatteryInfo(BluetoothDevice device) async {
    final services = await device.discoverServices();
    final batteryInfoService = services.firstWhereOrNull(
      (service) => service.uuid.toString().toLowerCase() == batteryService,
    );
    if (batteryInfoService != null) {
      final batteryInfo = await getBatteryInfoFromService(batteryInfoService);
      return batteryInfo;
    } else {
      return null;
    }
  }

  Future<HwMeasurementResult> getHwMeasurementResult({
    required BluetoothDevice device,
    required BluetoothService bpService,
    required bool isPairing,
    required String devId,
    bool? isSecondAttempt,
  }) async {
    final dtNow = DateTime.now().toUtc();

    var bpData = await getBPDataFromService(
      device,
      bpService,
      isPairing,
      isSecondAttempt,
    );

    if (bpData == null) {
      return HwMeasurementResult(
        resultState: ResultState.connectionError,
        measurementDt: dtNow,
        devId: devId,
      );
    } else if (bpData.isEmpty) {
      return HwMeasurementResult(
        resultState: isPairing ? ResultState.success : ResultState.noData,
        measurementDt: dtNow,
        devId: devId,
      );
    } else {
      final measurementInfo = MeasurementInfo.fromIntList(bpData);
      return HwMeasurementResult(
        resultState: ResultState.success,
        measurementInfo: measurementInfo,
        measurementDt: dtNow,
        devId: devId,
      );
    }
  }

  Future<HwMeasurementResult> requestBPData(
    BluetoothDevice device,
    bool isMeasurement,
    String devId,
  ) async {
    final services = await device.discoverServices();
    final bpService = services.firstWhereOrNull(
      (service) => service.uuid.toString().toLowerCase() == bloodPressure,
    );

    if (bpService != null) {
      final hwMeasurementResult = await getHwMeasurementResult(
        device: device,
        bpService: bpService,
        isPairing: !isMeasurement,
        devId: devId,
      );
      if (isMeasurement) {
        await Future.delayed(const Duration(seconds: 2));
        //repeat action in case to get fresh data
        final hwMeasurementResult2 = await getHwMeasurementResult(
          device: device,
          bpService: bpService,
          isPairing: !isMeasurement,
          isSecondAttempt: true,
          devId: devId,
        );
        if (hwMeasurementResult2.resultState == ResultState.success) {
          debugPrint('fetched more updated result');
          return hwMeasurementResult2;
        }

        await device.disconnect();
      }

      return hwMeasurementResult;
    } else {
      return HwMeasurementResult(
        resultState: ResultState.connectionError,
        measurementDt: DateTime.now(),
        devId: devId,
      );
    }
  }

  Future<List<int>?> getBPDataFromService(
    BluetoothDevice device,
    BluetoothService service,
    bool isPairing,
    bool? isSecondAttempt,
  ) async {
    final characteristics = service.characteristics;
    final bpCharacteristic = getBloodPressureChar(characteristics);

    if (bpCharacteristic == null) {
      return null;
    }

    if (isSecondAttempt == true && !bpCharacteristic.isNotifying == false) {
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
    }

    await bpCharacteristic.setNotifyValue(!bpCharacteristic.isNotifying);
    debugPrint('sent notification value');

    //wait for few seconds until device sends neccessary measurements in stream
    final List<List<int>> results = [];
    bpCharacteristic.lastValueStream.listen(results.add);
    await Future.delayed(const Duration(seconds: 5));

    //if iOS device is still connected in pairing process, we can consider that user haven't confirmed
    //device pair in system dialog, so return null as (connection error)
    /*
    if (Platform.isIOS && isPairing) {
      const iOsPairinAttemptsCheck = 15;
      for (int i = 1; i <= iOsPairinAttemptsCheck; i++) {
        final deviceState = await device.connectionState.first;

        if (deviceState == BluetoothConnectionState.connected &&
            i == iOsPairinAttemptsCheck) {
          return null;
        } else if (deviceState == BluetoothConnectionState.disconnected) {
          final reason = device.disconnectReason;
          if (reason?.code == 2) {
            break;
          } else {
            return null;
          }
        }

        await Future.delayed(const Duration(seconds: 1));
      }
    }
    */

    return results.last;
  }

  Future<String> readCharData(
    List<BluetoothCharacteristic> characteristics,
    DeviceChar characteristic,
  ) async {
    String address = deviceCharAddress.entries
        .firstWhere((entry) => entry.key == characteristic)
        .value;
    final speficicChar = characteristics.firstWhereOrNull(
      (char) => char.uuid.toString().toUpperCase().substring(4, 8) == address,
    );

    if (speficicChar == null) {
      return '';
    }

    final List<int> charData = await speficicChar.read();
    return String.fromCharCodes(charData);
  }

  void listenOnBloodPressureData(
    BluetoothCharacteristic speficicChar, {
    required Function(List<int> data)? onData,
  }) async {
    speficicChar.lastValueStream.listen((data) {
      onData?.call(data);
    });
  }

  BluetoothCharacteristic? getBloodPressureChar(
    List<BluetoothCharacteristic> characteristics,
  ) {
    String address = measurementCharAddress.entries
        .firstWhere(
          (entry) => entry.key == MeasurementChar.bloodPressureMeasurement,
        )
        .value;
    final speficicChar = characteristics.firstWhereOrNull(
      (char) => char.uuid.toString().toUpperCase().substring(4, 8) == address,
    );
    return speficicChar;
  }

  Future<DeviceInfo> getDeviceInfoFromService(
    BluetoothService service,
  ) async {
    final characteristics = service.characteristics;

    final modelNumber =
        await readCharData(characteristics, DeviceChar.modelNumber);
    final serialNumber =
        await readCharData(characteristics, DeviceChar.serialNumber);
    final firmwareRevision =
        await readCharData(characteristics, DeviceChar.firmwareRevision);
    final hardwareRevision =
        await readCharData(characteristics, DeviceChar.hardwareRevision);
    final softwareRevision =
        await readCharData(characteristics, DeviceChar.softwareRevision);
    final manufacturerName =
        await readCharData(characteristics, DeviceChar.manufacturerName);

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

  Future<BatteryInfo?> getBatteryInfoFromService(
    BluetoothService service,
  ) async {
    final characteristics = service.characteristics;

    String batteryLevelAdress = deviceCharAddress.entries
        .firstWhere((entry) => entry.key == DeviceChar.batteryLevel)
        .value;

    final batteryLevelChar = characteristics.firstWhereOrNull(
      (char) =>
          char.uuid.toString().toUpperCase().substring(4, 8) ==
          batteryLevelAdress,
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

  Future<void> getGenericAccessInfo(BluetoothService service) async {
    final characteristics = service.characteristics;

    debugPrint('generic access info:\n');
    for (final characteristic in characteristics) {
      final List<int> charInfo = await characteristic.read();
      String charInfoString = String.fromCharCodes(charInfo);
      debugPrint(
          '0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}\n'
          ' $charInfoString');
    }
  }

  Future<bool> hasPermissionsGranted() async {
    if (!Platform.isAndroid) {
      return true;
    }

    Map<Permission, PermissionStatus> statuses = await [
      //Permission.bluetooth, // -> is handled by flutter blue plus
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();

    if (statuses.values.any((permission) => permission.isGranted == false)) {
      return false;
    }

    return true;
  }
}
