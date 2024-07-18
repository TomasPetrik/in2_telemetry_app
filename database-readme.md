# Drift

## Changing database entities
- Update a table in `data/tables`
- Bump `SchemaVersion` in `data/app_database.dart`
- Run `GenerateMigrations.ps1` to create a new schema version
- Add a new migration to data/migrations.dart

## Example migrations

### Add a new non-nullable column (with a default value)
```dart
from1To2 (m, schema) async {
  await m.alterTable(
    TableMigration(
      schema.carePlans,
      columnTransformer: {
        schema.carePlans.testColumn: const Constant<String>('default value'),
      },
      newColumns: [schema.carePlans.testColumn],
    ),
  );
}
```

### Add a new column (without a default value)
```dart
from2To3(m, schema) async {
  await m.addColumn(schema.carePlans, schema.carePlans.scheduledStart);
}
```

### Custom query in migration
```dart
from3To4(m, schema) async {
  final rows = await schema.database.customSelect(
    'select "target_user_muid" from "care_plans" where "id">0 limit 3',
  ).get();

  await schema.database.customStatement("...");
}
```

## See also
[Documentation](https://drift.simonbinder.eu/docs/)