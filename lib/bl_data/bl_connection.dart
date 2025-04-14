import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/bl_data/devices/device_connector.dart';
import 'package:scalesoft_app/bl_data/devices/omron_m7.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';

var deviceConnectorByName = {
  "BLESmart" : OmronM7(),
};

class BlConnection {
  BluetoothDevice device;
  DeviceCreateModel deviceCreateModel;
  late DeviceConnector connector;

  BlConnection(this.device, this.deviceCreateModel) {
    connector = deviceConnectorByName[deviceCreateModel.prototype.bluetoothName] as DeviceConnector;
  }

  Future<HwMeasurementResult> getHwMeasurementResult() async {
    var services = await device.discoverServices();

    var characteristics = services
        .map((service) => service.characteristics)
        .toList()
        .expand((x) => x)
        .toList();
    return connector.loadMeasurement(device, characteristics);
  }

  // Future<HwMeasurementResult> loadMeasurement() async {
  //   return connector.loadMeasurement(device);
  // }
}