import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/cubit/omron/omron_connection_state.dart';
import 'package:scalesoft_app/model/device_info.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/measurement_info.dart';
import 'package:scalesoft_app/ui/screens/constants.dart';

enum Service { genericAccess, deviceInfo, bloodPressure, batteryService }

const String genericAccess = '00001800-0000-1000-8000-00805f9b34fb';
const String deviceInfo = '0000180a-0000-1000-8000-00805f9b34fb';
const String bloodPressure = '00001810-0000-1000-8000-00805f9b34fb';
const String batteryService = '0000180F-0000-1000-8000-00805f9b34fb';

@singleton
class OmronConnectionCubit extends Cubit<OmronConnectionState> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  bool search = true;

  OmronConnectionCubit()
      : super(
          const OmronConnectionState.init(),
        );

  void checkDeviceAvailability() async {
    List<BluetoothDevice> devices = await flutterBlue.connectedDevices;

    if (devices.isNotEmpty) {
      final device = devices[0];
      final BluetoothDeviceState deviceState = await device.state.first;
      if (deviceState == BluetoothDeviceState.connected) {
        verifyDevice(device);
      } else {
        connectToDevice(device);
      }
    } else {
      searchDevice();
    }
  }

  Future<void> stopSearch() {
    search = false;
    return flutterBlue.stopScan();
  }

  void searchDevice() {
    search = true;

    emit(const OmronConnectionState.searching());

    flutterBlue.isScanning.listen((isScanning) {
      if (!isScanning && search) {
        flutterBlue.startScan(timeout: const Duration(seconds: 4));
      }
    });

    flutterBlue.scanResults.listen(
      (results) async {
        if (!search) {
          return;
        }
        // do something with scan results

        for (final result in results) {
          if (result.advertisementData.serviceUuids
              .map((uuid) => uuid.toLowerCase())
              .contains(bloodPressureServiceUuid)) {
            search = false;
            flutterBlue.stopScan();
            BluetoothDevice device = result.device;
            emit(OmronConnectionState.found(device: device));
            connectToDevice(device);
            break;
          }
        }
      },
    );
  }

  /*
    1. Try to connect on device,
    2. When connected, read device info and proceed on device verification,
  */
  Future<void> connectToDevice(BluetoothDevice device) async {
    emit(const OmronConnectionState.connecting());
    await device.connect(autoConnect: false);

    final BluetoothDeviceState deviceState = await device.state.first;
    if (deviceState == BluetoothDeviceState.connected) {
      emit(const OmronConnectionState.connected());
    } else {
      emit(const OmronConnectionState.disconnected());
      return;
    }

    verifyDevice(device);
  }

  /*
    3. Verify device and proceed on device measurement
  */
  Future<void> verifyDevice(BluetoothDevice device) async {
    final deviceInfo = await requestDeviceInfo(device);
    if (deviceInfo != null) {
      emit(
        OmronConnectionState.verified(
          device: device,
          deviceInfo: deviceInfo,
        ),
      );
    } else {
      emit(const OmronConnectionState.notVerified());
      return;
    }

    emit(const OmronConnectionState.syncing());

    final measurementResult = await requestBPData(device);
    emit(OmronConnectionState.synced(measurementResult: measurementResult));
  }

  Future<DeviceInfo?> requestDeviceInfo(BluetoothDevice device) async {
    final services = await device.discoverServices();
    final deviceInfoService = services.firstWhereOrNull(
      (service) => service.uuid.toString().toLowerCase() == deviceInfo,
    );
    if (deviceInfoService != null) {
      final deviceInfo = await getDeviceInfoFromService(deviceInfoService);
      return deviceInfo;
    } else {
      return null;
    }
  }

  Future<HwMeasurementResult> requestBPData(BluetoothDevice device) async {
    final services = await device.discoverServices();
    final bloodPressureInfoService = services.firstWhereOrNull(
      (service) => service.uuid.toString().toLowerCase() == bloodPressure,
    );
    if (bloodPressureInfoService != null) {
      final measurementResult =
          await getBPInfoFromService(bloodPressureInfoService);
      return measurementResult;
    } else {
      return HwMeasurementResult(resultState: ResultState.connectionError);
    }
  }

  /*
    4. Try to get measured data, if measurement is not successfult:
      3.1 Device is not connected,
      3.2 Device should be paired first,
  */
  Future<HwMeasurementResult> getBPInfoFromService(
    BluetoothService service,
  ) async {
    final characteristics = service.characteristics;
    final bpCharacteristic = getBloodPressureChar(characteristics);
    final completer = Completer();
    HwMeasurementResult? measurementResult;

    if (bpCharacteristic == null) {
      return HwMeasurementResult(resultState: ResultState.connectionError);
    }

    listenOnBloodPressureData(
      bpCharacteristic,
      onData: (List<int> data) {
        if (data.isNotEmpty) {
          final measurementInfo = MeasurementInfo.fromIntList(data);

          measurementResult = HwMeasurementResult(
            resultState: ResultState.success,
            measurementInfo: measurementInfo,
          );
          completer.complete();
        }
      },
    );

    reqDevForBPData(bpCharacteristic);
    await Future.any(
      [completer.future, Future.delayed(const Duration(seconds: 4))],
    );

    measurementResult ??= HwMeasurementResult(resultState: ResultState.noData);

    return measurementResult!;
  }

/*
    final genericAccessInfoService = services.firstWhereOrNull(
      (service) => service.uuid.toString().toLowerCase() == genericAccess,
    );
    if (genericAccessInfoService != null) {
      await getGenericAccessInfo(genericAccessInfoService);
    }

  
    */

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
    speficicChar.value.listen((data) {
      onData?.call(data);
      //subscription.cancel();
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

  Future<void> reqDevForBPData(
    BluetoothCharacteristic speficicChar,
  ) async {
    await speficicChar.setNotifyValue(!speficicChar.isNotifying);
    await speficicChar.read();
  }

  Future<DeviceInfo> getDeviceInfoFromService(BluetoothService service) async {
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

  Future<void> getBatteryInfo(BluetoothService service) async {
    final characteristics = service.characteristics;

    debugPrint('battery info:\n');
    for (final characteristic in characteristics) {
      final List<int> charInfo = await characteristic.read();
      String charInfoString = String.fromCharCodes(charInfo);
      debugPrint(
          '0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}\n'
          ' $charInfoString');
    }
  }
}
