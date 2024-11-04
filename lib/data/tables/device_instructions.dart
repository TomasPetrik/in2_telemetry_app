import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/entities/enums/instruction_type.dart';
import 'package:scalesoft_app/data/tables/device_prototypes.dart';
import 'package:scalesoft_app/data/tables/users.dart';

class DeviceInstructions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer()();

  IntColumn get prototypeId => integer().references(DevicePrototypes, #id, onDelete: KeyAction.cascade)();

  IntColumn get userId => integer().references(Users, #id, onDelete: KeyAction.cascade)();

  IntColumn get index => integer()();

  TextColumn get languageCode => text()();

  TextColumn get instructionType => textEnum<InstructionType>()();

  TextColumn get instructionText => text()();

  BlobColumn get image => blob().nullable()();

  DateTimeColumn get lastModifiedTime => dateTime()();
}
