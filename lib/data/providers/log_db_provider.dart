import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/enums/log_severity.dart';

@injectable
class LogDbProvider {
  final AppDatabase _database;

  LogDbProvider(this._database);

  Future<int> save(
    int? userId,
    LogSeverity severity,
    String message,
    DateTime eventTime,
    String appVersion,
    String osVersion,
  ) async {
    final log = LogEventsCompanion.insert(
      userId: Value(userId),
      eventTime: DateTime.now(),
      appVersion: appVersion,
      osVersion: osVersion,
      severity: severity,
      message: message,
    );

    return await _database.logsDao.save(log);
  }

  Future<Map<int?, List<LogEvent>>> getLogEventsPerUser() async {
    final entities = await _database.logsDao.getAll();

    final result = entities.groupListsBy((x) => x.userId);
    return result;
  }

  Future<void> removeBeforeDateTime(DateTime date) async {
    await _database.logsDao.removeBeforeDateTime(date);
  }

  /// Deletes all reports made by the given user. If [userMuid] is null, deletes all reports without a user.
  Future<void> deleteUserReports(int? userId) async {
    await _database.logsDao.deleteUserReports(userId);
  }
}
