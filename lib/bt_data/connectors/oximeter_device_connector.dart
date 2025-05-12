import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/bt_data/connectors/device_connector.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';
import 'package:scalesoft_app/model/measurement_create_model.dart';
import 'package:scalesoft_app/utils/extensions/int_extensions.dart';
import 'package:scalesoft_app/utils/extensions/uint8_list_extension.dart';

class OximeterDeviceConnector implements DeviceConnector {
  final _writeUuid = Guid('FF01');
  final _readUuid = Guid('FF02');
  final _frameLength = 24;
  final _timeSyncLength = 3;
  final _lastPacketIdx = 9;
  final _packetNumberByte = 1;
  final _timeSyncHeader = 0xF3;
  final _setTimeHeader = 0x83;
  final _measurementRequestHeader = 0x99;

  @override
  Future<HwMeasurementResult> loadMeasurement(BluetoothDevice device,
      List<BluetoothCharacteristic> characteristics) async {
    final writeCharacteristic =
        characteristics.firstWhereOrNull((chara) => chara.uuid == _writeUuid);
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
      if (data.first == _timeSyncHeader) {
        data.removeRange(0, _timeSyncLength);
      }
      measurementBytes.addAll(data);

      if (measurementBytes.length >= _frameLength) {
        packetNumber = measurementBytes[_packetNumberByte];
        measurements
            .add(bytesToMeasurement(measurementBytes.sublist(0, _frameLength)));
        if (packetNumber > _lastPacketIdx) {
          onComplete.complete();
        }
        measurementBytes.removeRange(0, _frameLength);
        if (packetNumber == _lastPacketIdx) {
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
          resultState: ResultState.noData, measurementDt: DateTime.now(),);
    }

    return HwMeasurementResult(
      resultState: ResultState.success,
      measurementDt: DateTime.now(),
      measurement: measurements.last,
    );
  }

  MeasurementCreateModel bytesToMeasurement(List<int> data) {
    const userId = 0;
    const dateTimeByte = 8;
    const dateTimeLength = 6;
    const oxygenSaturationByte = 19;
    const heartRateByte = 22;
    const heartRateAddonByte = 14;
    const heartRateAddonBit = 3;
    return MeasurementCreateModel(
      userId,
      data
          .sublist(dateTimeByte, dateTimeByte + dateTimeLength)
          .toDateTimePO60(),
      MeasurementType.oxygenSaturation,
      oxygenSaturation: data[oxygenSaturationByte],
      // first bit of heart rate is stored in the third bit of byte 14
      heartRate: data[heartRateByte] +
          (data[heartRateAddonByte].getBit(heartRateAddonBit) << 7),
    );
  }

  List<int> _setCurrentTimeRequest() {
    var time = DateTime.now();
    var bytes = [
      _setTimeHeader,
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
    return _addChecksum([_measurementRequestHeader, 0]);
  }

  List<int> _nextMeasurementRequest() {
    return _addChecksum([_measurementRequestHeader, 1]);
  }

  List<int> _deleteMeasurementRequest() {
    return _addChecksum([_measurementRequestHeader, 127]);
  }

  List<int> _addChecksum(List<int> data) {
    int checksum = 0;
    for (final d in data) {
      checksum += d;
    }
    // set first bit of checksum to zero
    checksum &= 0x7f;
    data.add(checksum);
    return data;
  }
}
