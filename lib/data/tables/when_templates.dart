import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/entities/enums/when_code.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/time_only.dart';
import 'package:scalesoft_app/data/tables/users.dart';

class WhenTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer().references(Users, #id, onDelete: KeyAction.cascade)();

  TextColumn get whenCode => textEnum<WhenCode>()();

  TextColumn get start => text().map(TimeOnly.converter)();

  TextColumn get end => text().map(TimeOnly.converter)();

  TextColumn get userEditMin => text().map(TimeOnly.converter).nullable()();

  TextColumn get userEditMax => text().map(TimeOnly.converter).nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, whenCode},
      ];
}
