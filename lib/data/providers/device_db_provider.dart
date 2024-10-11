import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/device/assigned_device_contract.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/combined_entities/device_db_result.dart';
import 'package:scalesoft_app/model/device_create_model.dart';
import 'package:scalesoft_app/model/device_model.dart';
import 'package:scalesoft_app/utils/extensions/iterable_extensions.dart';

@injectable
class DeviceDbProvider {
  final AppDatabase _database;

  DeviceDbProvider(
    this._database,
  );

  Future<void> updateUserDevices(int userId, List<AssignedDeviceContract> newDevices) async {
    final existingDevices = await _database.devicesDao.getByUser(userId);

    final allowedPrototypes = await _database.devicePrototypesDao.getByUser(userId);

    final devicesToRemove = existingDevices
        .where((existingDevice) => !existingDevice.device.isPersonal)
        .where(
          (existingDevice) => newDevices.none(
            (x) => _areEquivalent(x, existingDevice),
          ),
        )
        .map((x) => x.device.id);

    await _database.devicesDao.removeAll(devicesToRemove);

    for (final newDevice in newDevices) {
      final existingDevice =
          existingDevices.firstWhereOrNull((existingDevice) => _areEquivalent(newDevice, existingDevice));

      if (existingDevice == null) {
        final devicePrototype = allowedPrototypes.firstWhereOrNull(
          (x) =>
              x.templateData.modelName == newDevice.modelName &&
              x.templateData.deviceManufacturer == newDevice.deviceManufacturer,
        );
        if (devicePrototype == null) {
          continue;
        }

        final physicalDevice = await getOrCreatePhysicalDevice(
          newDevice.deviceManufacturer,
          newDevice.modelName,
          newDevice.deviceIdentifier,
        );

        final createCompanion = DevicesCompanion.insert(
          userId: userId,
          physicalDeviceId: physicalDevice.id,
          prototypeId: devicePrototype.id,
          addedAt: DateTime.now(),
          assignedIdentifier: Value(newDevice.assignedIdentifier),
          bluetoothAddress: Value(newDevice.bluetoothAddress),
        );
        await _database.devicesDao.create(createCompanion);
        continue;
      }

      final updateCompanion = DevicesCompanion(
        assignedIdentifier: Value(newDevice.assignedIdentifier),
        bluetoothAddress: Value(newDevice.bluetoothAddress),
      );
      await _database.devicesDao.updateDevice(existingDevice.device.id, updateCompanion);
    }
  }

  bool _areEquivalent(AssignedDeviceContract contract, DeviceDbResult entity) {
    return contract.modelName == entity.physicalDevice.modelName &&
        contract.deviceManufacturer == entity.physicalDevice.manufacturer &&
        contract.deviceIdentifier == entity.physicalDevice.identifier;
  }

  Future<PhysicalDevice> getOrCreatePhysicalDevice(
    String? manufacturer,
    String modelName,
    String identifier,
  ) async {
    final existingEntity = await _database.devicesDao.getPhysicalDevice(manufacturer, modelName, identifier);
    if (existingEntity != null) {
      return existingEntity;
    }

    final companion = PhysicalDevicesCompanion.insert(
      identifier: identifier,
      modelName: modelName,
      manufacturer: Value(manufacturer),
    );
    return await _database.devicesDao.createPhysicalDevice(companion);
  }

  Future<List<DeviceModel>> getByUser(int userId) async {
    final entities = await _database.devicesDao.getByUser(userId);
    return entities.map(DeviceModel.fromEntity).toList();
  }

  Future<List<DeviceModel>> getByIds(Iterable<int> deviceIds) async {
    final entities = await _database.devicesDao.getByIds(deviceIds);
    return entities.map(DeviceModel.fromEntity).toList();
  }

  Future<List<DeviceModel>> getAll() async {
    final entities = await _database.devicesDao.getAll();
    return entities.map(DeviceModel.fromEntity).toList();
  }

  Future<List<DeviceModel>> getDistinctPairedDevices() async {
    final entities = await _database.devicesDao.getAllPairedDevices();
    final distinct = entities.distinctBy((x) => x.physicalDevice.id);

    return distinct.map(DeviceModel.fromEntity).toList();
  }

  Future<void> removeDevice(int deviceId) async {
    await _database.devicesDao.removeAll([deviceId]);
  }

  Future<void> markAsUnpaired(int physicalDeviceId) async {
    const companion = PhysicalDevicesCompanion(isPaired: Value(false));

    await _database.devicesDao.updatePhysicalDevice(physicalDeviceId, companion);
  }

  /// Marks the specified [device] of user with [userId] as paired.
  /// If the user has no such device, it's created and marked as a personal device.
  Future<DeviceModel> markDeviceAsPaired(int userId, DeviceCreateModel device) async {
    final physicalDevice = await getOrCreatePhysicalDevice(
      device.prototype.deviceManufacturer,
      device.prototype.modelName,
      device.deviceIdentifier,
    );

    const changes = PhysicalDevicesCompanion(isPaired: Value(true));
    await _database.devicesDao.updatePhysicalDevice(physicalDevice.id, changes);

    final existingDevice = await _database.devicesDao.getByPhysicalDeviceAndUser(userId, physicalDevice.id);
    if (existingDevice != null) {
      return DeviceModel.fromEntity(existingDevice);
    } else {
      final companion = DevicesCompanion.insert(
        userId: userId,
        physicalDeviceId: physicalDevice.id,
        prototypeId: device.prototype.id,
        addedAt: DateTime.now(),
        assignedIdentifier: Value(device.assignedIdentifier),
        bluetoothAddress: Value(device.bluetoothAddress),
        isPersonal: Value(device.isPersonal),
      );
      await _database.devicesDao.create(companion);
      final newDevice = await _database.devicesDao.getByPhysicalDeviceAndUser(userId, physicalDevice.id);

      return DeviceModel.fromEntity(newDevice!);
    }
  }

  Future<void> updateDevice(int deviceId, DevicesCompanion changes) async {
    await _database.devicesDao.updateDevice(deviceId, changes);
  }
}
