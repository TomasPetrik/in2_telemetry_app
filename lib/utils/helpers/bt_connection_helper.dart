import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/extensions/uint8_list_extension.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/measurement_info.dart';
import 'package:scalesoft_app/utils/constants.dart';

const String genericAccess = '00001800-0000-1000-8000-00805f9b34fb';
const String deviceInfo = '0000180a-0000-1000-8000-00805f9b34fb';
const String bloodPressure = '00001810-0000-1000-8000-00805f9b34fb';
const String batteryService = '0000180f-0000-1000-8000-00805f9b34fb';

class DeviceSearchResult {
  BluetoothDevice device;
  AdvertisementData advertisementData;

  DeviceSearchResult(this.device, this.advertisementData);
}

class BtConnectionHelper {
  static Future<DeviceSearchResult?> searchDevice({
    required String serviceUuid,
    required Device device,
  }) async {
    final flutterBlue = FlutterBluePlus.instance;

    final isScanning = await flutterBlue.isScanning.first;
    if (!isScanning) {
      flutterBlue.startScan();
    }

    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final availableDevices = await flutterBlue.scanResults.first;

      debugPrint('found ${availableDevices.length} devices');

      for (final result in availableDevices) {
        final serviceUuids = result.advertisementData.serviceUuids
            .map((uuid) => uuid.toLowerCase());
        if (serviceUuids.any(
              (devServiceUuid) =>
                  devServiceUuid.contains(serviceUuid.toLowerCase()),
            ) &&
            result.device.name
                .toLowerCase()
                .contains(device.bluetoothName!.toLowerCase()) &&
            (device.macAddress == null ||
                device.macAddress == result.device.id.toString())) {
          debugPrint('found device at ${result.timeStamp}');

          await flutterBlue.stopScan();
          return DeviceSearchResult(result.device, result.advertisementData);
        }
      }

      if (await flutterBlue.isScanning.first == false) {
        return null;
      }
    }
  }

  static Future<void> searchDevicesByService({
    required String serviceUuid,
    required Function(List<Device> devices) onResult,
  }) async {
    final flutterBlue = FlutterBluePlus.instance;

    final isScanning = await flutterBlue.isScanning.first;
    if (!isScanning) {
      flutterBlue.startScan();
    }

    final supportedBtNames = Constants.supportedDevices
        .map((supDev) => supDev.bluetoothName!.toLowerCase())
        .toList();

    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      final allDevices = await flutterBlue.scanResults.first;

      debugPrint('found all ${allDevices.length} devices');

      final matchedResults = allDevices.where((scanResult) {
        return scanResult.advertisementData.connectable &&
            scanResult.advertisementData.serviceUuids
                .map((uuid) => uuid.toLowerCase())
                .any((uuid) => uuid.contains(serviceUuid.toLowerCase())) &&
            supportedBtNames.any(
              (suppBtName) =>
                  scanResult.device.name.toLowerCase().contains(suppBtName),
            );
      }).toList();

      debugPrint('found matching devices ${matchedResults.length}');

      List<Device> availableDevices = [];

      for (final scanResult in matchedResults) {
        final devState = await scanResult.device.state.first;
        if (devState == BluetoothDeviceState.connected) {
          availableDevices.add(convertToDevice(scanResult.device));
        } else {
          try {
            await scanResult.device
                .connect(timeout: const Duration(seconds: 1));
            final devState = await scanResult.device.state.first;
            if (devState == BluetoothDeviceState.connected) {
              availableDevices.add(convertToDevice(scanResult.device));
            }
          } catch (e) {
            debugPrint('device was disconnected yet');
          }
        }
      }

      debugPrint('available devices devices ${matchedResults.length}');

/*

      final btDevices = matchedResults
          .map((scanResult) => convertToDevice(scanResult.device))
          .toList();
          */

      onResult.call(availableDevices);

      if (await flutterBlue.isScanning.first == false) {
        break;
      }
    }
  }

  static Device convertToDevice(BluetoothDevice btDevice) {
    final supportedDev = Constants.supportedDevices
        .firstWhere(
          (dev) => btDevice.name
              .toLowerCase()
              .contains(dev.bluetoothName!.toLowerCase()),
        )
        .copyWith(macAddress: btDevice.id.id);

    return supportedDev;
  }

  static Future<DeviceInfo?> requestDeviceInfo(BluetoothDevice device) async {
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

  static Future<BatteryInfo?> requestBatteryInfo(BluetoothDevice device) async {
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

  static Future<HwMeasurementResult> getHwMeasurementResult(
    BluetoothService bpService, {
    bool? isSecondAttempt,
  }) async {
    final dtNow = DateTime.now().toUtc();

    var bpData = await getBPDataFromService(bpService, isSecondAttempt);

    if (bpData == null) {
      return HwMeasurementResult(
        resultState: ResultState.connectionError,
        measurementDt: dtNow,
      );
    } else if (bpData.isEmpty) {
      return HwMeasurementResult(
        resultState: ResultState.noData,
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

  static Future<HwMeasurementResult> requestBPData(
    BluetoothDevice device,
    bool isMeasurement,
  ) async {
    final services = await device.discoverServices();
    final bpService = services.firstWhereOrNull(
      (service) => service.uuid.toString().toLowerCase() == bloodPressure,
    );

    if (bpService != null) {
      final hwMeasurementResult = await getHwMeasurementResult(bpService);
      if (isMeasurement) {
        await Future.delayed(const Duration(seconds: 2));
        //repeat action in case to get fresh data
        final hwMeasurementResult2 =
            await getHwMeasurementResult(bpService, isSecondAttempt: true);
        if (hwMeasurementResult2.resultState == ResultState.success) {
          debugPrint('fetched more updated result');
          return hwMeasurementResult2;
        }
      }
      await device.disconnect();
      return hwMeasurementResult;
    } else {
      return HwMeasurementResult(
        resultState: ResultState.connectionError,
        measurementDt: DateTime.now(),
      );
    }
  }

  static Future<List<int>?> getBPDataFromService(
    BluetoothService service,
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

    await bpCharacteristic.setNotifyValue(!bpCharacteristic.isNotifying);

    //wait for 5 seconds untill device sends necessary measements in stream
    final List<List<int>> results = [];
    bpCharacteristic.value.listen(results.add);
    await Future.delayed(const Duration(seconds: 5));

    return results.last;
  }

  static Future<String> readCharData(
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

  static void listenOnBloodPressureData(
    BluetoothCharacteristic speficicChar, {
    required Function(List<int> data)? onData,
  }) async {
    speficicChar.value.listen((data) {
      onData?.call(data);
    });
  }

  static BluetoothCharacteristic? getBloodPressureChar(
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

  static Future<DeviceInfo> getDeviceInfoFromService(
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

  static Future<BatteryInfo?> getBatteryInfoFromService(
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

  static Future<void> getGenericAccessInfo(BluetoothService service) async {
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

  static Future<bool> hasPermissionsGranted() async {
    if (!Platform.isAndroid) {
      return true;
    }

    Map<Permission, PermissionStatus> statuses = await [
      //Permission.bluetooth, // -> is handled by flutter blue plus
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise
    ].request();

    if (statuses.values.any((permission) => permission.isGranted == false)) {
      return false;
    }

    return true;
  }
}
