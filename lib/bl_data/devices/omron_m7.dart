import 'package:async/async.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/bl_data/devices/device_connector.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';

class OmronM7 implements DeviceConnector {
  final measurementUuid = Guid('2A35');

  @override
  Future<Stream<List<int>>> getDataStream(BluetoothDevice device) async {
    var services = await device.discoverServices();
    var characteristics = services
        .map((service) => service.characteristics)
        .expand((x) => x)
        .toList();
    var measurementCharacteristic = characteristics
        .firstWhere((chara) => chara.characteristicUuid == measurementUuid);
    return measurementCharacteristic.onValueReceived;
    // var data = List<int>.empty(growable: true);

  }

  @override
  HwMeasurementResult parseMeasurementResult(List<int> data) {
    // TODO: implement parseMeasurementResult
    throw UnimplementedError();
  }
}
