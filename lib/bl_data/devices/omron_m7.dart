import 'dart:async';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/bl_data/devices/device_connector.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement/blood_pressure_value.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/measurement_create_model.dart';
import 'package:scalesoft_app/utils/extensions/uint8_list_extension.dart';

class OmronM7 implements DeviceConnector {
  final _measurementUuid = Guid('2A35');

  @override
  Future<HwMeasurementResult> loadMeasurement(BluetoothDevice device, List<BluetoothCharacteristic> characteristics) async {

    var measurementCharacteristic = characteristics.firstWhereOrNull(
          (chara) => chara.uuid == _measurementUuid,
    );
    if (measurementCharacteristic == null) {
      debugPrint("characteristic not found");
      device.disconnect();
      return HwMeasurementResult(resultState: ResultState.noData, measurementDt: DateTime.now());
    }

    var dataArray = List<List<int>>.empty(growable: true);
    final done = Completer<void>();
    final subscription = measurementCharacteristic.onValueReceived.listen(
          (data) {
        dataArray.add(data);
        debugPrint("got data");
      },
      onDone: done.complete,
    );
    // selectedBlDevice.cancelWhenDisconnected(measurementStream);
    await measurementCharacteristic.setNotifyValue(true);

    await Future.delayed(
      Duration(seconds: 2),
    );

    // await done.future;
    subscription.cancel();

    var btData = dataArray.last;
    var measurementCreateModel = MeasurementCreateModel(
      btData.toInt8(16, 17),
      btData.toTimestamp(7, 14),
      MeasurementType.bloodPressure,
      bloodPressure: BloodPressureValue(
        systolic: btData.toInt16(1, 3),
        diastolic: btData.toInt16(3, 5),
      ),
      heartRate: btData.toInt16(14, 16),
    );
    return HwMeasurementResult(
      resultState: ResultState.success,
      measurementDt: DateTime.now(),
      measurement: measurementCreateModel,
    );
  }
}
