import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/api/contracts/measurement/blood_pressure_contract.dart';
import 'package:scalesoft_app/api/contracts/measurement/measurement.dart';
import 'package:scalesoft_app/constants/ble_constants.dart';
import 'package:scalesoft_app/constants/e8x_commands.dart';
import 'package:scalesoft_app/constants/e8x_response_types.dart';
import 'package:scalesoft_app/utils/helpers/e8x_helper.dart';

class BleE8xManager {
  BleE8xManager();

  Completer<List<Measurement>> _measurementCompleter = Completer();

  Completer<bool> _commandCompleter = Completer();
  int _byteSize = 0;
  final List<int> _rawData = [];
  List<int> _previousValue = [];
  List<int> _currentResponseType = [];

  List<int> _previousResponseType = [];

  // Obtain a BLE service that has all the necessary characteristics
  Future<BluetoothService> _getService(BluetoothDevice device) async {
    BluetoothService service = await device.discoverServices().then((services) {
      return services.singleWhere(
        (element) => element.uuid == BleConstants.gattServiceMain,
      );
    });
    return service;
  }

  // Obtain a BLE characteristic that can receive the commands necessary to set the wristband and retrieve data
  Future<BluetoothCharacteristic> _getCmdCharacteristic(
    BluetoothDevice device,
  ) async {
    var service = await _getService(device);
    BluetoothCharacteristic characteristic =
        service.characteristics.singleWhere(
      (element) => element.uuid == BleConstants.gattCharMainCmd,
    );
    return characteristic;
  }

  // Register notifications for two characteristics necessary for obtaining data from the wristband
  Future<void> registerNotifications(BluetoothDevice device) async {
    var service = await _getService(device);
    for (final characteristic in service.characteristics) {
      if (characteristic.uuid == BleConstants.gattCharMainCmd ||
          characteristic.uuid == BleConstants.gattCharMainRes) {
        if (!characteristic.isNotifying) {
          characteristic.onValueReceived.listen(_onReceiveData);

          await characteristic.setNotifyValue(true);
        }
      }
    }
  }

  Future<bool> setTime(BluetoothDevice device) async {
    return _sendCommand(device, E8xHelper.setTime);
  }

  Future<bool> setMeasurementInterval(
    BluetoothDevice device,
    int interval,
  ) async {
    return _sendCommand(
      device,
      () => E8xHelper.setMeasurementInterval(interval),
    );
  }

  Future<bool> setMetricUnits(BluetoothDevice device) async {
    return _sendCommand(device, () => E8xCommands.setMetricUnits);
  }

  Future<List<Measurement>> getHeartRateHistory(BluetoothDevice device) async {
    return _getMeasurement(
      device,
      () => E8xCommands.getHeartRateHistory,
      currRespType: [E8xResponseTypes.heartRate],
    );
  }

  Future<List<Measurement>> getBloodPressureHistory(
    BluetoothDevice device,
  ) async {
    return _getMeasurement(
      device,
      () => E8xCommands.getBloodPressureHistory,
      currRespType: [E8xResponseTypes.bloodPressure],
    );
  }

  Future<List<Measurement>> getOxygenSaturationHistory(
    BluetoothDevice device,
  ) async {
    return _getMeasurement(
      device,
      () => E8xCommands.getOxygenSaturationHistory,
      currRespType: [E8xResponseTypes.oxygenSaturation],
    );
  }

  Future<List<Measurement>> getBatteryLevel(BluetoothDevice device) async {
    return _getMeasurement(device, () => E8xCommands.getBatteryLevel);
  }

  Future<bool> deleteHeartRateHistory(BluetoothDevice device) async {
    return _sendCommand(device, () => E8xCommands.deleteHeartRateHistory);
  }

  Future<bool> deleteBloodPressureHistory(
    BluetoothDevice device,
  ) async {
    return _sendCommand(device, () => E8xCommands.deleteBloodPressureHistory);
  }

  Future<bool> deleteOxygenSaturationHistory(
    BluetoothDevice device,
  ) async {
    return _sendCommand(
      device,
      () => E8xCommands.deleteOxygenSaturationHistory,
    );
  }

