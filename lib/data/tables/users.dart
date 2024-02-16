import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/entities/json_entities/list_converters.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/time_setting.dart';

const emptyList = Constant('[]');

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Hospitals are not stored in database, they are defined in configuration.
  IntColumn get hospitalId => integer()();

  TextColumn get muid => text()();

  IntColumn get parentId => integer().references(Users, #id).nullable()();

  TextColumn get firstNames => text().map(const StringListConverter())();

  TextColumn get lastNames => text().map(const StringListConverter()).withDefault(emptyList)();

  TextColumn get phoneNumbers => text().map(const StringListConverter()).withDefault(emptyList)();

  TextColumn get emailAddresses => text().map(const StringListConverter()).withDefault(emptyList)();

  DateTimeColumn get lastActive => dateTime().nullable()();

  TextColumn get authToken => text().map(AuthToken.converter)();

  TextColumn get permissions => text().map(const StringListConverter()).withDefault(emptyList)();

  BoolColumn get isSessionExpired => boolean().withDefault(const Constant(false))();

  DateTimeColumn get lastSyncAt => dateTime()();

  BoolColumn get lastSyncFailed => boolean().withDefault(const Constant(false))();

  TextColumn get notificationIds => text().map(const IntListConverter()).withDefault(emptyList)();

  TextColumn get timeSettings => text().map(TimeSetting.listConverter)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {hospitalId, muid},
      ];
}
