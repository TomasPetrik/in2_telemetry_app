import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scalesoft_app/data/tables/care_plans.dart';
import 'package:scalesoft_app/data/migrations.dart';
import 'package:drift_dev/api/migrations.dart';

import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@singleton
@DriftDatabase(tables: [CarePlans])
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
      },
      onCreate: (Migrator m) async {
        await m.createAll();
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
