import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/tables/log_events.dart';
import 'package:scalesoft_app/data/tables/users.dart';

part 'logs_dao.drift.dart';

@DriftAccessor(tables: [LogEvents, Users])
class LogsDao extends DatabaseAccessor<AppDatabase> with _$LogsDaoMixin {
  LogsDao(super.db);

  Future<int> save(LogEventsCompanion logEvent) async {
    return await into(logEvents).insert(logEvent);
  }

  Future<void> removeBeforeDateTime(DateTime olderThan) async {
    await (delete(logEvents)..where((x) => x.eventTime.isSmallerOrEqualValue(olderThan))).go();
  }

  Future<List<LogEvent>> getAll() async {
    return await (select(logEvents)).get();
  }

  Future<void> deleteUserReports(int? userId) async {
    if (userId == null) {
      await (delete(logEvents)..where((x) => x.userId.isNull())).go();
      return;
    }

    await (delete(logEvents)..where((log) => log.userId.equals(userId))).go();
  }
}
