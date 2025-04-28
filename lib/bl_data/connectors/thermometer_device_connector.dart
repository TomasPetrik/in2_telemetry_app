import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/bl_data/connectors/device_connector.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/measurement_create_model.dart';
import 'package:scalesoft_app/utils/extensions/uint8_list_extension.dart';

class ThermometerDeviceConnector extends DeviceConnector {
  final _measurementUuid = Guid('2A1C');

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

    var lastReceived = DateTime.now();
    var dataArray = List<List<int>>.empty(growable: true);
    final subscription = measurementCharacteristic.onValueReceived.listen(
      (data) {
        dataArray.add(data);
        lastReceived = DateTime.now();
        // debugPrint("got data");
      },
    );
    await measurementCharacteristic.setNotifyValue(true);

    // Wait until no incoming measurement in 0.5 second
    while (DateTime.now().difference(lastReceived).inMilliseconds < 500) {
      await Future.delayed(const Duration(milliseconds: 200));
      // debugPrint('time diff: ${DateTime.now().difference(lastReceived).inMilliseconds}');
    }

    await subscription.cancel();

    var btData = dataArray.last;

    var measurementCreateModel = MeasurementCreateModel(
      0,
      btData.toTimestamp(5, 11),
      MeasurementType.temperature,
      temperature: btData.toFloat(1),
    );

    debugPrint('created measurement');

    return HwMeasurementResult(
      resultState: ResultState.success,
      measurementDt: DateTime.now(),
      measurement: measurementCreateModel,
    );
  }
}
