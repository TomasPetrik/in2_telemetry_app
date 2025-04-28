import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/bl_data/connectors/blood_pressure_device_connector.dart';
import 'package:scalesoft_app/bl_data/connectors/device_connector.dart';
import 'package:scalesoft_app/bl_data/connectors/oximeter_device_connector.dart';
import 'package:scalesoft_app/bl_data/connectors/thermometer_device_connector.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';

Map<String, DeviceConnector> deviceConnectorByName = {
  'BM77' : BloodPressureDeviceConnector(),
  'BLESmart' : BloodPressureDeviceConnector(),
  'FT95' : ThermometerDeviceConnector(),
  'PO60' : OximeterDeviceConnector(),
};

class BlConnection {
  BluetoothDevice device;
  late DeviceConnector connector;

  BlConnection(this.device,) {
    debugPrint(device.advName.split('_').first);
    var connector = deviceConnectorByName[device.advName.split('_').first];
    if (connector != null){
      this.connector = connector;
      return;
    }
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