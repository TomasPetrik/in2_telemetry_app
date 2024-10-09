import 'package:drift/drift.dart';

class DeviceInstructions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer()();

  IntColumn get prototypeId => integer()();

  IntColumn get index => integer()();

  TextColumn get languageCode => text()();

  TextColumn get instructionType => text()();

  TextColumn get instructionText => text()();

  BlobColumn get image => blob().nullable()();

  DateTimeColumn get lastModifiedTime => dateTime()();
}
