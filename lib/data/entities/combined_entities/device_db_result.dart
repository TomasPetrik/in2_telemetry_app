import 'package:scalesoft_app/data/app_database.dart';

class DeviceDbResult {
  final Device device;
  final DevicePrototype prototype;
  final PhysicalDevice physicalDevice;

  DeviceDbResult(this.device, this.prototype, this.physicalDevice);
}
