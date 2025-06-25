import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/bt_data/connectors/device_connector.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement/blood_pressure_value.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/measurement_create_model.dart';
import 'package:scalesoft_app/utils/extensions/uint8_list_extension.dart';

class BloodPressureDeviceConnector implements DeviceConnector {
  final _measurementUuid = Guid('2A35');
  final _userByte = 16;
  final _dateTimeByte = 7;
  final _dateTimeLength = 7;
  final _systolicByte = 1;
  final _diastolicByte = 3;
  final _heartRateByte = 14;

  @override
  Future<HwMeasurementResult> loadMeasurement(BluetoothDevice device,
      List<BluetoothCharacteristic> characteristics) async {
    var measurementCharacteristic = characteristics.firstWhereOrNull(
      (chara) => chara.uuid == _measurementUuid,
    );
    if (measurementCharacteristic == null) {
      debugPrint("characteristic not found");
      device.disconnect();
      return HwMeasurementResult(
          resultState: ResultState.noData, measurementDt: DateTime.now());
    }

    var receivedFirst = false;
    var lastReceived = DateTime.now();
    var dataArray = List<List<int>>.empty(growable: true);
    final subscription = measurementCharacteristic.onValueReceived.listen(
      (data) {
        dataArray.add(data);
        lastReceived = DateTime.now();
        receivedFirst = true;
      },
    );
    await measurementCharacteristic.setNotifyValue(!measurementCharacteristic.isNotifying);
    await Future.delayed(const Duration(seconds: 1));
    while (DateTime.now().difference(lastReceived).inMilliseconds < 500 || !receivedFirst) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    subscription.cancel();

    if (dataArray.isEmpty) {
      debugPrint("no data received");
      device.disconnect();
      return HwMeasurementResult(
          resultState: ResultState.noData, measurementDt: DateTime.now());
    }

    var btData = dataArray.last;
    var measurementCreateModel = MeasurementCreateModel(
      btData.toInt8(_userByte, _userByte + 1),
      btData.toTimestamp(_dateTimeByte, _dateTimeByte + _dateTimeLength),
      MeasurementType.bloodPressure,
      bloodPressure: BloodPressureValue(
        systolic: btData.toInt16(_systolicByte, _systolicByte + 2),
        diastolic: btData.toInt16(_diastolicByte, _diastolicByte + 2),
      ),
      heartRate: btData.toInt16(_heartRateByte, _heartRateByte + 2),
    );
    return HwMeasurementResult(
      resultState: ResultState.success,
      measurementDt: DateTime.now(),
      measurement: measurementCreateModel,
    );
  }
}
