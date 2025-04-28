import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/bl_data/connectors/device_connector.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement/blood_pressure_value.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/measurement_create_model.dart';
import 'package:scalesoft_app/utils/extensions/int_extensions.dart';
import 'package:scalesoft_app/utils/extensions/uint8_list_extension.dart';

class OximeterDeviceConnector implements DeviceConnector {
  final _wirteUuid = Guid('FF01');
  final _readUuid = Guid('FF02');

  @override
  Future<HwMeasurementResult> loadMeasurement(BluetoothDevice device,
      List<BluetoothCharacteristic> characteristics) async {
    final writeCharacteristic =
        characteristics.firstWhereOrNull((chara) => chara.uuid == _wirteUuid);
    var readCharacteristic = characteristics.firstWhereOrNull(
      (chara) => chara.uuid == _readUuid,
    );
    if (writeCharacteristic == null || readCharacteristic == null) {
      debugPrint("characteristic not found");
      device.disconnect();
      return HwMeasurementResult(
          resultState: ResultState.noData, measurementDt: DateTime.now());
    }

    List<int> measurementBytes = [];
    List<MeasurementCreateModel> measurements = [];

    int packetNumber = -1;
    var onComplete = Completer();
    var subscription = readCharacteristic.onValueReceived.listen((data) async {
      if (data.first == 0xF3) {
        data.removeRange(0, 3);
      }
      measurementBytes.addAll(data);

      if (measurementBytes.length >= 24) {
        packetNumber = measurementBytes[1];
        measurements
            .add(bytesToMeasurement(measurementBytes.sublist(0, 24)));
        if (packetNumber > 9){
          onComplete.complete();
        }
        measurementBytes.removeRange(0, 24);
        if (packetNumber == 9) {
          await writeCharacteristic.write(_nextMeasurementRequest());
        }
      }
    });
    device.cancelWhenDisconnected(subscription);
    await readCharacteristic.setNotifyValue(true);

    await writeCharacteristic.write(_setCurrentTimeRequest());

    await writeCharacteristic.write(_firstMeasurementRequest());

    // await Future.delayed(const Duration(seconds: 1));
    await onComplete.future;
    await subscription.cancel();
    writeCharacteristic.write(_deleteMeasurementRequest());

    if (measurements.isEmpty) {
      debugPrint("no data received");
      device.disconnect();
      return HwMeasurementResult(
          resultState: ResultState.noData, measurementDt: DateTime.now());
    }

    return HwMeasurementResult(
      resultState: ResultState.success,
      measurementDt: DateTime.now(),
      measurement: measurements.last,
    );
  }

  MeasurementCreateModel bytesToMeasurement(List<int> data) {
    return MeasurementCreateModel(
      0,
      data.sublist(8, 14).toDateTimePO60(),
      MeasurementType.oxygenSaturation,
      oxygenSaturation: data[19],
      heartRate: data[22] + (data[14].getBit(3) << 7),
    );
  }

  List<int> _setCurrentTimeRequest() {
    var time = DateTime.now();
    var bytes = [
      0x83,
      time.year - 2000,
      time.month,
      time.day,
      time.hour,
      time.minute,
      time.second,
      0,
      0
    ];
    return _addChecksum(bytes);
  }

  List<int> _firstMeasurementRequest() {
    return _addChecksum([0x99, 0]);
  }

  List<int> _nextMeasurementRequest() {
    return _addChecksum([0x99, 1]);
  }

  List<int> _deleteMeasurementRequest() {
    return _addChecksum([0x99, 127]);
  }

  List<int> _addChecksum(List<int> data) {
    int checksum = 0;
    for (var d in data) {
      checksum += d;
    }
    checksum &= 0x7f;
    data.add(checksum);
    return data;
  }
}
