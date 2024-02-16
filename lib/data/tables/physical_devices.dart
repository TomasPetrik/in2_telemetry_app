import 'package:drift/drift.dart';

/// Represents a single physical device. Multiple device entities can refer to a single physical device.
/// Typically, this can occur with personal devices - one device may be used for multiple user accounts.
/// While devices can be deleted, physical devices shouldn't ever be deleted, to preserve pairing status.
class PhysicalDevices extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get identifier => text()();

  TextColumn get manufacturer => text().nullable().withDefault(const Constant(null))();

  TextColumn get modelName => text()();

  BoolColumn get isPaired => boolean().withDefault(const Constant(false))();

// Unique constraint is created in app_database.dart - null coalescing only works in CREATE CONSTRAINT statements.
}
