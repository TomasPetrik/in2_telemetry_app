import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/dto/measurement/device.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class PairedDevicesDbProvider extends BoxProvider<Device> {
  @override
  final String boxName = 'pairedDevicesBox';

  @override
  void registerAdapters() {
    Hive.registerAdapter(DeviceModelAdapter());
    Hive.registerAdapter(ActionButtonTypeAdapter());
  }

  Device? get(String macAddress) {
    final foundDevice = box.get(macAddress);
    return foundDevice;
  }

  Future<void> add(Device device) async {
    await box.put(device.macAddress!, device);
  }

  Future<void> remove(Device device) async {
    await box.delete(device.macAddress);
  }
}
