import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/tables/device_prototypes.dart';

class DeviceInstructions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get prototypeId => integer().references(DevicePrototypes, #id, onDelete: KeyAction.cascade)();

  IntColumn get index => integer()();

  TextColumn get languageCode => text()();

  TextColumn get instructionType => text()();

  TextColumn get instructionText => text().nullable()();

  BlobColumn get image => blob().nullable()();

  DateTimeColumn get lastModifiedTime => dateTime().nullable()();
}
