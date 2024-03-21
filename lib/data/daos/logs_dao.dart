import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/combined_entities/log_with_muid.dart';
import 'package:scalesoft_app/data/tables/log_events.dart';
import 'package:scalesoft_app/data/tables/users.dart';

part 'logs_dao.drift.dart';

@DriftAccessor(tables: [LogEvents, Users])
class LogsDao extends DatabaseAccessor<AppDatabase> with _$LogsDaoMixin {
  LogsDao(AppDatabase db) : super(db);

  Future<int> save(LogEventsCompanion logEvent) async {
    return await into(logEvents).insert(logEvent);
  }

  Future<void> removeBeforeDateTime(DateTime olderThan) async {
    await (delete(logEvents)..where((x) => x.eventTime.isSmallerOrEqualValue(olderThan))).go();
  }

  Future<List<LogWithMuid>> getAll() async {
    final muidColumn = users.muid;

    final query = (select(logEvents)
          ..join([leftOuterJoin(users, logEvents.userId.equalsExp(users.id), useColumns: false)]))
        .addColumns([muidColumn]);

    final results = await query.map((row) => LogWithMuid(row.read(muidColumn), row.readTable(logEvents))).get();
    return results;
  }

  /// Deletes all reports made by the given user. If [userMuid] is null, deletes all reports without a user.
  Future<void> deleteUserReports(String? userMuid) async {
    if (userMuid == null) {
      await (delete(logEvents)..where((x) => x.userId.isNull())).go();
      return;
    }

    final userIds = await (selectOnly(users)
          ..addColumns([users.id])
          ..where((users.muid.equals(userMuid))))
        .map((x) => x.read(users.id)!)
        .get();

    await (delete(logEvents)..where((log) => log.userId.isIn(userIds))).go();
  }
}
