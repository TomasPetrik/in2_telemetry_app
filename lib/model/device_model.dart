import 'package:scalesoft_app/data/entities/combined_entities/device_db_result.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/device_prototype_model.dart';

class DeviceModel extends DeviceCreateModel {
  final int id;
  final DateTime addedAt;
  final int physicalDeviceId;
  final bool isPersonal;
  final DateTime? lastMeasurementTime;

  DeviceModel(
    this.id,
    super.deviceIdentifier,
    super.prototype,
    this.physicalDeviceId,
    this.addedAt, {
    this.isPersonal = false,
    super.isPaired = false,
    super.assignedIdentifier,
    super.bluetoothAddress,
    this.lastMeasurementTime,
  });

  factory DeviceModel.fromEntity(DeviceDbResult entity) {
    final prototype = DevicePrototypeModel.fromEntity(entity.prototype);

    return DeviceModel(
      entity.device.id,
      entity.physicalDevice.identifier,
      prototype,
      entity.physicalDevice.id,
      entity.device.addedAt,
      isPersonal: entity.device.isPersonal,
      isPaired: entity.physicalDevice.isPaired,
      assignedIdentifier: entity.device.assignedIdentifier,
      bluetoothAddress: entity.device.bluetoothAddress,
      lastMeasurementTime: entity.device.lastMeasurementTime,
    );
  }
}
