import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/entities/json_entities/list_converters.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/time_setting.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Hospitals are not stored in database, they are defined in configuration.
  IntColumn get hospitalId => integer()();

  TextColumn get muid => text()();

  IntColumn get parentId => integer().references(Users, #id, onDelete: KeyAction.cascade).nullable()();

  TextColumn get firstNames => text()();

  TextColumn get lastNames => text()();

  TextColumn get phoneNumbers => text().map(const StringListConverter())();

  TextColumn get emailAddresses => text().map(const StringListConverter())();

  DateTimeColumn get lastActive => dateTime().nullable()();

  TextColumn get authToken => text().map(AuthToken.converter)();

  TextColumn get permissions => text().map(const StringListConverter())();

  BoolColumn get isSessionExpired => boolean().withDefault(const Constant(false))();

  DateTimeColumn get lastSyncAt => dateTime()();

  BoolColumn get lastSyncFailed => boolean().withDefault(const Constant(false))();

  TextColumn get notificationIds => text().map(const IntListConverter()).withDefault(const Constant('[]'))();

  TextColumn get timeSettings => text().map(TimeSetting.listConverter)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {hospitalId, muid},
      ];
}
