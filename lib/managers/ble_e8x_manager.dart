import 'package:ble_wrist_ui/constants/ble_constants.dart';
import 'package:ble_wrist_ui/constants/e8x_commands.dart';
import 'package:ble_wrist_ui/constants/e8x_response_types.dart';
import 'package:ble_wrist_ui/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/api/model/care_plan/care_plan_activity.dart';
// import '../../../MobileE86SDK/lib/utils.dart';
import 'dart:async';

import 'package:scalesoft_app/api/model/measurement/measurement.dart';


class BleE8xManager {
  BleE8xManager._privateConstructor();
  // static final BleE8xManager _instance = BleE8xManager._privateConstructor();
  // factory BleE8xManager() => _instance;
  
  Completer<List<Object>> _taskCompleter = Completer();

  int _byteSize = 0;
  final List<int> _rawData = [];
  List<int> _prevValue = [];
  List<int> _currRespType = [];
  List<int> _prevCurrRespType = [];

  int _battState = 0;

  // Obtain a BLE service that has all the necessary characteristics
  Future<BluetoothService> _getService(BluetoothDevice device) async {
    BluetoothService service = await device.discoverServices().then((services) {
      return services.singleWhere(
          (element) => element.uuid.toString() == BleConstants.GATT_SERVICE_MAIN);
    });
    return service;
  }

  // Obtain a BLE characteristic that can receive the commands necessary to set the wristband and retrieve data
  Future<BluetoothCharacteristic> _getCmdCharacteristic(
      BluetoothDevice device) async {
    var service = await _getService(device);
    BluetoothCharacteristic charr = service.characteristics.singleWhere(
        (element) => element.uuid.toString() == BleConstants.GATT_CHAR_MAIN_CMD);
    return charr;
  }

  // Register notifications for two characteristics necessary for obtaining data from the wristband
  @override
  Future<void> registerNotifications(BluetoothDevice device) async {
    var service = await _getService(device);
    for (var charr in service.characteristics) {
      if (charr.uuid.toString() == BleConstants.GATT_CHAR_MAIN_CMD ||
          charr.uuid.toString() == BleConstants.GATT_CHAR_MAIN_RES) {
        if (!charr.isNotifying) {
          charr.onValueReceived.listen((data) {
            _onReceiveData(data);
          });
          
          await charr.setNotifyValue(true);
        }
      }
    }
  }

    Future<List<Object>> setTime(BluetoothDevice device) async {
    return _sendCommand(device, () => Utils.setTime());
  }


  Future<List<Object>> setMeasurementInterval(BluetoothDevice device, int interval) async {
    return _sendCommand(device, () => Utils.setMeasurementInterval(interval));
  }


  Future<List<Object>> setMetricUnits(BluetoothDevice device) async {
    return _sendCommand(device, () => E8xCommands.setMetricUnits);
  }


  Future<List<Object>?> getHeartRateHistory(BluetoothDevice device) async {
    return _sendCommand(device, () => E8xCommands.getHeartRateHistory,
        currRespType: [E8xResponseTypes.heartRate]);
  }


  Future<List<Object>?> getBloodPressureHistory(BluetoothDevice device) async {
    return _sendCommand(device, () => E8xCommands.getBloodPressureHistory,
        currRespType: [E8xResponseTypes.bloodPressure]);
  }


  Future<List<Object>?> getOxygenSaturationHistory(BluetoothDevice device) async {
    return _sendCommand(device, () => E8xCommands.getOxygenSaturationHistory,
        currRespType: [E8xResponseTypes.oxygenSaturation]);
  }


  Future<List<Object>> getDevInfo(BluetoothDevice device) async {
    return _sendCommand(device, () => E8xCommands.getDeviceInfo);
  }


  Future<List<Object>> deleteHeartRateHistory(BluetoothDevice device) async {
    return _sendCommand(device, () => E8xCommands.deleteHeartRateHistory);
  }


  Future<List<Object>> deleteBloodPressureHistory(BluetoothDevice device) async {
    return _sendCommand(device, () => E8xCommands.deleteBloodPressureHistory);
  }


  Future<List<Object>> deleteOxygenSaturationHistory(BluetoothDevice device) async {
    return _sendCommand(device, () => E8xCommands.deleteOxygenSaturationHistory);
  }

