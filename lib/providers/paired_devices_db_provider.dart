import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/model/measurement/device.dart';
import 'package:scalesoft_app/providers/box_provider.dart';

@singleton
class PairedDevicesDbProvider extends BoxProvider<Device> {
  @override
  @PostConstruct(preResolve: true)
  Future<void> init() async => super.init();

  @override
  final String boxName = 'pairedDevicesBox';

  @override
  void registerAdapters() {}

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
