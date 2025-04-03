import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/bl_data/devices/device_connector.dart';
import 'package:scalesoft_app/bl_data/devices/omron_m7.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';

var deviceConnectorByName = {
  "M7" : OmronM7(),
};

class BlConnection {
  BluetoothDevice device;
  late DeviceConnector connector;

  BlConnection(this.device) {
    connector = deviceConnectorByName[device.advName] as DeviceConnector;
  }

  Future<Stream<List<int>>> getDataStream() async {
    return connector.getDataStream(device);
  }

  // Future<HwMeasurementResult> loadMeasurement() async {
  //   return connector.loadMeasurement(device);
  // }
}