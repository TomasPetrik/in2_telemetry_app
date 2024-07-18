import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/tables/device_prototypes.dart';
import 'package:scalesoft_app/data/tables/physical_devices.dart';
import 'package:scalesoft_app/data/tables/users.dart';

class Devices extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #id, onDelete: KeyAction.cascade)();

  IntColumn get physicalDeviceId => integer().references(PhysicalDevices, #id)();

  IntColumn get prototypeId => integer().references(DevicePrototypes, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get addedAt => dateTime()();

  BoolColumn get isPersonal => boolean().withDefault(const Constant(false))();

  TextColumn get assignedIdentifier => text().nullable()();

  TextColumn get bluetoothAddress => text().nullable()();

  DateTimeColumn get lastMeasurementTime => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, physicalDeviceId},
      ];
}
