import 'package:scalesoft_app/model/device_prototype_model.dart';

class DeviceModel {
  final DevicePrototypeModel prototype;
  final String deviceIdentifier;
  final bool isPaired;
  final DateTime? addedAt;
  final bool isPersonal;
  final String? assignedIdentifier;
  final String? bluetoothAddress;
  final DateTime? lastMeasurementTime;

  DeviceModel(
    this.deviceIdentifier,
    this.prototype, {
    this.addedAt,
    this.isPersonal = false,
    this.isPaired = false,
    this.assignedIdentifier,
    this.bluetoothAddress,
    this.lastMeasurementTime,
  });
}
