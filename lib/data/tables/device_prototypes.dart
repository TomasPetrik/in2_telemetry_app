import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/entities/json_entities/device/device_prototype_template.dart';
import 'package:scalesoft_app/data/tables/users.dart';

class DevicePrototypes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer()();

  IntColumn get userId => integer().references(Users, #id, onDelete: KeyAction.cascade)();

  TextColumn get aboutUrl => text().nullable()();

  TextColumn get templateData => text().map(DevicePrototypeTemplate.converter)();
}
