import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class PairedDevicesDbProvider extends BoxProvider<Device> {
  @override
  final String boxName = 'pairedDevicesBox';

  @override
  void registerAdapters() {
    Hive.registerAdapter(DeviceModelTypeAdapter());
    Hive.registerAdapter(ActionButtonTypeAdapter());
  }

  Device? get(String deviceIdentifier) {
    final foundDevice = box.get(deviceIdentifier.toLowerCase());
    return foundDevice;
  }

  Future<void> add(Device device) async {
    await box.put(device.deviceIdentifier!.toLowerCase(), device);
  }

  Future<void> remove(Device device) async {
    await box.delete(device.deviceIdentifier!.toLowerCase());
  }
}
