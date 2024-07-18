import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/combined_entities/device_db_result.dart';
import 'package:scalesoft_app/data/tables/devices.dart';
import 'package:scalesoft_app/data/tables/physical_devices.dart';

part 'devices_dao.drift.dart';

@DriftAccessor(tables: [Devices, PhysicalDevices])
class DevicesDao extends DatabaseAccessor<AppDatabase> with _$DevicesDaoMixin {
  DevicesDao(super.db);

  Future<PhysicalDevice?> getPhysicalDevice(String? manufacturer, String modelName, String identifier) async {
    return await (select(physicalDevices)
          ..where((x) => x.manufacturer.equalsNullable(manufacturer))
          ..where((x) => x.modelName.equals(modelName))
          ..where((x) => x.identifier.equals(identifier)))
        .getSingleOrNull();
  }

  Future<PhysicalDevice> createPhysicalDevice(PhysicalDevicesCompanion companion) async {
    return await into(physicalDevices).insertReturning(companion, onConflict: DoNothing());
  }

  Future<List<DeviceDbResult>> getByUser(int userId) async {
    final query = select(devices).join([
      innerJoin(physicalDevices, devices.physicalDeviceId.equalsExp(physicalDevices.id)),
      innerJoin(devicePrototypes, devices.prototypeId.equalsExp(devicePrototypes.id)),
    ])
      ..where(devices.userId.equals(userId));

    final result = await query
        .map(
          (row) =>
              DeviceDbResult(row.readTable(devices), row.readTable(devicePrototypes), row.readTable(physicalDevices)),
        )
        .get();
    return result;
  }

  Future<List<DeviceDbResult>> getByIds(Iterable<int> deviceIds) async {
    final query = select(devices).join([
      innerJoin(physicalDevices, devices.physicalDeviceId.equalsExp(physicalDevices.id)),
      innerJoin(devicePrototypes, devices.prototypeId.equalsExp(devicePrototypes.id)),
    ])
      ..where(devices.id.isIn(deviceIds));

    final result = await query
        .map(
          (row) =>
              DeviceDbResult(row.readTable(devices), row.readTable(devicePrototypes), row.readTable(physicalDevices)),
        )
        .get();
    return result;
  }

  Future<List<DeviceDbResult>> getAll() async {
    final query = select(devices).join([
      innerJoin(physicalDevices, devices.physicalDeviceId.equalsExp(physicalDevices.id)),
      innerJoin(devicePrototypes, devices.prototypeId.equalsExp(devicePrototypes.id)),
    ]);

    final result = await query
        .map(
          (row) =>
          DeviceDbResult(row.readTable(devices), row.readTable(devicePrototypes), row.readTable(physicalDevices)),
    )
        .get();
    return result;
  }

  Future<DeviceDbResult?> getByPhysicalDeviceAndUser(int userId, int physicalDeviceId) async {
    final query = select(devices).join([
      innerJoin(physicalDevices, devices.physicalDeviceId.equalsExp(physicalDevices.id)),
      innerJoin(devicePrototypes, devices.prototypeId.equalsExp(devicePrototypes.id)),
    ])
      ..where(devices.userId.equals(userId))
      ..where(physicalDevices.id.equals(physicalDeviceId));

    final result = await query
        .map(
          (row) =>
              DeviceDbResult(row.readTable(devices), row.readTable(devicePrototypes), row.readTable(physicalDevices)),
        )
        .getSingleOrNull();
    return result;
  }

  Future<List<DeviceDbResult>> getAllPairedDevices() async {
    final query = select(devices).join([
      innerJoin(physicalDevices, devices.physicalDeviceId.equalsExp(physicalDevices.id)),
      innerJoin(devicePrototypes, devices.prototypeId.equalsExp(devicePrototypes.id)),
    ])
      ..where(physicalDevices.isPaired.equals(true))
      ..orderBy([OrderingTerm(expression: devices.assignedIdentifier.length, mode: OrderingMode.desc)]);

    final result = await query
        .map(
          (row) =>
              DeviceDbResult(row.readTable(devices), row.readTable(devicePrototypes), row.readTable(physicalDevices)),
        )
        .get();
    return result;
  }

  Future<int> create(DevicesCompanion companion) async {
    return await into(devices).insert(companion, onConflict: DoUpdate((old) => companion));
  }

  Future<int> updateDevice(int deviceId, DevicesCompanion changes) async {
    return await (update(devices)..where((x) => x.id.equals(deviceId))).write(changes);
  }

  Future<void> removeAll(Iterable<int> deviceIds) async {
    await (delete(devices)..where((x) => x.id.isIn(deviceIds))).go();
  }

  Future<void> updatePhysicalDevice(int physicalDeviceId, PhysicalDevicesCompanion changes) async {
    await update(physicalDevices).write(changes);
  }
}
