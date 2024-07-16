import 'package:drift/drift.dart';
import 'package:flutter/material.dart' hide Table;

class AppSettings extends Table {
  TextColumn get themeMode => textEnum<ThemeMode>()();

  TextColumn get languageCode => text()();

  BoolColumn get enableNotifications => boolean()();

  BoolColumn get notifyAtStartOfMeasurement => boolean()();

  BoolColumn get notify10minBeforeMeasurement => boolean()();

  IntColumn get lastHospitalId => integer()();

  TextColumn get currentCodeVerifier => text()();

  BoolColumn get showAllUsers => boolean()();

  BoolColumn get enableStagingHospitals => boolean().withDefault(const Constant(false))();
}
