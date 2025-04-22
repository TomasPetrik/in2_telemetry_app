import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/bl_data/devices/blood_pressure_device.dart';
import 'package:scalesoft_app/bl_data/devices/device_connector.dart';
import 'package:scalesoft_app/bl_data/devices/thermometer_device.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';

var deviceConnectorByName = {

};

class BlConnection {
  BluetoothDevice device;
  DeviceCreateModel deviceCreateModel;
  MeasurementType measurementType;
  late DeviceConnector connector;

  BlConnection(this.device, this.deviceCreateModel, this.measurementType) {
    var connector = deviceConnectorByName[deviceCreateModel.prototype.bluetoothName];
    if (connector != null){
      this.connector = connector;
      return;
    }
    switch (measurementType) {
      case  MeasurementType.temperature:
        this.connector = ThermometerDevice();
      case MeasurementType.bloodPressure:
        this.connector = BloodPressureDevice();
        default:
          UnimplementedError("Device connector not implemented for this measurement type");
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