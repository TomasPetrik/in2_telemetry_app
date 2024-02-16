import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_author.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_version.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_aggregated.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/blood_pressure_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/heart_rate_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/overall_health_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/oxygen_saturation_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/shortness_of_breath_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement_thresholds/temperature_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/list_converters.dart';
import 'package:scalesoft_app/data/migrations.dart';
import 'package:scalesoft_app/data/tables/app_settings.dart';
import 'package:scalesoft_app/data/tables/care_plans.dart';
import 'package:scalesoft_app/data/tables/device_prototypes.dart';
import 'package:scalesoft_app/data/tables/devices.dart';
import 'package:scalesoft_app/data/tables/log_events.dart';
import 'package:scalesoft_app/data/tables/measurement_thresholds.dart';
import 'package:scalesoft_app/data/tables/measurements.dart';
import 'package:scalesoft_app/data/tables/physical_devices.dart';
import 'package:scalesoft_app/data/tables/users.dart';
import 'package:scalesoft_app/data/tables/when_templates.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/time_only.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/data/entities/enums/when_code.dart';
import 'package:scalesoft_app/data/entities/json_entities/device/device_prototype_template.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/time_setting.dart';
import 'package:scalesoft_app/data/entities/enums/measurement_type.dart';
import 'package:scalesoft_app/data/entities/enums/shortness_of_breath_level.dart';
import 'package:scalesoft_app/data/entities/enums/overall_health_state.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';
import 'package:scalesoft_app/data/entities/json_entities/measurement/blood_pressure_value.dart';

part 'app_database.g.dart';

@singleton
@DriftDatabase(
  tables: [
    CarePlans,
    Users,
    MeasurementThresholds,
    WhenTemplates,
    DevicePrototypes,
    Devices,
    Measurements,
    PhysicalDevices,
    AppSettings,
    LogEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        if (kDebugMode) {
          await validateDatabaseSchema();
        }
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onCreate: (Migrator m) async {
        await m.createAll();
        await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS UQ_PhysicalDevice ON "physical_devices" ("identifier", COALESCE("manufacturer", \'\'), "model_name");');
      },
      onUpgrade: upgradeStrategy,
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