  //Function processing all incoming messages from the wristband
  void _onReceiveData(List<int> value) {
    if (listEquals(_currentResponseType, _previousResponseType) &&
        listEquals(value, _previousValue)) return;
    _previousValue = value;
    _previousResponseType = _currentResponseType;
    if (value.length > 8 && value[0] == BleConstants.dataOper) {
      if ([17, 19, 21, 23, 24].contains(value[1])) {
        List<int> data = value.sublist(4, value.length - 2);
        _rawData.addAll(data);
      } else if (value[1] == BleConstants.confirmFetchData) {
        if (_byteSize == _rawData.length) {
          switch (_currentResponseType[0]) {
            case E8xResponseTypes.bloodPressure:
              _measurementCompleter.complete(_processBPData(_rawData));
              break;
            case E8xResponseTypes.heartRate:
              _measurementCompleter.complete(_processHRData(_rawData));
              break;
            case E8xResponseTypes.oxygenSaturation:
              _measurementCompleter.complete(_processSPData(_rawData));
              break;
          }
        } else {
          _measurementCompleter.completeError("Data inconsistency");
        }
      } else if (value.length == 16) {
        _byteSize =
            E8xHelper.bytesToDec([value[13], value[12], value[11], value[10]]);
      }
    } else {
      var subList = value.sublist(0, 2);
      if (listEquals(subList, E8xResponseTypes.timeSet)) {
        _commandCompleter.complete(true);
      }
      if (listEquals(subList, E8xResponseTypes.metricUnitsSet)) {
        _commandCompleter.complete(true);
      }
      if (listEquals(subList, E8xResponseTypes.measurementIntervalSet)) {
        _commandCompleter.complete(true);
      }
      if (listEquals(subList, E8xResponseTypes.bloodPressureHistoryDeleted)) {
        _commandCompleter.complete(true);
      }
      if (listEquals(subList, E8xResponseTypes.heartRateHistoryDeleted)) {
        _commandCompleter.complete(true);
      }
      if (listEquals(
        subList,
        E8xResponseTypes.oxygenSaturationHistoryDeleted,
      )) {
        _commandCompleter.complete(true);
      }
      if (listEquals(subList, E8xResponseTypes.batteryLevel)) {
        final batteryState = value[9];
        final measurement = Measurement(
          measurementType: MeasurementTypeContract.battery,
          batteryPercentage: batteryState,
          measurementDateTime: DateTime.now().toUtc(),
        );
        _measurementCompleter.complete([measurement]);
      }
      if (listEquals(subList, E8xResponseTypes.emptyOxygenSaturationHistory)) {
        _measurementCompleter.complete(<Measurement>[]);
      }
      if (listEquals(subList, E8xResponseTypes.emptyHeartRateHistory)) {
        _measurementCompleter.complete(<Measurement>[]);
      }
      if (listEquals(subList, E8xResponseTypes.emptyBloodPressureHistory)) {
        _measurementCompleter.complete(<Measurement>[]);
      }
    }
  }

  Future<List<Measurement>> _getMeasurement(
    BluetoothDevice device,
    List<int>? Function() func, {
    List<int>? currRespType,
  }) async {
    _measurementCompleter = Completer<List<Measurement>>();

    _sendRequest(device, func, currRespType);

    return Future.any([
      _measurementCompleter.future,
      Future.delayed(
        const Duration(seconds: BleConstants.bleTimeout),
        () => throw "Connection timeout",
      ),
    ]);
  }

  Future<bool> _sendCommand(
    BluetoothDevice device,
    List<int>? Function() func, {
    List<int>? currRespType,
  }) async {
    _commandCompleter = Completer<bool>();

    _sendRequest(device, func, currRespType);

    return Future.any([
      _commandCompleter.future,
      Future.delayed(
        const Duration(
          seconds: BleConstants.bleTimeout,
        ),
        () => throw "Connection timeout",
      ),
    ]);
  }

  //The only function that sends commands to the wristband
  Future<void> _sendRequest(
    BluetoothDevice device,
    List<int>? Function() func,
    List<int>? currRespType,
  ) async {
    _rawData.clear();
    _currentResponseType = currRespType ?? [];
    _previousValue = [];
    var characteristic = await _getCmdCharacteristic(device);
    characteristic.write(func() ?? [], withoutResponse: false);
  }

  List<Measurement> _processHRData(List<int> data) {
    List<Measurement> result = [];
    if (data.length >= 6) {
      int offset = 0;
      for (int i = 0; i < data.length ~/ 6; i++) {
        List<int> subData = data.sublist(offset, offset + 6);
        offset += 6;

        final measurementTime = E8xHelper.getTime(subData);
        int heartTimes = E8xHelper.bytesToDec([0, 0, 0, subData[5]]);

        result.add(
          Measurement(
            measurementType: MeasurementTypeContract.heartRate,
            heartRate: heartTimes,
            measurementDateTime: measurementTime,
          ),
        );
      }
    }
    return result;
  }

  List<Measurement> _processBPData(List<int> data) {
    List<Measurement> bpData = [];
    if (data.length >= 8) {
      int offset = 0;
      for (int i = 0; i < data.length ~/ 8; i++) {
        List<int> subData = data.sublist(offset, offset + 8);
        offset += 8;
        final measurementTime = E8xHelper.getTime(subData);
        int systolic = E8xHelper.bytesToDec([0, 0, 0, subData[6]]);
        int diastolic = E8xHelper.bytesToDec([0, 0, 0, subData[5]]);

        bpData.add(
          Measurement(
            measurementType: MeasurementTypeContract.bloodPressure,
            bloodPressure: BloodPressureContract(
              systolic: systolic,
              diastolic: diastolic,
            ),
            measurementDateTime: measurementTime,
          ),
        );
      }
    }
    return bpData;
  }

  List<Measurement> _processSPData(List<int> data) {
    List<Measurement> results = [];
    if (data.length >= 15) {
      for (final List<int> subData in E8xHelper.makeSendMsg(data, 20)) {
        if (subData.length >= 15) {
          final measurementTime = E8xHelper.getTime(subData);
          int spo2 = subData[9];
          int respiratoryRate = subData[10];
          //int cvrr = subData[12];
          //int hrv = subData[11];
          int tempI = subData[13];
          int tempD = subData[14];

          // The watches often send an incorrect temperature of 0.15 degrees celsius for unknown reasons. Ignore such values.
          double? temp;
          if (tempI == 0 && tempD == 15) {
            temp = null;
          } else {
            temp = double.parse('$tempI.$tempD');
          }

          // We only create one measurement instance with an arbitrarily chosen measurementType
          // - db only supports one measurement at any given instant.
          results.add(
            Measurement(
              measurementType: MeasurementTypeContract.oxygenSaturation,
              respiratoryRate: respiratoryRate,
              oxygenSaturation: spo2,
              temperature: temp,
              measurementDateTime: measurementTime,
            ),
          );
        }
      }
    }
    return results;
  }
}
