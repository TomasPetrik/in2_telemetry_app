import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/data/daos/care_plans_dao.dart';
import 'package:scalesoft_app/data/daos/device_prototypes_dao.dart';
import 'package:scalesoft_app/data/daos/device_instruction_dao.dart';
import 'package:scalesoft_app/data/daos/devices_dao.dart';
import 'package:scalesoft_app/data/daos/logs_dao.dart';
import 'package:scalesoft_app/data/daos/measurements_dao.dart';
import 'package:scalesoft_app/data/daos/users_dao.dart';
import 'package:scalesoft_app/data/daos/when_templates_dao.dart';
import 'package:scalesoft_app/data/entities/enums/instruction_type.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_activity.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_author.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/care_plan_version.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_aggregated.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/fulfillment_evaluation_item.dart';
import 'package:scalesoft_app/data/entities/json_entities/list_converters.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/measurement_thresholds.dart';
import 'package:scalesoft_app/data/migrations.dart';
import 'package:scalesoft_app/data/tables/app_settings.dart';
import 'package:scalesoft_app/data/tables/care_plans.dart';
import 'package:scalesoft_app/data/tables/device_prototypes.dart';
import 'package:scalesoft_app/data/tables/device_instructions.dart';
import 'package:scalesoft_app/data/tables/devices.dart';
import 'package:scalesoft_app/data/tables/log_events.dart';
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

part 'app_database.drift.dart';

@singleton
@DriftDatabase(
  tables: [
    CarePlans,
    Users,
    WhenTemplates,
    DevicePrototypes,
    DeviceInstructions,
    Devices,
    Measurements,
    PhysicalDevices,
    AppSettings,
    LogEvents,
  ],
  daos: [
    UsersDao,
    LogsDao,
    MeasurementsDao,
    WhenTemplatesDao,
    CarePlansDao,
    DevicePrototypesDao,
    DeviceInstructionsDao,
    DevicesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        if (kDebugMode) {
          await validateDatabaseSchema();
        }
        await customStatement('PRAGMA foreign_keys = ON');
        await customStatement('PRAGMA journal_mode=WAL;');
      },
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: upgradeStrategy,
    );
  }

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        ...super.allSchemaEntities,
        Index(
          'UQ_PhysicalDevice',
          'CREATE UNIQUE INDEX IF NOT EXISTS UQ_PhysicalDevice ON "physical_devices" ("identifier", COALESCE("manufacturer", \'\'), "model_name");',
        ),
      ];
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Uncomment to log db statements: (cross-isolate synchronization might break)
    // final dbFolder = await getApplicationDocumentsDirectory();
    // final file = File(p.join(dbFolder.path, 'db.sqlite'));
    //
    // // Uncomment to reset database on app startup - useful for development
    // // if (await file.exists()) {
    // //   await file.delete();
    // // }
    //
    // return NativeDatabase.createInBackground(file, logStatements: true);

    return driftDatabase(
      name: 'db',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    );
  });
}