  //Function processing all incoming messages from the wristband
  _onReceiveData(List<int> value) {
    if (listEquals(currentResponseType, previousResponseType) &&
        listEquals(value, previousValue)) return;
    previousValue = value;
    previousResponseType = currentResponseType;
    if (value.length > 8 && value[0] == BleConstants.DATA_OPER) {
      if ([17, 19, 21, 23, 24].contains(value[1])) {
        List<int> data = value.sublist(4, value.length - 2);
       rawData.addAll(data);
      } else if (value[1] == BleConstants.CONFIRM_FETCH_DATA) {
        if (byteSize == rawData.length) {
          switch (currentResponseType[0]) {
            case E8xResponseTypes.bloodPressure:
              taskCompleter.complete(_processBPData(rawData));
              break;
            case E8xResponseTypes.heartRate:
              taskCompleter.complete(_processHRData(rawData));
              break;
            case E8xResponseTypes.oxygenSaturation:
              taskCompleter.complete(_processSPData(rawData));
              break;
          }
        } else {
          taskCompleter.completeError("Data inconsistency");
        }
      } else if (value.length == 16) {
        byteSize =
            Utils.bytesToDec([value[13], value[12], value[11], value[10]]);
      }
    } else {
      var subList = value.sublist(0, 2);
      if (listEquals(subList, E8xResponseTypes.timeSet)) {
        taskCompleter.complete([true]);
      }
      if (listEquals(subList, E8xResponseTypes.metricUnitsSet)) {
        taskCompleter.complete([true]);
      }
      if (listEquals(subList, E8xResponseTypes.measurementIntervalSet)) {
        taskCompleter.complete([true]);
      }
      if (listEquals(subList, E8xResponseTypes.bloodPressureHistoryDeleted)) {
        taskCompleter.complete([true]);
      }
      if (listEquals(subList, E8xResponseTypes.heartRateHistoryDeleted)) {
        taskCompleter.complete([true]);
      }
      if (listEquals(subList, E8xResponseTypes.oxygenSaturationHistoryDeleted)) {
        taskCompleter.complete([true]);
      }
      if (listEquals(subList, E8xResponseTypes.deviceInfo)) {
        batteryState = value[9];
        taskCompleter.complete([batteryState]);
      }
      if (listEquals(subList, E8xResponseTypes.emptyOxygenSaturationHistory)) {
        taskCompleter.complete(<IHistoryInfo>[]);
      }
      if (listEquals(subList, E8xResponseTypes.emptyHeartRateHistory)) {
        taskCompleter.complete(<IHistoryInfo>[]);
      }
      if (listEquals(subList, E8xResponseTypes.emptyBloodPressureHistory)) {
        taskCompleter.complete(<IHistoryInfo>[]);
      }
    }
  }

  //The only function that sends commands to the wristband and waits for data or timeout
  Future<List<Object>> _sendCommand(
      BluetoothDevice device, List<int>? Function() func,
      {List<int>? currRespType}) async {
    rawData.clear();
    currentResponseType = currRespType ?? [];
    previousValue = [];
    taskCompleter = Completer<List<Object>>();
    var charr = await _getCmdCharacteristic(device);
    charr.write(func() ?? [], withoutResponse: false);

    return Future.any([
      taskCompleter.future,
      Future.delayed(
        const Duration(seconds: BleConstants.BLE_TIMEOUT),
        () => throw "Connection timeout",
      )
    ]);
  }

  List<IHistoryInfo> _processHRData(List<int> data) {
    List<IHistoryInfo> hrData = [];
    if (data.length >= 6) {
      int offset = 0;
      for (int i = 0; i < data.length ~/ 6; i++) {
        List<int> subData = data.sublist(offset, offset + 6);
        offset += 6;

        final measurementTime = Utils.getTime(subData);
        int heartTimes = Utils.bytesToDec([0, 0, 0, subData[5]]);

        HRInfo hRInfo = HRInfo(measurementTime.toUtc(), heartTimes);
        hrData.add(hRInfo);
      }
    }
    return hrData;
  }

  List<IHistoryInfo> _processBPData(List<int> data) {
    List<IHistoryInfo> bpData = [];
    if (data.length >= 8) {
      int offset = 0;
      for (int i = 0; i < data.length ~/ 8; i++) {
        List<int> subData = data.sublist(offset, offset + 8);
        offset += 8;
        final measurementTime = Utils.getTime(subData);
        int SBP = Utils.bytesToDec([0, 0, 0, subData[6]]);
        int DBP = Utils.bytesToDec([0, 0, 0, subData[5]]);

        BPInfo bPInfo = BPInfo(measurementTime.toUtc(), DBP, SBP);
        bpData.add(bPInfo);
      }
    }
    return bpData;
  }

  List<Measurement> _processSPData(List<int> data) {
    List<Measurement> spData = [];
    if (data.length >= 15) {
      for (List<int> subData in Utils.makeSendMsg(data, 20)) {
        if (subData.length >= 15) {
          final measurementTime = Utils.getTime(subData);
          int spo2 = subData[9];
          int respiratoryRate = subData[10];
          //int cvrr = subData[12];
          //int hrv = subData[11];
          int tempI = subData[13];
          int tempD = subData[14];
          double temp = double.parse('$tempI.$tempD');
          Measurement(
            measurementType: MeasurementType.respiratoryRate,
            respiratoryRate: respiratoryRate,
            measurementDateTime: measurementTime,
          )
          SPInfo sPInfo = SPInfo(
            measurementTime.toUtc(),
            respiratoryRate,
            spo2,
            temp,
          );
          spData.add(sPInfo);
        }
      }
    }
    return spData;
  }
}
