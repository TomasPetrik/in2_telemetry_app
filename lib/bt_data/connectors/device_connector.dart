import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:scalesoft_app/model/hw_measurement_result.dart';

abstract class DeviceConnector {
  Future<HwMeasurementResult> loadMeasurement(BluetoothDevice device, List<BluetoothCharacteristic> characteristics);
}