import 'package:scalesoft_app/model/device_prototype_model.dart';

class DeviceCreateModel {
  final DevicePrototypeModel prototype;
  final String deviceIdentifier;
  bool isPaired;
  final String? assignedIdentifier;
  final String? bluetoothAddress;

  DeviceCreateModel(
    this.deviceIdentifier,
    this.prototype, {
    this.isPaired = false,
    this.assignedIdentifier,
    this.bluetoothAddress,
  });
}
